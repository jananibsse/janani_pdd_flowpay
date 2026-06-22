"""
FlowPay Selenium Framework — Explicit Waits Utility
Provides reusable wait conditions for reliable element interaction.
"""
import os
import sys
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webelement import WebElement
from selenium.common.exceptions import TimeoutException, NoSuchElementException

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config.config import Config
from utils.logger_utils import get_logger

logger = get_logger(__name__)


class Waits:
    """Utility class providing explicit wait methods for reliable automation."""
    
    def __init__(self, driver: webdriver.Remote, timeout: int = None):
        self.driver = driver
        self.timeout = timeout or Config.EXPLICIT_WAIT
        self.wait = WebDriverWait(driver, self.timeout)
    
    def wait_for_element_visible(self, locator: tuple) -> WebElement:
        """Wait until element is visible and return it."""
        try:
            return self.wait.until(EC.visibility_of_element_located(locator))
        except TimeoutException:
            logger.error(f"Element not visible after {self.timeout}s: {locator}")
            raise
    
    def wait_for_element_clickable(self, locator: tuple) -> WebElement:
        """Wait until element is clickable and return it."""
        try:
            return self.wait.until(EC.element_to_be_clickable(locator))
        except TimeoutException:
            logger.error(f"Element not clickable after {self.timeout}s: {locator}")
            raise
    
    def wait_for_element_present(self, locator: tuple) -> WebElement:
        """Wait until element is present in DOM."""
        try:
            return self.wait.until(EC.presence_of_element_located(locator))
        except TimeoutException:
            logger.error(f"Element not present after {self.timeout}s: {locator}")
            raise
    
    def wait_for_text_in_element(self, locator: tuple, text: str) -> bool:
        """Wait until element contains specific text."""
        try:
            return self.wait.until(EC.text_to_be_present_in_element(locator, text))
        except TimeoutException:
            logger.error(f"Text '{text}' not found in element {locator} after {self.timeout}s")
            return False
    
    def wait_for_url_contains(self, text: str) -> bool:
        """Wait until URL contains specific text."""
        try:
            return self.wait.until(EC.url_contains(text))
        except TimeoutException:
            logger.warning(f"URL did not contain '{text}' after {self.timeout}s")
            return False
    
    def wait_for_title_contains(self, text: str) -> bool:
        """Wait until page title contains specific text."""
        try:
            return self.wait.until(EC.title_contains(text))
        except TimeoutException:
            logger.warning(f"Title did not contain '{text}' after {self.timeout}s")
            return False
    
    def wait_for_element_invisible(self, locator: tuple) -> bool:
        """Wait until element is invisible."""
        try:
            return self.wait.until(EC.invisibility_of_element_located(locator))
        except TimeoutException:
            return False
    
    def wait_for_page_load(self) -> None:
        """Wait for complete page load via JavaScript."""
        self.wait.until(
            lambda d: d.execute_script("return document.readyState") == "complete"
        )
    
    def is_element_present(self, locator: tuple, timeout: int = 5) -> bool:
        """Check if element is present within timeout (non-raising)."""
        try:
            short_wait = WebDriverWait(self.driver, timeout)
            short_wait.until(EC.presence_of_element_located(locator))
            return True
        except (TimeoutException, NoSuchElementException):
            return False
    
    def wait_for_flutter_app(self) -> None:
        """Wait for Flutter web app to fully load."""
        try:
            # Wait for Flutter initialization
            self.wait.until(
                lambda d: d.execute_script(
                    "return typeof window._flutter !== 'undefined'"
                )
            )
        except TimeoutException:
            # If Flutter object not found, just wait for page load
            self.wait_for_page_load()
