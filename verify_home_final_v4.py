from playwright.sync_api import sync_playwright, expect
import time

def run_verification():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={'width': 390, 'height': 844},
            user_agent='Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1'
        )
        page = context.new_page()

        print("Navigating to http://localhost:8080...")
        page.goto("http://localhost:8080", timeout=60000)
        time.sleep(10)

        # Click "START EXPLORING" if on onboarding
        try:
            start_button = page.get_by_role("button", name="START EXPLORING")
            if start_button.is_visible(timeout=5000):
                start_button.click()
                print("Clicked 'START EXPLORING'")
                time.sleep(2)
        except:
            print("Start button not found")

        # Dismiss Privacy Dialog if it appears
        try:
            allow_button = page.get_by_role("button", name="Allow")
            if allow_button.is_visible(timeout=5000):
                allow_button.click()
                print("Clicked 'Allow' on privacy dialog")
                time.sleep(2)
        except:
            print("Privacy dialog not found")

        # Take screenshot of Home Screen
        page.screenshot(path="home_actual_top.png")
        print("Home screen top screenshot saved")

        # Scroll down
        page.evaluate("window.scrollTo(0, 1000)")
        time.sleep(2)
        page.screenshot(path="home_actual_scrolled.png")
        print("Home screen scrolled screenshot saved")

        browser.close()

if __name__ == "__main__":
    run_verification()
