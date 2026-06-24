---
          
## 📱 APPIUM E2E TEST CASES (480 Tests)

### 🔐 Authentication Tests (40)
<details><summary>Click to view 40 Appium auth test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_AUTH_001 | App launches successfully to welcome screen |
| 2 | AP_AUTH_002 | App logo is visible on startup |
| 3 | AP_AUTH_003 | Login button is enabled |
| 4 | AP_AUTH_004 | Login screen fields are focusable |
| 5 | AP_AUTH_005 | Password field hides characters |
| 6 | AP_AUTH_006 | Login fails with empty fields |
| 7 | AP_AUTH_007 | Keyboard opens on email field tap |
| 8 | AP_AUTH_008 | Keyboard type is email for email field |
| 9 | AP_AUTH_009 | Invalid email format shows inline error |
| 10 | AP_AUTH_010 | Wrong password shows snackbar error |
| 11 | AP_AUTH_011 | Successful login navigates to dashboard |
| 12 | AP_AUTH_012 | Session persists after app kill and restart |
| 13 | AP_AUTH_013 | Registration screen reachable from login |
| 14 | AP_AUTH_014 | Registration fields accept valid input |
| 15 | AP_AUTH_015 | Weak password rejected during registration |
| 16 | AP_AUTH_016 | Successful registration logs user in |
| 17 | AP_AUTH_017 | Biometric prompt shown on supported devices |
| 18 | AP_AUTH_018 | Biometric login succeeds |
| 19 | AP_AUTH_019 | Biometric login fails with wrong print |
| 20 | AP_AUTH_020 | Logout returns user to login screen |
| 21–40 | AP_AUTH_021-040 | Various edge cases and UI state validations for Auth flow |
</details>

### 🛡️ Authorization Tests (30)
<details><summary>Click to view 30 Appium authz test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_AUTHZ_001 | Unauthenticated user cannot access dashboard |
| 2 | AP_AUTHZ_002 | Back button from login does not bypass auth |
| 3 | AP_AUTHZ_003 | Deep link requires login |
| 4 | AP_AUTHZ_004 | Admin view hidden for normal users |
| 5 | AP_AUTHZ_005 | PIN required to send money |
| 6 | AP_AUTHZ_006 | PIN required for bank transfer |
| 7 | AP_AUTHZ_007 | Biometric fallback to PIN |
| 8–30 | AP_AUTHZ_008-030 | Permission and role checks |
</details>

### 🧭 Navigation Tests (30)
<details><summary>Click to view 30 Appium navigation test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_NAV_001 | Bottom nav bar functional |
| 2 | AP_NAV_002 | Navigate to Profile via bottom nav |
| 3 | AP_NAV_003 | Navigate to QR Scanner |
| 4 | AP_NAV_004 | Native back button works as expected |
| 5 | AP_NAV_005 | App bar back button works |
| 6 | AP_NAV_006 | Drawer menu opens via hamburger icon |
| 7 | AP_NAV_007 | Drawer menu closes on outside tap |
| 8–30 | AP_NAV_008-030 | Navigation state and stack tests |
</details>

### 🎨 UI Validation Tests (40)
<details><summary>Click to view 40 Appium UI test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_UI_001 | Dashboard loads without UI clipping |
| 2 | AP_UI_002 | Wallet card scales correctly |
| 3 | AP_UI_003 | Text is readable with system font scaled up |
| 4 | AP_UI_004 | Dark mode applies correct colors |
| 5 | AP_UI_005 | Snackbars show at bottom |
| 6 | AP_UI_006 | Loading indicators visible |
| 7 | AP_UI_007 | Screen rotation supported (if enabled) |
| 8–40 | AP_UI_008-040 | Layout, contrast, element visibility |
</details>

### 📝 Forms Tests (40)
<details><summary>Click to view 40 Appium form test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_FORM_001 | Send Money form accepts amount |
| 2 | AP_FORM_002 | Send Money keyboard is numeric |
| 3 | AP_FORM_003 | Form scrolls when keyboard opens |
| 4 | AP_FORM_004 | Clear button removes input |
| 5 | AP_FORM_005 | Profile edit saves changes |
| 6–40 | AP_FORM_006-040 | Various form field validations |
</details>

### 🗄️ CRUD Tests (40)
<details><summary>Click to view 40 Appium CRUD test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_CRUD_001 | Refresh dashboard updates balance |
| 2 | AP_CRUD_002 | View transaction details |
| 3 | AP_CRUD_003 | Add bank account |
| 4 | AP_CRUD_004 | Remove bank account |
| 5 | AP_CRUD_005 | Mark notification read |
| 6–40 | AP_CRUD_006-040 | Data persistence verification |
</details>

### ✏️ Input Validation Tests (40)
<details><summary>Click to view 40 Appium input test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_INP_001 | Cannot enter negative amount |
| 2 | AP_INP_002 | Paste blocked on PIN field |
| 3 | AP_INP_003 | Phone field limits to 10 chars |
| 4–40 | AP_INP_004-040 | Input restrictions and sanitization |
</details>

### ⚠️ Error Handling Tests (30)
<details><summary>Click to view 30 Appium error test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_ERR_001 | Offline message shown when airplane mode on |
| 2 | AP_ERR_002 | Retry button works when connection restored |
| 3 | AP_ERR_003 | Insufficient balance shows modal |
| 4–30 | AP_ERR_004-030 | Native API/network error states |
</details>

### ♿ Accessibility Tests (20)
<details><summary>Click to view 20 Appium accessibility test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_A11Y_001 | TalkBack reads balance card correctly |
| 2 | AP_A11Y_002 | TalkBack focus order follows visual layout |
| 3 | AP_A11Y_003 | Buttons have content descriptions |
| 4–20 | AP_A11Y_004-020 | VoiceOver/TalkBack compatibility |
</details>

### ⚡ Performance Smoke Tests (20)
<details><summary>Click to view 20 Appium performance test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_PERF_001 | App cold start < 3 seconds |
| 2 | AP_PERF_002 | Scrolling transaction list is smooth (60fps) |
| 3 | AP_PERF_003 | Screen transition < 500ms |
| 4–20 | AP_PERF_004-020 | Memory/CPU usage checks |
</details>

### 🔁 Regression Tests (100)
<details><summary>Click to view 100 Appium regression test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | AP_REG_001 | E2E Payment flow (Send Money via Contact) |
| 2 | AP_REG_002 | E2E QR Payment flow |
| 3 | AP_REG_003 | E2E Bank Transfer flow |
| 4 | AP_REG_004 | Add Money via Razorpay |
| 5 | AP_REG_005 | Notification to Transaction detail deep link |
| 6–100 | AP_REG_006-100 | Comprehensive user journeys and flows |
</details>
