"""
FlowPay Selenium Framework — Screenshot Utilities
Captures and manages screenshots for test evidence.
"""
import os
import sys
import time
import base64
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config.config import Config
from utils.logger_utils import get_logger

logger = get_logger(__name__)


class ScreenshotUtils:
    """Utility class for capturing and managing screenshots."""
    
    def __init__(self, driver: webdriver.Remote):
        self.driver = driver
        Config.ensure_directories()
    
    def capture_screenshot(self, test_name: str, suffix: str = "") -> str:
        """
        Capture a full-page screenshot.
        
        Args:
            test_name: Name of the test case.
            suffix: Optional suffix (e.g., 'failure', 'before', 'after').
        
        Returns:
            Absolute path to the saved screenshot.
        """
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            safe_name = "".join(c if c.isalnum() or c in ('-', '_') else '_' for c in test_name)
            suffix_part = f"_{suffix}" if suffix else ""
            filename = f"{safe_name}{suffix_part}_{timestamp}.png"
            filepath = os.path.join(Config.SCREENSHOTS_DIR, filename)
            
            self.driver.save_screenshot(filepath)
            logger.info(f"Screenshot saved: {filepath}")
            return filepath
        except Exception as e:
            logger.error(f"Failed to capture screenshot: {e}")
            return ""
    
    def capture_failure_screenshot(self, test_name: str) -> str:
        """Capture a screenshot on test failure."""
        return self.capture_screenshot(test_name, suffix="FAILURE")
    
    def capture_element_screenshot(self, element, test_name: str) -> str:
        """Capture screenshot of a specific element."""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"{test_name}_element_{timestamp}.png"
            filepath = os.path.join(Config.SCREENSHOTS_DIR, filename)
            element.screenshot(filepath)
            return filepath
        except Exception as e:
            logger.error(f"Failed to capture element screenshot: {e}")
            return self.capture_screenshot(test_name, "element_fallback")
    
    def get_browser_logs(self) -> list:
        """Retrieve browser console logs."""
        try:
            logs = self.driver.get_log("browser")
            return logs
        except Exception as e:
            logger.warning(f"Could not retrieve browser logs: {e}")
            return []
    
    def get_page_source_snippet(self, length: int = 2000) -> str:
        """Get a snippet of the current page source."""
        try:
            source = self.driver.page_source
            return source[:length] if len(source) > length else source
        except Exception as e:
            logger.warning(f"Could not get page source: {e}")
            return ""
    
    def screenshot_to_base64(self, filepath: str) -> str:
        """Convert screenshot to base64 for embedding in HTML reports."""
        try:
            if os.path.exists(filepath):
                with open(filepath, "rb") as f:
                    return base64.b64encode(f.read()).decode("utf-8")
        except Exception as e:
            logger.warning(f"Could not convert screenshot to base64: {e}")
        return ""
