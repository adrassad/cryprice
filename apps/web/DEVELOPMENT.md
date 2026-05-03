# Local development

## API base URLs (compile-time)

The app does not commit production API hosts. Pass at build time, for example:

- `CRYPRICE_BACKEND_BASE_URL` — prices API
- `AUTH_BACKEND_BASE_URL` — `/auth/*` (separate from prices; see `lib/core/config/auth_backend_config.dart`)

See [`.env.example`](.env.example) for a full list. If unset, both default to `http://127.0.0.1:3000` for local development.

## Web: Google Sign-In (OAuth 2.0)

The app reads the **Web** OAuth 2.0 client id at **compile time** via `--dart-define` (it is not hardcoded in source).

### 1. How `GOOGLE_WEB_CLIENT_ID` is passed

At build/run time, pass:

```text
--dart-define=GOOGLE_WEB_CLIENT_ID=<WEB_CLIENT_ID>.apps.googleusercontent.com
```

`flutter` injects that value into the Dart `String.fromEnvironment` API for the app binary you are running (debug `flutter run` or `flutter build web` with the same flags).

### 2. Where it is read in code

- **File:** `lib/features/auth/data/datasources/google_id_token_provider.dart`
- **Mechanism:** `const web = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');`
- On **web** (`kIsWeb`), a non-empty value is passed to `GoogleSignIn(clientId: web)` so Google Identity Services uses the correct client.

### 3. Client type: must be “Web application”

For **Flutter Web** you must create an OAuth 2.0 **Client ID** in [Google Cloud Console](https://console.cloud.google.com/apis/credentials) with type **Web application**.

- **Do not** use an Android, iOS, or Desktop OAuth client id as `GOOGLE_WEB_CLIENT_ID` for the browser build — Google will return errors such as `401: invalid_client` / “OAuth client was not found” for the wrong client type or a deleted/wrong id.

### 4. Google Cloud Console — Authorized JavaScript origins

For local development with a **fixed** port, add an origin that **exactly matches** the host and port where the app is served, for example:

- If you use `--web-port=5000`, add: **`http://localhost:5000`**
- If you use another port (e.g. `60434`), add **`http://localhost:60434`** instead. The origin and the port in your `flutter run` command must match.

You may add multiple origins (e.g. both `http://localhost:5000` and `http://127.0.0.1:5000` if you open the app via `127.0.0.1`).

### 5. Local run command (example)

```bash
flutter run -d chrome --web-port=5000 --dart-define=GOOGLE_WEB_CLIENT_ID=<WEB_CLIENT_ID>.apps.googleusercontent.com
```

Replace `<WEB_CLIENT_ID>.apps.googleusercontent.com` with the full **Client ID** string from the **Web application** client (not a client secret; the id is safe to pass via `--dart-define` locally, but do not commit secrets).

### 6. `401: invalid_client` / “The OAuth client was not found”

Typical causes:

- Client id is not a **Web application** type, or is mistyped, or was deleted in Google Cloud.
- **Authorized JavaScript origins** does not include the origin you are actually using (wrong port or `http` vs `https`).
- A placeholder or copy-paste error in `--dart-define` (must be the full `xxx-yyy.apps.googleusercontent.com` string from Credentials).

Troubleshooting: confirm the id in the Cloud Console, fix origins to match the exact URL in the browser address bar, and restart `flutter run` with the same `--dart-define` value.

---

No backend or repository configuration is required for the **Google** client id itself; the backend expects the **ID token** after sign-in, which is a separate step.
