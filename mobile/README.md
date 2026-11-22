# Bazarino Flutter app

Expo / React Native has been removed. The mobile client is Flutter (Dart), targeting Android and iOS from one codebase.

## Run locally
```bash
flutter pub get
flutter run --dart-define=BAZARINO_API_URL=http://10.0.2.2:3000/api/v1
```

For a physical Android phone, replace the emulator host with the reachable API server address.
The app includes a Persian RTL starter interface and a live API health check. Marketplace data, authentication and transactions must be connected to implemented backend endpoints before they are represented as live features.
