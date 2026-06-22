package com.flowpay.automation.tests;

import com.flowpay.automation.config.AppiumConfig;
import io.appium.java_client.android.AndroidDriver;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.ITestResult;
import org.testng.annotations.*;

/**
 * FlowPay Appium — Base Test Class
 * All test classes extend this base class.
 * Manages driver lifecycle and common test hooks.
 */
public abstract class BaseTest {

    protected static final Logger log = LogManager.getLogger(BaseTest.class);
    protected AndroidDriver driver;

    @BeforeSuite(alwaysRun = true)
    public void beforeSuite() {
        log.info("╔══════════════════════════════════════════╗");
        log.info("║     FlowPay Appium Test Suite Starting  ║");
        log.info("╠══════════════════════════════════════════╣");
        log.info("║  App Package : {}  ║", AppiumConfig.APP_PACKAGE);
        log.info("║  Platform    : Android {}                ║", AppiumConfig.PLATFORM_VERSION);
        log.info("║  Server      : {}                        ║", AppiumConfig.APPIUM_SERVER);
        log.info("╚══════════════════════════════════════════╝");
    }

    @BeforeClass(alwaysRun = true)
    public void beforeClass() {
        log.info("📱 Initialising driver for: {}", getClass().getSimpleName());
        driver = AppiumConfig.createDriver();
    }

    @BeforeMethod(alwaysRun = true)
    public void beforeMethod(java.lang.reflect.Method method) {
        log.info("▶️  Starting: {}.{}", getClass().getSimpleName(), method.getName());
    }

    @AfterMethod(alwaysRun = true)
    public void afterMethod(ITestResult result) {
        if (!result.isSuccess()) {
            log.error("❌ FAILED: {}", result.getName());
            try {
                String screenshot = captureFailureScreenshot(result.getName());
                log.info("📷 Failure screenshot: {}", screenshot);
            } catch (Exception e) {
                log.warn("Could not capture screenshot: {}", e.getMessage());
            }
        } else {
            log.info("✅ PASSED: {}", result.getName());
        }
    }

    @AfterClass(alwaysRun = true)
    public void afterClass() {
        log.info("🔄 Tearing down driver for: {}", getClass().getSimpleName());
        AppiumConfig.quitDriver();
    }

    @AfterSuite(alwaysRun = true)
    public void afterSuite() {
        log.info("╔══════════════════════════════════════════╗");
        log.info("║     FlowPay Appium Suite Complete       ║");
        log.info("╚══════════════════════════════════════════╝");
    }

    protected String captureFailureScreenshot(String testName) {
        try {
            byte[] bytes = (byte[]) driver.getScreenshotAs(org.openqa.selenium.OutputType.BYTES);
            String dir  = "../../Appium_Results/screenshots";
            java.nio.file.Files.createDirectories(java.nio.file.Paths.get(dir));
            String path = dir + "/FAIL_" + testName + "_" +
                          java.time.LocalDateTime.now().format(
                              java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")
                          ) + ".png";
            java.nio.file.Files.write(java.nio.file.Paths.get(path), bytes);
            return path;
        } catch (Exception e) {
            return "screenshot_failed";
        }
    }

    protected void sleep(long ms) {
        try { Thread.sleep(ms); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
    }
}
