#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { spawnSync } = require('child_process');

const COLLECTION = 'exhibits';
const EXPECTED_COUNT = 30;
const STANDARD_ROUTE_IDS = [
  'artifact_001',
  'artifact_005',
  'artifact_002',
  'artifact_006',
  'artifact_018',
  'artifact_030',
];

const scriptDir = __dirname;
const mobileRoot = path.resolve(scriptDir, '..', '..');
const seedPath = path.join(scriptDir, 'exhibits.v1.json');
const validatorPath = path.join(scriptDir, 'validate_exhibits_seed.js');

const args = new Set(process.argv.slice(2));
const rawArgs = process.argv.slice(2);
const dryRun = args.has('--dry-run');
const merge = args.has('--merge');
const help = args.has('--help') || args.has('-h');
const projectArg = rawArgs.find((arg) => arg.startsWith('--project='));
const projectId =
  (projectArg && projectArg.slice('--project='.length)) ||
  process.env.FIREBASE_PROJECT_ID ||
  process.env.GOOGLE_CLOUD_PROJECT ||
  process.env.GCLOUD_PROJECT;

function usage() {
  console.log(`Usage: node shared/booking-product-system/seed_exhibits.js [--dry-run] [--merge]

Options:
  --dry-run   Validate and print what would be imported without writing Firestore.
  --merge     Use Firestore set(..., { merge: true }) instead of overwriting docs.
  --project=<firebase-project-id>
             Optional project ID. Can also be set with FIREBASE_PROJECT_ID.

Credentials:
  Set GOOGLE_APPLICATION_CREDENTIALS to a Firebase service account JSON path,
  or set FIREBASE_SERVICE_ACCOUNT_PATH to that path. Application Default
  Credentials are also supported if already configured.

This script writes only to Firestore collection: ${COLLECTION}`);
}

function sha256(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}

function loadAdminSdk() {
  try {
    return require('firebase-admin');
  } catch (error) {
    console.error('Missing dependency: firebase-admin');
    console.error('Install it before running a real import, for example: npm install firebase-admin');
    process.exit(1);
  }
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, ''));
}

function validateBeforeImport() {
  const result = spawnSync(process.execPath, [validatorPath], {
    cwd: mobileRoot,
    encoding: 'utf8',
  });

  if (result.stdout) process.stdout.write(result.stdout);
  if (result.stderr) process.stderr.write(result.stderr);

  if (result.status !== 0) {
    console.error('Validation failed. Aborting Firestore import.');
    process.exit(result.status || 1);
  }
}

function assertSeedShape(seedData) {
  if (!seedData || !Array.isArray(seedData.exhibits)) {
    throw new Error('Seed JSON must contain an exhibits array.');
  }

  if (seedData.exhibits.length !== EXPECTED_COUNT) {
    throw new Error(`Seed contains ${seedData.exhibits.length} exhibits, expected ${EXPECTED_COUNT}.`);
  }

  const ids = seedData.exhibits.map((exhibit) => exhibit.id);
  const uniqueIds = new Set(ids);
  if (uniqueIds.size !== ids.length) {
    throw new Error('Seed contains duplicate exhibit IDs.');
  }

  for (let index = 0; index < EXPECTED_COUNT; index += 1) {
    const expectedId = `artifact_${String(index + 1).padStart(3, '0')}`;
    if (ids[index] !== expectedId) {
      throw new Error(`Unexpected exhibit ID at index ${index}: ${ids[index]} != ${expectedId}`);
    }
  }
}

function initializeAdmin(admin) {
  const serviceAccountPath =
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
    process.env.GOOGLE_APPLICATION_CREDENTIALS;

  if (serviceAccountPath) {
    const resolvedPath = path.resolve(serviceAccountPath);
    if (!fs.existsSync(resolvedPath)) {
      throw new Error(`Service account file not found: ${resolvedPath}`);
    }

    const serviceAccount = readJson(resolvedPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: projectId || serviceAccount.project_id,
    });
    return;
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId,
  });
}

async function preflightFirestore(db) {
  try {
    await db.collection(COLLECTION).limit(1).get();
  } catch (error) {
    throw new Error(
      `Firestore credential/project preflight failed: ${error.message}. ` +
        'Set GOOGLE_APPLICATION_CREDENTIALS or FIREBASE_SERVICE_ACCOUNT_PATH to a service account JSON file, ' +
        'and set FIREBASE_PROJECT_ID or pass --project=<firebase-project-id> if the project cannot be inferred.',
    );
  }
}

async function batchWrite(db, exhibits) {
  let importedCount = 0;
  let failedCount = 0;
  const failedIds = [];
  const importedIds = [];

  for (let index = 0; index < exhibits.length; index += 500) {
    const chunk = exhibits.slice(index, index + 500);
    const batch = db.batch();

    for (const exhibit of chunk) {
      const ref = db.collection(COLLECTION).doc(exhibit.id);
      if (merge) {
        batch.set(ref, exhibit, { merge: true });
      } else {
        batch.set(ref, exhibit);
      }
    }

    try {
      await batch.commit();
      importedCount += chunk.length;
      importedIds.push(...chunk.map((exhibit) => exhibit.id));
    } catch (error) {
      failedCount += chunk.length;
      failedIds.push(...chunk.map((exhibit) => exhibit.id));
      console.error(`Batch failed for IDs ${chunk.map((exhibit) => exhibit.id).join(', ')}: ${error.message}`);
    }
  }

  return { importedCount, failedCount, failedIds, importedIds };
}

