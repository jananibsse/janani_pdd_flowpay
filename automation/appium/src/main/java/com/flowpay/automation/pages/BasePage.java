package com.flowpay.automation.pages;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.pagefactory.AppiumFieldDecorator;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * FlowPay Appium — Base Page Object
 * All page objects inherit from this base class.
 * Implements Page Object Model (POM) pattern.
 */
public abstract class BasePage {

    protected static final Logger log = LogManager.getLogger(BasePage.class);
    protected AndroidDriver driver;
    protected WebDriverWait wait;

    private static final String SCREENSHOTS_DIR = "../../Appium_Results/screenshots";
    private static final DateTimeFormatter DTF =
            DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss");

    public BasePage(AndroidDriver driver) {
        this.driver = driver;
        this.wait   = new WebDriverWait(driver, Duration.ofSeconds(30));
        PageFactory.initElements(new AppiumFieldDecorator(driver), this);
        ensureDirectories();
    }

    // ─── Navigation ───────────────────────────────────────────

    /** Launch the app. */
    public void launchApp() {
        driver.activateApp(System.getProperty("app.package", "com.example.flowpay_app"));
        log.info("App launched");
    }

    /** Send app to background. */
    public void backgroundApp(int seconds) {
        driver.runAppInBackground(Duration.ofSeconds(seconds));
    }

    /** Get current activity name. */
    public String getCurrentActivity() {
        return driver.currentActivity();
    }

    // ─── Element Interactions ─────────────────────────────────

    public WebElement findElement(By locator) {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    public List<WebElement> findElements(By locator) {
        return driver.findElements(locator);
    }

    public void tap(By locator) {
        log.debug("Tapping: {}", locator);
        wait.until(ExpectedConditions.elementToBeClickable(locator)).click();
    }

    public void typeText(By locator, String text) {
        log.debug("Typing '{}' into {}", text, locator);
        WebElement el = wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
        el.clear();
        el.sendKeys(text);
    }

    public String getText(By locator) {
        try {
            return wait.until(ExpectedConditions.visibilityOfElementLocated(locator)).getText();
        } catch (Exception e) {
            return "";
        }
    }

    public boolean isDisplayed(By locator) {
        try {
            return driver.findElement(locator).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public boolean isEnabled(By locator) {
        try {
            return driver.findElement(locator).isEnabled();
        } catch (Exception e) {
            return false;
        }
    }

    public void waitForVisible(By locator) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    public void waitForInvisible(By locator) {
        wait.until(ExpectedConditions.invisibilityOfElementLocated(locator));
    }

    public boolean waitForText(By locator, String text) {
        try {
            return wait.until(ExpectedConditions.textToBePresentInElementLocated(locator, text));
        } catch (Exception e) {
            return false;
        }
    }

    // ─── Gestures ────────────────────────────────────────────

    public void scrollDown() {
        driver.executeScript("mobile: scroll", "direction=down");
    }

    public void scrollUp() {
        driver.executeScript("mobile: scroll", "direction=up");
    }

    public void hideKeyboard() {
        try { driver.hideKeyboard(); } catch (Exception ignored) {}
    }

    public void pressBack() {
        driver.navigate().back();
    }

    // ─── Screenshots ─────────────────────────────────────────

    public String captureScreenshot(String testName) {
        try {
            String timestamp = LocalDateTime.now().format(DTF);
            String safeName  = testName.replaceAll("[^a-zA-Z0-9_-]", "_");
            String filename   = safeName + "_" + timestamp + ".png";
            Path   filepath   = Paths.get(SCREENSHOTS_DIR, filename);

            byte[] bytes = (byte[]) driver.getScreenshotAs(org.openqa.selenium.OutputType.BYTES);
            Files.write(filepath, bytes);
            log.info("📷 Screenshot: {}", filepath);
            return filepath.toString();
        } catch (Exception e) {
            log.warn("Could not capture screenshot: {}", e.getMessage());
            return "";
        }
    }

    public String captureFailureScreenshot(String testName) {
        return captureScreenshot("FAILURE_" + testName);
    }

    // ─── Utilities ────────────────────────────────────────────

    public void sleep(long ms) {
        try { Thread.sleep(ms); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
    }

    public String getPageSource() {
        return driver.getPageSource();
    }

    private void ensureDirectories() {
        try {
            Files.createDirectories(Paths.get(SCREENSHOTS_DIR));
            Files.createDirectories(Paths.get("../../Appium_Results/logs"));
        } catch (IOException ignored) {}
    }
}
