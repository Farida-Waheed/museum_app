const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.setViewportSize({ width: 390, height: 844 });

  await page.goto('http://localhost:8080');

  // Wait for the app to load
  await page.waitForTimeout(5000);

  // Click "START EXPLORING"
  // Try multiple ways to click it
  try {
    await page.click('text=START EXPLORING', { timeout: 5000 });
  } catch (e) {
    console.log('Text click failed, trying coordinate click');
    // Based on the previous screenshot, the button is near the bottom
    await page.mouse.click(195, 800);
  }

  // Wait for transition to Home Screen
  await page.waitForTimeout(3000);

  await page.screenshot({ path: '/home/jules/verification/home_screen_actual.png' });

  // Try to scroll down to see more sections
  await page.mouse.wheel(0, 500);
  await page.waitForTimeout(1000);
  await page.screenshot({ path: '/home/jules/verification/home_screen_scrolled.png' });

  await browser.close();
})();
