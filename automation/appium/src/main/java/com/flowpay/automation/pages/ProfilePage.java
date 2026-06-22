package com.flowpay.automation.pages;

import io.appium.java_client.android.AndroidDriver;
import org.openqa.selenium.By;

/**
 * FlowPay Appium — Profile Page Object
 * Encapsulates profile, settings, and account interactions.
 */
public class ProfilePage extends BasePage {

    private static final By USER_NAME =
            By.xpath("//*[@content-desc='user_name' or contains(@resource-id,'name')]");
    private static final By USER_EMAIL =
            By.xpath("//*[@content-desc='user_email' or contains(@resource-id,'email')]");
    private static final By EDIT_PROFILE_BTN =
            By.xpath("//*[@content-desc='edit_profile' or @text='Edit Profile' or @text='Edit']");
    private static final By SECURITY_CENTER =
            By.xpath("//*[@text='Security Center' or @text='Security']");
    private static final By HELP_SUPPORT =
            By.xpath("//*[@text='Help & Support' or @text='Help']");
    private static final By BANK_ACCOUNTS =
            By.xpath("//*[@text='Bank Accounts' or @text='Linked Banks']");
    private static final By LOGOUT_BUTTON =
            By.xpath("//*[@content-desc='logout' or @text='Logout' or @text='Sign Out']");
    private static final By THEME_TOGGLE =
            By.xpath("//*[@content-desc='theme_toggle' or contains(@text,'Dark') "
                   + "or contains(@text,'Theme')]");
    private static final By VERSION_TEXT =
            By.xpath("//*[contains(@text,'Version') or contains(@text,'v1.')]");
    private static final By PROFILE_PICTURE =
            By.xpath("//*[@content-desc='profile_picture' or contains(@resource-id,'avatar')]");

    public ProfilePage(AndroidDriver driver) {
        super(driver);
        log.info("ProfilePage initialised");
    }

    // ─── Actions ──────────────────────────────────────────────

    public void tapEditProfile()    { tap(EDIT_PROFILE_BTN); }
    public void tapSecurityCenter() { tap(SECURITY_CENTER); }
    public void tapHelpSupport()    { tap(HELP_SUPPORT); }
    public void tapBankAccounts()   { tap(BANK_ACCOUNTS); }
    public void tapLogout()         { log.info("Tapping Logout"); tap(LOGOUT_BUTTON); }
    public void tapThemeToggle()    { tap(THEME_TOGGLE); }

    // ─── Queries ──────────────────────────────────────────────

    public String  getUserName()        { return getText(USER_NAME); }
    public String  getUserEmail()       { return getText(USER_EMAIL); }
    public boolean isEditButtonVisible(){ return isDisplayed(EDIT_PROFILE_BTN); }
    public boolean isLogoutVisible()    { return isDisplayed(LOGOUT_BUTTON); }
    public boolean isVersionVisible()   { return isDisplayed(VERSION_TEXT); }
    public String  getVersionText()     { return getText(VERSION_TEXT); }
    public boolean isProfilePicVisible(){ return isDisplayed(PROFILE_PICTURE); }

    public boolean isProfilePageLoaded() {
        sleep(3000);
        return getPageSource() != null && getPageSource().length() > 200;
    }
}
