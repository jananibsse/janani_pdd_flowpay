"""
FlowPay Selenium Framework — Driver Factory
Manages WebDriver creation and configuration.
"""
import os
import sys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.firefox import GeckoDriverManager

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config.config import Config


class DriverFactory:
    """Factory class to create and configure Selenium WebDriver instances."""

    @staticmethod
    def create_driver(browser: str = None) -> webdriver.Remote:
        """
        Create and return a configured WebDriver instance.
        
        Args:
            browser: Browser type ('chrome' or 'firefox'). Defaults to Config.BROWSER.
        
        Returns:
            Configured WebDriver instance.
        """
        browser = (browser or Config.BROWSER).lower()
        
        if browser == "chrome":
            return DriverFactory._create_chrome_driver()
        elif browser == "firefox":
            return DriverFactory._create_firefox_driver()
        else:
            raise ValueError(f"Unsupported browser: {browser}. Use 'chrome' or 'firefox'.")

    @staticmethod
    def _create_chrome_driver() -> webdriver.Chrome:
        """Create a Chrome WebDriver with appropriate options."""
        options = ChromeOptions()
        
        if Config.HEADLESS:
            options.add_argument("--headless=new")
        
        # Performance and stability options
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-gpu")
        options.add_argument("--disable-web-security")
        options.add_argument("--allow-running-insecure-content")
        options.add_argument("--ignore-certificate-errors")
        options.add_argument(f"--window-size={Config.WINDOW_WIDTH},{Config.WINDOW_HEIGHT}")
        options.add_argument("--disable-extensions")
        options.add_argument("--disable-infobars")
        options.add_argument("--remote-debugging-port=9222")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_experimental_option("excludeSwitches", ["enable-automation"])
        options.add_experimental_option("useAutomationExtension", False)
        
        # Performance logging
        options.set_capability("goog:loggingPrefs", {
            "browser": "ALL",
            "performance": "ALL"
        })
        
        try:
            service = ChromeService(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=options)
        except Exception:
            # Fallback: use system chrome
            driver = webdriver.Chrome(options=options)
        
        driver.implicitly_wait(Config.IMPLICIT_WAIT)
        driver.set_page_load_timeout(Config.PAGE_LOAD_TIMEOUT)
        driver.set_script_timeout(Config.SCRIPT_TIMEOUT)
        
        return driver

    @staticmethod
    def _create_firefox_driver() -> webdriver.Firefox:
        """Create a Firefox WebDriver with appropriate options."""
        options = FirefoxOptions()
        
        if Config.HEADLESS:
            options.add_argument("--headless")
        
        options.add_argument(f"--width={Config.WINDOW_WIDTH}")
        options.add_argument(f"--height={Config.WINDOW_HEIGHT}")
        
        try:
            service = GeckoDriverManager().install()
            driver = webdriver.Firefox(
                service=service,
                options=options
            )
        except Exception:
            driver = webdriver.Firefox(options=options)
        
        driver.implicitly_wait(Config.IMPLICIT_WAIT)
        driver.set_page_load_timeout(Config.PAGE_LOAD_TIMEOUT)
        
        return driver

    @staticmethod
    def quit_driver(driver) -> None:
        """Safely quit the WebDriver instance."""
        if driver:
            try:
                driver.quit()
            except Exception:
                pass
