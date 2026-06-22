package com.flowpay.automation.pages;

import io.appium.java_client.android.AndroidDriver;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

/**
 * FlowPay Appium — Login Page Object
 * Encapsulates all login screen interactions.
 */
public class LoginPage extends BasePage {

    // ─── Locators ─────────────────────────────────────────────
    private static final By EMAIL_FIELD =
            By.xpath("//*[@content-desc='email_field' or contains(@resource-id,'email') "
                   + "or contains(@hint,'Email') or contains(@text,'Email')]");
    private static final By PASSWORD_FIELD =
            By.xpath("//*[@content-desc='password_field' or contains(@resource-id,'password') "
                   + "or contains(@hint,'Password') or contains(@text,'Password')]");
    private static final By LOGIN_BUTTON =
            By.xpath("//*[@content-desc='login_button' or @text='Login' or @text='Sign In' "
                   + "or @text='LOG IN']");
    private static final By REGISTER_LINK =
            By.xpath("//*[@content-desc='register_link' or @text='Register' or @text='Sign Up' "
                   + "or contains(@text,'Create Account')]");
    private static final By FORGOT_PASSWORD =
            By.xpath("//*[@text='Forgot Password' or @text='Forgot password?' "
                   + "or contains(@text,'Forgot')]");
    private static final By SHOW_PASSWORD_TOGGLE =
            By.xpath("//*[@content-desc='toggle_password' or contains(@resource-id,'visibility')]");
    private static final By ERROR_MESSAGE =
            By.xpath("//*[contains(@text,'error') or contains(@text,'Error') "
                   + "or contains(@text,'invalid') or contains(@text,'wrong')]");
    private static final By LOADING_INDICATOR =
            By.xpath("//*[@content-desc='loading' or contains(@class,'ProgressBar')]");
    private static final By APP_LOGO =
            By.xpath("//*[@content-desc='app_logo' or contains(@resource-id,'logo')]");

    public LoginPage(AndroidDriver driver) {
        super(driver);
        log.info("LoginPage initialised");
    }

    // ─── Actions ──────────────────────────────────────────────

    /** Enter email address. */
    public LoginPage enterEmail(String email) {
        log.info("Entering email: {}", email);
        typeText(EMAIL_FIELD, email);
        return this;
    }

    /** Enter password. */
    public LoginPage enterPassword(String password) {
        log.info("Entering password: ****");
        typeText(PASSWORD_FIELD, password);
        return this;
    }

    /** Tap the Login button. */
    public void tapLogin() {
        log.info("Tapping Login button");
        hideKeyboard();
        tap(LOGIN_BUTTON);
    }

    /** Full login flow: enter email, password, and tap login. */
    public void login(String email, String password) {
        enterEmail(email).enterPassword(password);
        hideKeyboard();
        tapLogin();
    }

    /** Navigate to Register screen. */
    public void tapRegister() {
        log.info("Tapping Register link");
        tap(REGISTER_LINK);
    }

    /** Navigate to Forgot Password screen. */
    public void tapForgotPassword() {
        log.info("Tapping Forgot Password");
        tap(FORGOT_PASSWORD);
    }

    /** Toggle password visibility. */
    public void togglePasswordVisibility() {
        log.info("Toggling password visibility");
        tap(SHOW_PASSWORD_TOGGLE);
    }

    // ─── Queries ──────────────────────────────────────────────

    /** Check if email field is visible. */
    public boolean isEmailFieldVisible() {
        return isDisplayed(EMAIL_FIELD);
    }

    /** Check if password field is visible. */
    public boolean isPasswordFieldVisible() {
        return isDisplayed(PASSWORD_FIELD);
    }

    /** Check if login button is visible. */
    public boolean isLoginButtonVisible() {
        return isDisplayed(LOGIN_BUTTON);
    }

    /** Check if register link is visible. */
    public boolean isRegisterLinkVisible() {
        return isDisplayed(REGISTER_LINK);
    }

    /** Check if an error message is displayed. */
    public boolean isErrorMessageVisible() {
        return isDisplayed(ERROR_MESSAGE);
    }

    /** Get error message text. */
    public String getErrorMessage() {
        return getText(ERROR_MESSAGE);
    }

    /** Check if login button is enabled. */
    public boolean isLoginButtonEnabled() {
        return isEnabled(LOGIN_BUTTON);
    }

    /** Check if loading indicator is visible. */
    public boolean isLoading() {
        return isDisplayed(LOADING_INDICATOR);
    }

    /** Check if app logo is visible. */
    public boolean isAppLogoVisible() {
        return isDisplayed(APP_LOGO);
    }

    /** Wait for login to complete (loading disappears). */
    public void waitForLoginComplete() {
        log.info("Waiting for login completion...");
        sleep(5000); // Allow Firebase auth round-trip
    }

    /** Verify entire login page is loaded. */
    public boolean isLoginPageFullyLoaded() {
        sleep(3000);
        String source = getPageSource();
        return source != null && source.length() > 200;
    }
}
