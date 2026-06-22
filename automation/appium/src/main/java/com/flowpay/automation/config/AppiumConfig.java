package com.flowpay.automation.config;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.options.UiAutomator2Options;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;

/**
 * FlowPay Appium Configuration
 * Manages AndroidDriver creation and desired capabilities.
 */
public class AppiumConfig {

    private static final Logger log = LogManager.getLogger(AppiumConfig.class);

    // ─── Server Config ────────────────────────────────────────
    public static final String APPIUM_SERVER =
            System.getProperty("appium.server", "http://localhost:4723");

    // ─── App Config ───────────────────────────────────────────
    public static final String APP_PACKAGE =
            System.getProperty("app.package", "com.example.flowpay_app");
    public static final String APP_ACTIVITY =
            System.getProperty("app.activity", "com.example.flowpay_app.MainActivity");
    public static final String PLATFORM_VERSION =
            System.getProperty("platform.version", "13");
    public static final String DEVICE_NAME =
            System.getProperty("device.name", "Pixel_5_API_33");

    // ─── Timeouts ─────────────────────────────────────────────
    public static final int IMPLICIT_WAIT_SEC  = 10;
    public static final int EXPLICIT_WAIT_SEC  = 30;
    public static final int NEW_COMMAND_TIMEOUT = 300;

    // ─── Screenshot Path ──────────────────────────────────────
    public static final String SCREENSHOTS_DIR = "../../Appium_Results/screenshots";
    public static final String LOGS_DIR        = "../../Appium_Results/logs";

    private static ThreadLocal<AndroidDriver> driverThread = new ThreadLocal<>();

    /**
     * Create and configure an AndroidDriver instance.
     */
    public static AndroidDriver createDriver() {
        UiAutomator2Options options = new UiAutomator2Options();
        options.setPlatformName("Android");
        options.setPlatformVersion(PLATFORM_VERSION);
        options.setDeviceName(DEVICE_NAME);
        options.setAppPackage(APP_PACKAGE);
        options.setAppActivity(APP_ACTIVITY);
        options.setNoReset(false);
        options.setFullReset(false);
        options.setNewCommandTimeout(Duration.ofSeconds(NEW_COMMAND_TIMEOUT));
        options.setAutoGrantPermissions(true);
        options.setUnicodeKeyboard(true);
        options.setResetKeyboard(true);

        // Disable animations for faster tests
        options.setCapability("settings[animatorDurationScale]", 0.0);
        options.setCapability("settings[transitionAnimationScale]", 0.0);
        options.setCapability("settings[windowAnimationScale]", 0.0);

        try {
            URL serverUrl = new URL(APPIUM_SERVER);
            AndroidDriver driver = new AndroidDriver(serverUrl, options);
            driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(IMPLICIT_WAIT_SEC));
            driverThread.set(driver);
            log.info("✅ AndroidDriver created successfully");
            log.info("   Device  : {}", DEVICE_NAME);
            log.info("   Package : {}", APP_PACKAGE);
            log.info("   Platform: Android {}", PLATFORM_VERSION);
            return driver;
        } catch (MalformedURLException e) {
            log.error("❌ Invalid Appium server URL: {}", APPIUM_SERVER, e);
            throw new RuntimeException("Invalid Appium server URL: " + APPIUM_SERVER, e);
        } catch (Exception e) {
            log.error("❌ Driver creation failed: {}", e.getMessage(), e);
            throw new RuntimeException("Driver creation failed: " + e.getMessage(), e);
        }
    }

    public static AndroidDriver getDriver() {
        return driverThread.get();
    }

    public static void quitDriver() {
        AndroidDriver driver = driverThread.get();
        if (driver != null) {
            try {
                driver.quit();
                log.info("🔄 Driver quit successfully");
            } catch (Exception e) {
                log.warn("⚠️ Error quitting driver: {}", e.getMessage());
            } finally {
                driverThread.remove();
            }
        }
    }
}
