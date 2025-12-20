# How to Ship to TestFlight

This guide covers the steps to deploy the first version of **Tigidou** (`com.yannickkoehler.tigidou`) to TestFlight.

## Prerequisites
1. **Apple Developer Account**: You must be enrolled in the [Apple Developer Program](https://developer.apple.com/programs/).
2. **Transporter App**: Download from the Mac App Store (easiest way to upload) OR have Xcode installed.

## Step 1: Apple Developer Portal
1. Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list).
2. Click **+** to create a new **App ID**.
3. Select **App**, then **Continue**.
4. Description: `Tigidou`
5. Bundle ID: `com.yannickkoehler.tigidou` (Explicit)
6. Click **Continue** and **Register**.

## Step 2: App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com/).
2. Click **My Apps** -> **+** -> **New App**.
3. Platform: **iOS**.
4. Name: **Tigidou** (if taken, try `Tigidou App` or similar).
5. Primary Language: **English** (or French).
6. Bundle ID: Select `com.yannickkoehler.tigidou`.
7. SKU: `tigidou_ios` (or any unique string).
8. Click **Create**.

## Step 3: Configure Signing (Local)
1. Open the project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Select **Runner** (top left).
3. Select the **Signing & Capabilities** tab.
4. Under **Team**, select your Apple Developer Team.
   - If none listed, log in via **Xcode -> Settings -> Accounts**.
5. Ensure **Bundle Identifier** is `com.yannickkoehler.tigidou`.

## Step 4: Build the Archive
1. In your terminal (root of project):
   ```bash
   flutter build ipa
   ```
   *This performs a release build and creates an `.ipa` file.*

2. Locate the output file:
   `build/ios/ipa/tigidou.ipa`

## Step 5: Upload to TestFlight
**Option A: Using Transporter (Recommended)**
1. Open **Transporter** app.
2. Drag and drop the `build/ios/ipa/tigidou.ipa` file into the window.
3. Click **Deliver**.

**Option B: Using Xcode**
1. In Xcode, go to **Product** -> **Archive** (if you didn't use `flutter build ipa`).
   *Note: `flutter build ipa` is generally preferred for Flutter apps.*
2. Use **Window** -> **Organizer** to see archives.
3. Click **Distribute App** -> **TestFlight & App Store** -> **Upload**.

## Step 6: Release to Testers
1. Go back to **App Store Connect**.
2. Click on **TestFlight** tab.
3. You should see the build processing (takes a few minutes).
4. Once processed, you might need to answer compliance questions (encryption).
   - If you use standard HTTPS only, usually "Yes" -> "Yes" is fine (standard encryption).
5. Add **Internal Testing** group and add yourself/team.

## Common Issues
- **Version Cleanliness**: Ensure you commit all changes before building (`git commit`) to ensure the build metadata is clean.
- **Build Number**: Update `version: 1.0.0+1` in `pubspec.yaml` for subsequent builds (e.g., `1.0.0+2`).
