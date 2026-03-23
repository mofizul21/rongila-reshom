# 🔒 Security Alert - Firebase API Key Exposed

## ⚠️ Immediate Action Required

Your Firebase API key was exposed on GitHub. Follow these steps immediately:

## Step 1: Regenerate Firebase API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: **Rongila Reshom**
3. Navigate to: **APIs & Services** → **Credentials**
4. Find the compromised key: `AIzaSyAanhQwaNSPPse1yO4hLB8PuKfjF6jqwZ0`
5. Click **Edit** (pencil icon)
6. Click **Regenerate Key**
7. Copy the new key
8. Click **Save**

## Step 2: Remove from GitHub History

```bash
# Navigate to your project
cd /Users/mofizulislam/Sites/flutter-app/rongilareshom

# Remove firebase_options.dart from git (but keep locally)
git rm --cached lib/firebase_options.dart

# Commit the removal
git commit -m "security: Remove sensitive Firebase config from Git"

# Force push to remove from GitHub history
git push origin main --force
```

## Step 3: Update Firebase Configuration

After regenerating the key, update your Firebase setup:

### Option A: Use Firebase CLI (Recommended)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Reconfigure Firebase with new project
flutterfire configure

# This will regenerate lib/firebase_options.dart
# DO NOT commit this file to Git!
```

### Option B: Manual Configuration

1. Download the new `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase Console
2. Replace the old files in your project
3. Update `lib/firebase_options.dart` with new credentials
4. **Do NOT commit `lib/firebase_options.dart` to Git**

## Step 4: Add API Key Restrictions (Optional but Recommended)

1. In Google Cloud Console → APIs & Services → Credentials
2. Edit your API key
3. Under **Application restrictions**:
   - Select **Android apps** (for Android)
   - Select **iOS apps** (for iOS)
   - Or select **HTTP referrers** (for web)
4. Under **API restrictions**:
   - Select **Restrict key**
   - Enable only required APIs:
     - Firebase Cloud Messaging API
     - Cloud Firestore API
     - Firebase Auth API
5. Click **Save**

## Step 5: Monitor for Abuse

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to: **Monitoring** → **Logging** → **Logs Explorer**
3. Filter for unusual activity
4. Check **Billing** for unexpected charges

## Step 6: Update .gitignore (Already Done)

The following files are now ignored:
- ✅ `lib/firebase_options.dart`
- ✅ `.env`
- ✅ `.env.local`

## Prevention for Future

### Never Commit Sensitive Files

```bash
# Always check before committing
git status

# Review what will be committed
git diff --cached
```

### Use Environment Variables

For web apps, consider using environment variables:

```dart
// lib/services/firebase_options_secure.dart
class FirebaseOptionsConfig {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  // ... etc
}
```

### Use Secret Management Services

For production apps, use:
- **Google Secret Manager**
- **AWS Secrets Manager**
- **Azure Key Vault**

## Checklist

- [ ] Regenerated Firebase API key
- [ ] Removed `firebase_options.dart` from Git
- [ ] Force pushed to GitHub
- [ ] Added API key restrictions
- [ ] Monitored for suspicious activity
- [ ] Updated team members about the security issue

## Need Help?

- [Firebase Security Best Practices](https://firebase.google.com/docs/projects/api-keys)
- [Google Cloud Security](https://cloud.google.com/security)
- [GitHub Security](https://docs.github.com/en/security)

---

**Remember:** API keys in client-side apps (Flutter, React Native, etc.) are always visible to users. The real security comes from:
1. **Firebase Security Rules** (for Firestore)
2. **API Key Restrictions** (limit where the key can be used)
3. **Proper Authentication** (verify users before granting access)
4. **Monitoring** (watch for unusual activity)
