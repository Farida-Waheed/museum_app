#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const EXPECTED_COUNT = 30;
const EXPECTED_IDS = Array.from({ length: EXPECTED_COUNT }, (_, index) =>
  `artifact_${String(index + 1).padStart(3, '0')}`,
);
const STANDARD_ROUTE_IDS = [
  'artifact_001',
  'artifact_005',
  'artifact_002',
  'artifact_006',
  'artifact_018',
  'artifact_030',
];
const ALLOWED_MISSING_IMAGES = new Set([
  'artifact_009',
  'artifact_010',
  'artifact_011',
  'artifact_022',
]);

const scriptDir = __dirname;
const mobileRoot = path.resolve(scriptDir, '..', '..');
const defaultOriginalPath = path.join(
  'C:',
  'Users',
  'Farid',
  'Downloads',
  'TourGuideRag_V02.txt',
);
const originalPath = process.env.TOUR_GUIDE_RAG_PATH || defaultOriginalPath;
const mobileSeedPath = path.join(scriptDir, 'exhibits.v1.json');
const websiteSeedPath =
  process.env.WEBSITE_EXHIBITS_SEED_PATH ||
  path.join(
    'D:',
    'Grad_Project',
    'Website',
    'horus-bot',
    'shared',
    'booking-product-system',
    'exhibits.v1.json',
  );

const failures = [];
const warnings = [];
const mismatches = [];

function fileExists(filePath) {
  try {
    return fs.statSync(filePath).isFile();
  } catch (_) {
    return false;
  }
}

function readFile(filePath) {
  return fs.readFileSync(filePath);
}

function sha256(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}

function fail(message) {
  failures.push(message);
}

function mismatch(message) {
  mismatches.push(message);
}

function arraysEqual(a, b) {
  return JSON.stringify(a) === JSON.stringify(b);
}

function parseConcatenatedJsonObjects(text) {
  const objects = [];
  let index = 0;

  while (index < text.length) {
    while (index < text.length && /\s/.test(text[index])) index += 1;
    if (index >= text.length) break;

    if (text[index] !== '{') {
      throw new Error(`Expected JSON object at character ${index}`);
    }

    const start = index;
    let depth = 0;
    let inString = false;
    let escaped = false;

    for (; index < text.length; index += 1) {
      const char = text[index];

      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char === '\\') {
          escaped = true;
        } else if (char === '"') {
          inString = false;
        }
        continue;
      }

      if (char === '"') {
        inString = true;
      } else if (char === '{') {
        depth += 1;
      } else if (char === '}') {
        depth -= 1;
        if (depth === 0) {
          index += 1;
          objects.push(JSON.parse(text.slice(start, index)));
          break;
        }
      }
    }

    if (depth !== 0) {
      throw new Error(`Unclosed JSON object starting at character ${start}`);
    }
  }

  return objects;
}

function compareExact(artifactId, fieldName, originalValue, seedValue) {
  if (!arraysEqual(originalValue, seedValue)) {
    mismatch(`${artifactId}: ${fieldName} does not match original source`);
  }
}

