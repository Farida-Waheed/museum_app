from playwright.sync_api import sync_playwright, expect
import time

def run_verification():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        # Create a mobile-like context
        context = browser.new_context(
            viewport={'width': 390, 'height': 844},
            user_agent='Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1'
        )
        page = context.new_page()

        print("Navigating to http://localhost:8080...")
        try:
            page.goto("http://localhost:8080", timeout=60000)
        except Exception as e:
            print(f"Failed to navigate: {e}")
            browser.close()
            return

        # Wait for the app to load
        time.sleep(10)

        # Check if we are on onboarding or home. If onboarding, we might need to skip it or it might already be at home.
        # Based on my changes, I didn't touch onboarding but let's see.

        # Take a screenshot of the initial view
        page.screenshot(path="home_screen_initial.png")
        print("Initial screenshot saved as home_screen_initial.png")

        # Try to find and click "Allow" on the privacy dialog if it appears
        try:
            allow_button = page.get_by_role("button", name="Allow")
            if allow_button.is_visible(timeout=5000):
                allow_button.click()
                print("Clicked 'Allow' on privacy dialog")
                time.sleep(2)
        except:
            print("Privacy dialog not found or already dismissed")

        # Take screenshot of Home Screen
        page.screenshot(path="home_screen_v3_top.png")
        print("Home screen top screenshot saved as home_screen_v3_top.png")

        # Scroll down to see the rest
        page.evaluate("window.scrollTo(0, 1000)")
        time.sleep(2)
        page.screenshot(path="home_screen_v3_scrolled.png")
        print("Home screen scrolled screenshot saved as home_screen_v3_scrolled.png")

        browser.close()

if __name__ == "__main__":
    run_verification()
