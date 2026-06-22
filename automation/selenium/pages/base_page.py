"""
FlowPay Selenium Framework — Base Page Object
All page objects inherit from this base class.
"""
import os
import sys
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.remote.webelement import WebElement
from selenium.common.exceptions import (
    NoSuchElementException, TimeoutException, 
    StaleElementReferenceException, ElementNotInteractableException
)

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config.config import Config
from utils.waits import Waits
from utils.logger_utils import get_logger
from utils.screenshot_utils import ScreenshotUtils

logger = get_logger(__name__)


class BasePage:
    """
    Base Page Object that provides common functionality for all page objects.
    Implements POM (Page Object Model) pattern.
    """
    
    def __init__(self, driver: webdriver.Remote):
        self.driver = driver
        self.waits = Waits(driver)
        self.screenshots = ScreenshotUtils(driver)
        self.actions = ActionChains(driver)
        self.base_url = Config.BASE_URL
    
    # ─── Navigation ────────────────────────────────────────────
    
    def navigate_to(self, url: str = None) -> None:
        """Navigate to a URL (defaults to BASE_URL)."""
        target = url or self.base_url
        logger.info(f"Navigating to: {target}")
        self.driver.get(target)
        self.waits.wait_for_page_load()
    
    def go_back(self) -> None:
        """Navigate browser back."""
        self.driver.back()
        self.waits.wait_for_page_load()
    
    def refresh(self) -> None:
        """Refresh current page."""
        self.driver.refresh()
        self.waits.wait_for_page_load()
    
    def get_current_url(self) -> str:
        """Get the current URL."""
        return self.driver.current_url
    
    def get_page_title(self) -> str:
        """Get the current page title."""
        return self.driver.title
    
    # ─── Element Interaction ────────────────────────────────────
    
    def find_element(self, locator: tuple) -> WebElement:
        """Find element with explicit wait."""
        return self.waits.wait_for_element_present(locator)
    
    def find_elements(self, locator: tuple) -> list:
        """Find multiple elements."""
        return self.driver.find_elements(*locator)
    
    def click(self, locator: tuple, timeout: int = None) -> None:
        """Click an element with explicit wait."""
        try:
            element = self.waits.wait_for_element_clickable(locator)
            element.click()
            logger.debug(f"Clicked element: {locator}")
        except ElementNotInteractableException:
            # Try JavaScript click as fallback
            element = self.waits.wait_for_element_present(locator)
            self.driver.execute_script("arguments[0].click();", element)
    
    def type_text(self, locator: tuple, text: str, clear_first: bool = True) -> None:
        """Type text into an input field."""
        element = self.waits.wait_for_element_visible(locator)
        if clear_first:
            element.clear()
        element.send_keys(text)
        logger.debug(f"Typed '{text}' into {locator}")
    
    def get_text(self, locator: tuple) -> str:
        """Get visible text of an element."""
        try:
            element = self.waits.wait_for_element_visible(locator)
            return element.text
        except Exception:
            return ""
    
    def get_attribute(self, locator: tuple, attribute: str) -> str:
        """Get an attribute value from an element."""
        element = self.waits.wait_for_element_present(locator)
        return element.get_attribute(attribute) or ""
    
    def is_element_displayed(self, locator: tuple) -> bool:
        """Check if element is displayed (non-raising)."""
        try:
            element = self.driver.find_element(*locator)
            return element.is_displayed()
        except (NoSuchElementException, TimeoutException):
            return False
    
    def is_element_enabled(self, locator: tuple) -> bool:
        """Check if element is enabled."""
        try:
            element = self.driver.find_element(*locator)
            return element.is_enabled()
        except (NoSuchElementException, TimeoutException):
            return False
    
    def scroll_to_element(self, locator: tuple) -> None:
        """Scroll page to bring element into view."""
        element = self.waits.wait_for_element_present(locator)
        self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
        time.sleep(0.3)
    
    def hover_over(self, locator: tuple) -> None:
        """Hover over an element."""
        element = self.waits.wait_for_element_visible(locator)
        self.actions.move_to_element(element).perform()
    
    def press_key(self, locator: tuple, key) -> None:
        """Press a key on an element."""
        element = self.waits.wait_for_element_present(locator)
        element.send_keys(key)
    
    def clear_field(self, locator: tuple) -> None:
        """Clear an input field."""
        element = self.waits.wait_for_element_present(locator)
        element.clear()
    
    # ─── JavaScript Utilities ─────────────────────────────────
    
    def execute_script(self, script: str, *args):
        """Execute JavaScript in browser context."""
        return self.driver.execute_script(script, *args)
    
    def scroll_to_top(self) -> None:
        """Scroll page to top."""
        self.driver.execute_script("window.scrollTo(0, 0);")
    
    def scroll_to_bottom(self) -> None:
        """Scroll page to bottom."""
        self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    
    def get_page_source(self) -> str:
        """Get full page source."""
        return self.driver.page_source
    
    # ─── Window Management ─────────────────────────────────────
    
    def get_window_size(self) -> dict:
        """Get current browser window size."""
        return self.driver.get_window_size()
    
    def set_window_size(self, width: int, height: int) -> None:
        """Set browser window size."""
        self.driver.set_window_size(width, height)
    
    def maximize_window(self) -> None:
        """Maximize browser window."""
        self.driver.maximize_window()
    
    # ─── Assertions ────────────────────────────────────────────
    
    def assert_title_contains(self, text: str) -> bool:
        """Assert page title contains expected text."""
        title = self.get_page_title()
        result = text.lower() in title.lower()
        if not result:
            logger.warning(f"Title assertion failed. Expected '{text}' in '{title}'")
        return result
    
    def assert_url_contains(self, text: str) -> bool:
        """Assert current URL contains expected text."""
        url = self.get_current_url()
        result = text.lower() in url.lower()
        if not result:
            logger.warning(f"URL assertion failed. Expected '{text}' in '{url}'")
        return result
    
    def wait_and_assert_text(self, locator: tuple, expected_text: str) -> bool:
        """Wait for element and assert its text."""
        return self.waits.wait_for_text_in_element(locator, expected_text)
    
    # ─── Flutter Web Specific ─────────────────────────────────
    
    def wait_for_flutter(self) -> None:
        """Wait for Flutter web app to initialize."""
        self.waits.wait_for_flutter_app()
    
    def is_flutter_app_loaded(self) -> bool:
        """Check if Flutter web app is loaded."""
        try:
            result = self.driver.execute_script(
                "return document.querySelector('flutter-view') !== null || "
                "document.querySelector('flt-glass-pane') !== null || "
                "document.readyState === 'complete'"
            )
            return bool(result)
        except Exception:
            return False