async function verifyImport(db, seedData) {
  const snapshot = await db.collection(COLLECTION).get();
  const allDocs = snapshot.docs;
  const seedIds = new Set(seedData.exhibits.map((exhibit) => exhibit.id));
  const importedDocs = allDocs.filter((doc) => seedIds.has(doc.id));
  const malformedIds = importedDocs
    .map((doc) => doc.id)
    .filter((id) => !/^artifact_\d{3}$/.test(id));
  const existingIds = new Set(importedDocs.map((doc) => doc.id));
  const missingSeedDocs = [...seedIds].filter((id) => !existingIds.has(id));
  const missingRouteDocs = STANDARD_ROUTE_IDS.filter((id) => !existingIds.has(id));
  const imageAssetIssues = [];
  const narrationIssues = [];

  for (const doc of importedDocs) {
    const data = doc.data();
    const seedExhibit = seedData.exhibits.find((exhibit) => exhibit.id === doc.id);
    const expectedImageAsset = seedExhibit && seedExhibit.media && seedExhibit.media.image_asset;
    const actualImageAsset = data.media && data.media.image_asset;
    const actualNarration = data.narration && data.narration.scripts && data.narration.scripts.en;

    if (expectedImageAsset && actualImageAsset !== expectedImageAsset) {
      imageAssetIssues.push(doc.id);
    }

    if (typeof actualNarration !== 'string' || actualNarration.length === 0) {
      narrationIssues.push(doc.id);
    }
  }

  return {
    collectionDocCount: allDocs.length,
    importedDocCount: importedDocs.length,
    missingSeedDocs,
    missingRouteDocs,
    malformedIds,
    imageAssetIssues,
    narrationIssues,
  };
}

async function main() {
  if (help) {
    usage();
    return;
  }

  validateBeforeImport();

  const seedBuffer = fs.readFileSync(seedPath);
  const seedData = JSON.parse(seedBuffer.toString('utf8').replace(/^\uFEFF/, ''));
  assertSeedShape(seedData);
  const exhibits = seedData.exhibits;

  console.log(`Seed hash: ${sha256(seedBuffer)}`);
  console.log(`Mode: ${dryRun ? 'dry-run' : 'import'}${merge ? ' with merge' : ' overwrite'}`);
  console.log(`Target collection: ${COLLECTION}`);
  console.log(`Planned artifact count: ${exhibits.length}`);
  console.log('Planned IDs:');
  for (const exhibit of exhibits) console.log(`- ${exhibit.id}`);

  if (dryRun) {
    console.log('\nImport summary:');
    console.log(`imported count: 0`);
    console.log(`skipped count: ${exhibits.length}`);
    console.log(`failed count: 0`);
    console.log('Dry run complete. No Firestore writes were performed.');
    return;
  }

  const admin = loadAdminSdk();
  initializeAdmin(admin);
  const db = admin.firestore();
  await preflightFirestore(db);

  const result = await batchWrite(db, exhibits);
  const skippedCount = exhibits.length - result.importedCount - result.failedCount;

  console.log('\nImported IDs:');
  for (const id of result.importedIds) console.log(`- ${id}`);

  console.log('\nImport summary:');
  console.log(`imported count: ${result.importedCount}`);
  console.log(`skipped count: ${skippedCount}`);
  console.log(`failed count: ${result.failedCount}`);

  if (result.failedIds.length > 0) {
    console.log(`failed IDs: ${result.failedIds.join(', ')}`);
    process.exitCode = 1;
    return;
  }

  const verification = await verifyImport(db, seedData);
  const verificationFailures = [
    ...(verification.collectionDocCount === EXPECTED_COUNT
      ? []
      : [`collection contains ${verification.collectionDocCount} docs, expected ${EXPECTED_COUNT}`]),
    ...verification.missingSeedDocs.map((id) => `missing seeded doc ${id}`),
    ...verification.missingRouteDocs.map((id) => `missing standard route doc ${id}`),
    ...verification.malformedIds.map((id) => `malformed imported ID ${id}`),
    ...verification.imageAssetIssues.map((id) => `image_asset mismatch ${id}`),
    ...verification.narrationIssues.map((id) => `missing narration.scripts.en ${id}`),
  ];

  console.log('\nVerification summary:');
  console.log(`collection docs visible: ${verification.collectionDocCount}`);
  console.log(`seed docs found: ${verification.importedDocCount}`);
  console.log(`standard route docs found: ${STANDARD_ROUTE_IDS.length - verification.missingRouteDocs.length}/${STANDARD_ROUTE_IDS.length}`);
  console.log(`malformed imported IDs: ${verification.malformedIds.length}`);
  console.log(`image_asset issues: ${verification.imageAssetIssues.length}`);
  console.log(`narration.scripts.en issues: ${verification.narrationIssues.length}`);

  if (verificationFailures.length > 0) {
    console.log('\nVerification failures:');
    for (const item of verificationFailures) console.log(`- ${item}`);
    process.exitCode = 1;
  } else {
    console.log('Verification result: PASS');
  }
}

main().catch((error) => {
  console.error(`Seeder failed: ${error.message}`);
  process.exit(1);
});