function main() {
  let originalHash = null;
  let seedHash = null;
  let artifactCount = 0;
  let missingImages = [];

  if (!fileExists(originalPath)) {
    fail(`Original NLP/RAG source not found: ${originalPath}`);
  }

  if (!fileExists(mobileSeedPath)) {
    fail(`Shared seed not found: ${mobileSeedPath}`);
  }

  if (failures.length === 0) {
    const originalBuffer = readFile(originalPath);
    const seedBuffer = readFile(mobileSeedPath);
    originalHash = sha256(originalBuffer);
    seedHash = sha256(seedBuffer);

    let originalArtifacts = [];
    let seedData = null;

    try {
      originalArtifacts = parseConcatenatedJsonObjects(
        originalBuffer.toString('utf8').replace(/^\uFEFF/, ''),
      );
    } catch (error) {
      fail(`Unable to parse original NLP/RAG source: ${error.message}`);
    }

    try {
      seedData = JSON.parse(seedBuffer.toString('utf8').replace(/^\uFEFF/, ''));
    } catch (error) {
      fail(`Unable to parse exhibits seed: ${error.message}`);
    }

    if (seedData && !Array.isArray(seedData.exhibits)) {
      fail('Seed JSON must contain an exhibits array');
    }

    if (failures.length === 0) {
      const seedArtifacts = seedData.exhibits;
      artifactCount = seedArtifacts.length;

      if (originalArtifacts.length !== EXPECTED_COUNT) {
        fail(`Original source artifact count is ${originalArtifacts.length}, expected ${EXPECTED_COUNT}`);
      }

      if (seedArtifacts.length !== EXPECTED_COUNT) {
        fail(`Seed artifact count is ${seedArtifacts.length}, expected ${EXPECTED_COUNT}`);
      }

      const originalById = new Map(originalArtifacts.map((artifact) => [artifact.id, artifact]));
      const seedById = new Map(seedArtifacts.map((artifact) => [artifact.id, artifact]));
      const seedIds = seedArtifacts.map((artifact) => artifact.id);
      const uniqueSeedIds = new Set(seedIds);

      if (uniqueSeedIds.size !== seedIds.length) {
        fail('Seed artifact IDs are not unique');
      }

      if (!arraysEqual(seedIds, EXPECTED_IDS)) {
        fail(`Seed IDs must be exactly ${EXPECTED_IDS[0]} through ${EXPECTED_IDS[EXPECTED_IDS.length - 1]} in order`);
      }

      for (const expectedId of EXPECTED_IDS) {
        if (!originalById.has(expectedId)) {
          fail(`Original source missing ${expectedId}`);
        }
        if (!seedById.has(expectedId)) {
          fail(`Seed missing ${expectedId}`);
        }
      }

      for (const artifactId of EXPECTED_IDS) {
        const original = originalById.get(artifactId);
        const seed = seedById.get(artifactId);
        if (!original || !seed) continue;

        compareExact(artifactId, 'title_en/title', original.title, seed.title_en);
        compareExact(
          artifactId,
          'narration.scripts.en/storytelling_script',
          original.storytelling_script,
          seed.narration && seed.narration.scripts && seed.narration.scripts.en,
        );
        compareExact(
          artifactId,
          'content_en.historical_background',
          original.historical_background,
          seed.content_en && seed.content_en.historical_background,
        );
        compareExact(
          artifactId,
          'content_en.historical_significance',
          original.historical_significance,
          seed.content_en && seed.content_en.historical_significance,
        );
        compareExact(
          artifactId,
          'content_en.symbolism',
          original.symbolism,
          seed.content_en && seed.content_en.symbolism,
        );
        compareExact(
          artifactId,
          'content_en.important_facts',
          original.important_facts,
          seed.content_en && seed.content_en.important_facts,
        );

        const imageAsset = seed.media && seed.media.image_asset;
        if (imageAsset === null || imageAsset === undefined || imageAsset === '') {
          missingImages.push(artifactId);
          if (!ALLOWED_MISSING_IMAGES.has(artifactId)) {
            mismatch(`${artifactId}: media.image_asset is missing but is not in the allowed missing image list`);
          }
        } else {
          const imagePath = path.join(mobileRoot, imageAsset);
          if (!fileExists(imagePath)) {
            mismatch(`${artifactId}: media.image_asset path does not exist: ${imageAsset}`);
          }
        }
      }

      const invalidMissingImages = missingImages.filter(
        (artifactId) => !ALLOWED_MISSING_IMAGES.has(artifactId),
      );
      const missingExpectedImages = [...ALLOWED_MISSING_IMAGES].filter(
        (artifactId) => !missingImages.includes(artifactId),
      );

      if (invalidMissingImages.length > 0) {
        fail(`Unexpected missing images: ${invalidMissingImages.join(', ')}`);
      }

      if (missingExpectedImages.length > 0) {
        warnings.push(`Allowed missing image list contains artifacts that now have images: ${missingExpectedImages.join(', ')}`);
      }

      if (!arraysEqual(seedData.standard_route_ids, STANDARD_ROUTE_IDS)) {
        fail(`standard_route_ids must be ${STANDARD_ROUTE_IDS.join(', ')}`);
      }

      for (const routeId of STANDARD_ROUTE_IDS) {
        if (!seedById.has(routeId)) {
          fail(`Standard route ID does not exist in seed: ${routeId}`);
        }
      }

      for (const seed of seedArtifacts) {
        const expectedOrder = STANDARD_ROUTE_IDS.indexOf(seed.id) + 1;
        if (expectedOrder > 0) {
          if (seed.route_order !== expectedOrder) {
            mismatch(`${seed.id}: route_order is ${seed.route_order}, expected ${expectedOrder}`);
          }
        } else if (seed.route_order !== null) {
          mismatch(`${seed.id}: route_order must be null for non-standard route artifacts`);
        }
      }

      if (fileExists(websiteSeedPath)) {
        const websiteBuffer = readFile(websiteSeedPath);
        if (!seedBuffer.equals(websiteBuffer)) {
          fail(`Website and mobile exhibits.v1.json files are not identical: ${websiteSeedPath}`);
        }
      } else {
        warnings.push(`Website seed not accessible, skipped identity check: ${websiteSeedPath}`);
      }
    }
  }

  if (mismatches.length > 0) {
    fail(`${mismatches.length} mismatch(es) found`);
  }

  const status = failures.length === 0 ? 'PASS' : 'FAIL';
  console.log(`Seed validation: ${status}`);
  console.log(`Artifact count: ${artifactCount}`);
  console.log(`Missing images: ${missingImages.length ? missingImages.join(', ') : 'none'}`);
  console.log(`Original hash: ${originalHash || 'unavailable'}`);
  console.log(`Seed hash: ${seedHash || 'unavailable'}`);

  if (mismatches.length > 0) {
    console.log('\nMismatches:');
    for (const item of mismatches) console.log(`- ${item}`);
  } else {
    console.log('Mismatches: none');
  }

  if (warnings.length > 0) {
    console.log('\nWarnings:');
    for (const item of warnings) console.log(`- ${item}`);
  }

  if (failures.length > 0) {
    console.log('\nFailures:');
    for (const item of failures) console.log(`- ${item}`);
    process.exitCode = 1;
  }
}

main();
