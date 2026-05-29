# Setup Guide - GamersBox

## ⚠️ Critical Files to Configure (Not in Git)

The following sensitive files are **NOT included in the repository** and must be created locally to run the app:

### 1. **Firebase Configuration** (REQUIRED)
**File:** `lib/core/firebase_options.dart`

This file contains your Firebase API keys and must NOT be committed to version control.

**Setup Steps:**
1. Copy the template: `lib/core/firebase_options.example.dart` → `lib/core/firebase_options.dart`
2. Get your Firebase credentials:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project or create one
   - Navigate to Project Settings → Your apps
   - Copy your API keys and configuration

3. Update `firebase_options.dart` with your actual credentials:
   - `apiKey`: Your Firebase API Key
   - `projectId`: Your Firebase Project ID
   - `databaseURL`: Your Realtime Database URL
   - `storageBucket`: Your Storage Bucket URL
   - `appId`: Your App ID
   - `messagingSenderId`: Your Messaging Sender ID

### 2. **Other Configuration Files** (If Used)
- `lib/**/*_config.dart` - Custom configuration files
- `lib/**/*_secrets.dart` - Secret keys or tokens
- `lib/**/*.env` - Environment variables
- `lib/constants/api_keys.dart` - API keys

## Initial Setup

```bash
# 1. Clone the repository
git clone <repository-url>
cd games

# 2. Install Flutter dependencies
flutter pub get

# 3. Create firebase_options.dart from example
cp lib/core/firebase_options.example.dart lib/core/firebase_options.dart

# 4. Update firebase_options.dart with your credentials (IMPORTANT!)

# 5. Run the app
flutter run
```

## Important Notes

🔒 **Security:**
- NEVER commit files containing API keys or credentials
- NEVER push `firebase_options.dart` to GitHub
- NEVER share your Firebase credentials

✅ **Verification:**
- The `firebase_options.dart` file is in `.gitignore`
- Your credentials are never tracked by Git
- Each developer/environment has their own configuration

## Troubleshooting

**Error: "Firebase not initialized"**
- Ensure `firebase_options.dart` exists and has valid credentials

**Error: "Cannot access Firestore/Realtime Database"**
- Check your Firebase project has the correct databases enabled
- Verify Firestore/Realtime Database rules allow access

## Environment-Specific Setup

For different environments (development, staging, production):
1. Create separate Firebase projects
2. Create corresponding `firebase_options_[env].dart` files
3. Add them all to `.gitignore`
4. Update `lib/core/init_user.dart` to load the correct configuration based on build flavor

---

**Last Updated:** 2026-05-29
**Author:** Saksham Nirula
