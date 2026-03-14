import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page(viewport={'width': 390, 'height': 844})

        # Navigate to the app
        await page.goto('http://localhost:8080/#/home')

        # Wait for any loading to finish
        await page.wait_for_timeout(5000)

        # Take a screenshot
        await page.screenshot(path='home_screen_final.png', full_page=True)

        await browser.close()

if __name__ == '__main__':
    asyncio.run(run())
