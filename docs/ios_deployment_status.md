# iOS App Store Deployment Status

This document tracks the requirements and current status for deploying **Tigidou** to the Apple App Store.

## 🚀 Quick Status
- **Bundle ID:** `com.yannickkoehler.tigidou`
- **Current Version:** `1.0.0+1`
- **Development Account:** 🔴 Pending
- **App Store Connect:** 🔴 Pending
- **Code Signing:** 🟡 In Progress (Codemagic CLI tools integrated)

---

## 📋 Requirements Checklist

### 1. Apple Developer & Admin
| Requirement | Status | Note |
| :--- | :---: | :--- |
| Apple Developer Program Membership | 🔴 | $99 USD/year required. |
| App Store Connect Account | 🔴 | Created after joining Developer Program. |
| App Record in App Store Connect | 🔴 | Define app name, primary language, etc. |

### 2. Assets & Branding
| Requirement | Status | Note |
| :--- | :---: | :--- |
| App Icon (1024x1024) | ✅ | Configured and verified using `flutter_launcher_icons`. |
| Splash Screen | ✅ | Configured and verified using `flutter_native_splash`. |
| Screenshots (iPhone 6.7" & 6.5") | 🔴 | Required for submission. |
| Screenshots (iPad 12.9") | 🔴 | Required if iPad support is enabled. |

### 3. Legal & Privacy
| Requirement | Status | Note |
| :--- | :---: | :--- |
| Privacy Policy URL | 🔴 | Required for all apps. |
| Support URL | 🔴 | Required for all apps. |
| Data Safety Disclosure | 🔴 | Form to fill in App Store Connect. |

### 4. Technical Configuration
| Requirement | Status | Note |
| :--- | :---: | :--- |
| Bundle Identifier | ✅ | `com.yannickkoehler.tigidou` |
| App Version / Build Number | ✅ | Currently `1.0.0+1`. |
| Permissions (Info.plist) | ✅ | `NSUserNotificationsUsageDescription` and Biometric permissions added. |
| Background Modes | ✅ | `fetch` and `remote-notification` added. |
| "Sign in with Apple" | N/A | Not required (using email/password + biometrics). |

### 5. Deployment & CI/CD
| Requirement | Status | Note |
| :--- | :---: | :--- |
| Distribution Certificate | 🔴 | Created in Apple Developer portal. |
| Provisioning Profile | 🔴 | Created in Apple Developer portal. |
| GitHub Actions Secrets | ✅ | Configured using `gh cli` and `codemagic-cli-tools` approach. |

---

## 🛠 Next Steps

1.  **Enroll in Apple Developer Program:** This is the primary blocker for any actual deployment.
2.  **Create App Record:** Register the app in App Store Connect with the Bundle ID `com.yannickkoehler.tigidou`.
3.  **Prepare Marketing Assets:**
    - Draft a Privacy Policy.
    - Generate final screenshots using simulators or physical devices.
4.  **Configure Code Signing:** Set up certificates and provisioning profiles for the App Store.
5.  **Submit for Review:** Once all metadata is filled and a build is uploaded via GitHub Actions or Xcode.
