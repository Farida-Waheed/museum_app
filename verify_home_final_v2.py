from playwright.sync_api import Page, expect, sync_playwright
import time

def verify_home_screen(page: Page):
    # Set viewport to mobile-like size
    page.set_viewport_size({"width": 390, "height": 844})

    # 1. Arrange: Go to the local Flutter web server.
    print("Navigating to http://localhost:8080...")
    page.goto("http://localhost:8080")

    # Wait for Flutter to load
    time.sleep(10)

    # Onboarding should be visible. We need to click "START EXPLORING" to reach home.
    # Note: Flutter web can be tricky with selectors. Using text-based if possible.
    try:
        start_button = page.get_by_text("START EXPLORING")
        if start_button.count() > 0:
            print("Clicking 'START EXPLORING'...")
            start_button.click()
            time.sleep(2)
    except:
        print("Could not find 'START EXPLORING' button, maybe already on home.")

    # 4. Screenshot: Capture the final result for visual verification.
    print("Capturing screenshot...")
    page.screenshot(path="/home/jules/verification/final_home_screen_v2.png", full_page=True)
    print("Screenshot saved to /home/jules/verification/final_home_screen_v2.png")

if __name__ == "__main__":
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        try:
            verify_home_screen(page)
        finally:
            browser.close()
