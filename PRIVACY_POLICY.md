# Privacy Policy for V-sync

**Last Updated: April 21, 2026**

V-sync ("the App") is an open-source companion application designed specifically for students of VIT-AP University. This Privacy Policy explains how we handle your information when you use our services, particularly our integration with Google OAuth and the VTOP portal.

## 1. Information We Collect

### VTOP Credentials
To access your academic data, V-sync requires your VTOP registration number and password. 
*   **Storage**: These credentials are stored **exclusively on your local device** using secure storage. 
*   **Transmission**: They are only transmitted directly to the official VIT-AP VTOP servers to facilitate login. We do not have any middle-man servers; your data never reaches us or any third party.

### Google Account Data (Gmail)
V-sync requests **read-only access** to your Gmail messages (`gmail.readonly` scope).
*   **Purpose**: This permission is used solely to find and extract the VTOP Login OTP (One-Time Password) sent by `info1@vitap.ac.in`. 
*   **Processing**: The app scans for emails with the subject "VTOP Login OTP Needed" that were received within the last 3 minutes.
*   **Storage**: The content of your emails is **never stored, uploaded, or shared**. The OTP is processed locally and discarded immediately after being used for login.

## 2. No External Data Sharing
V-sync is built with a "Local First" philosophy.
*   We do not use any tracking, analytics, or external databases to store your personal information.
*   We do not share any data with third parties, including Google or VIT-AP University, other than what is necessary for the native authentication flows you initiate.

## 3. Open Source Transparency
V-sync is open-source. Any user can inspect the code to verify that their data is handled according to this policy. You can review the source code at: [https://github.com/sumitkumards07/V-sync](https://github.com/sumitkumards07/V-sync).

## 4. Third Party Services
*   **Google OAuth**: We use Google's official Sign-In service. Use of this service is subject to [Google's Privacy Policy](https://policies.google.com/privacy).
*   **VTOP**: Academic data is fetched from the VIT-AP VTOP portal.

## 5. Contact
If you have any questions regarding this Privacy Policy, please contact the developer via the GitHub repository issues.
