# Google Sign-In Setup (Native, no browser / webview)

This app uses `google_sign_in: ^7.2.0` for native Google Sign-In and
passes the obtained ID token to Supabase via `signInWithIdToken()`,
completely avoiding any browser or webview flow.

---

## 1. Google Cloud Console

Create a project (or use an existing one) at
https://console.cloud.google.com/apis/credentials.

You need **three** OAuth 2.0 Client IDs under the same project:

| Type           | Purpose                                              |
| -------------- | ---------------------------------------------------- |
| **Web**        | `serverClientId` passed to `GoogleSignIn.initialize()` |
| **Android**    | Used by Google Play Services on Android              |
| **iOS**        | Used by Google Sign-In SDK on iOS                    |

### Web client ID (required)

This is the **serverClientId** value. Supabase uses it to verify the
ID token on the server side, regardless of platform.

### Android client ID (required for Android builds)

Google Sign-In v7 on Android uses the Credential Manager API, which
requires the Android client ID. You have two options:

**Option A — Set in `.env` (recommended)**

Add your Android client ID to `.env`:
```
GOOGLE_ANDROID_CLIENT_ID=XXXXXXXXXXXX-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
```

**Option B — `google-services.json`**

1. Get your app's SHA-1 fingerprint:
   ```sh
   cd android && ./gradlew signingReport
   ```
2. Add it to the Android OAuth client in Google Cloud Console.
3. Download `google-services.json` and place it at:
   ```
   android/app/google-services.json
   ```
4. Make sure `android/build.gradle` includes the Google Services plugin.

Without either option, `authenticate()` will return a `canceled` exception
because the Credential Manager has no valid client ID to use.

### iOS client ID (required for iOS builds)

1. Create an iOS OAuth client in Google Cloud Console (bundle ID match).
2. Add the **reversed client ID** as a URL scheme in `Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.XXXXXXXXXXXXX</string>
       </array>
     </dict>
   </array>
   ```
3. (Optional) `GoogleService-Info.plist` is only needed if using Firebase
   tooling. The `google_sign_in` package works without it.

---

## 2. Credentials already exist

The project owner has confirmed these credentials already exist in the
Google Cloud Console. Insert the Web and Android client IDs in `.env`:

```
GOOGLE_SERVER_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=your-android-client-id.apps.googleusercontent.com
```

If you only have the Web client ID configured in Supabase and want to
skip passing the Android client ID, you can add `google-services.json`
to `android/app/` instead (see section 1).

---

## 3. How it works (no browser / webview)

```
User taps "Continue with Google"
  → GoogleSignIn.instance.authenticate()  # native modal (Credential Manager)
  → account.authentication                # idToken
  → supabase.auth.signInWithIdToken()     # no browser involved
```

This is the key architectural choice: `signInWithIdToken` exchanges a
natively-obtained Google ID token directly with Supabase's Auth API,
unlike `supabase.auth.signInWithOAuth()` which always opens a browser /
webview / Custom Tab.

---

## 4. Troubleshooting

- **"10" developer error on Android**: SHA-1 fingerprint missing from
  Google Cloud Console.
- **idToken is null**: The OAuth client for the platform may not have
  the correct bundle ID / package name.
- **"invalid id_token" from Supabase**: The `serverClientId` must match
  the Web client ID exactly — not the Android or iOS client ID.
