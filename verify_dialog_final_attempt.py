
import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(viewport={'width': 450, 'height': 900})

        print("Navigating to app...")
        await page.goto('http://localhost:3000')

        print("Waiting for any button...")
        try:
            # The button is "START EXPLORING"
            button = await page.wait_for_selector('button, [role="button"]', timeout=40000)
            print("Found a button!")
            await page.screenshot(path='/home/jules/verification/onboarding_debug.png')
            await button.click()
            print("Clicked button")
        except Exception as e:
            print(f"Error finding button: {e}")
            await page.screenshot(path='/home/jules/verification/error_state.png')
            await browser.close()
            return

        print("Waiting for Home Screen...")
        try:
            # Home Screen text
            await page.wait_for_selector('text="Explore Egypt"', timeout=15000)
            print("Home Screen reached")

            # Wait for Dialog
            await asyncio.sleep(3) # Wait for animation
            await page.screenshot(path='/home/jules/verification/dialog_capture.png')
            print("Captured potential dialog")
        except Exception as e:
            print(f"Error reaching home or dialog: {e}")
            await page.screenshot(path='/home/jules/verification/home_error.png')

        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
