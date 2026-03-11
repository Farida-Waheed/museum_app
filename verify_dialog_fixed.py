
import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        # Use a larger viewport to see the full UI
        page = await browser.new_page(viewport={'width': 450, 'height': 900})

        # Navigate to the app
        await page.goto('http://localhost:3000')

        # Wait for Onboarding
        await page.wait_for_selector('text="START EXPLORING"')
        await page.click('text="START EXPLORING"')

        # Wait for Home Screen to load
        await page.wait_for_selector('text="Explore Egypt"', timeout=10000)

        # Wait for the Permission Dialog to appear (it has a small delay)
        try:
            await page.wait_for_selector('text="Privacy & Permissions"', timeout=5000)
            print("Dialog detected")
            await page.screenshot(path='/home/jules/verification/dialog_final.png')
        except:
            print("Dialog not detected automatically, might have already been seen or timing issue")
            # Force screenshot of home screen anyway
            await page.screenshot(path='/home/jules/verification/home_post_onboarding.png')

        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
