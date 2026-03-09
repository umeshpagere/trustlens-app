# Technical Specification: TrustLens Mobile App

## Technical Context
- **Framework**: Flutter (Dart)
- **Target Platforms**: Android, iOS
- **Backend**: Flask REST API (Existing)
- **Key Plugin**: `receive_sharing_intent` for system Share Sheet integration

## Implementation Approach

### 1. Mobile App Architecture
The app follows a layered architecture:
- **Presentation Layer**: Flutter Widgets (Screens and reusable Components).
- **Service Layer**: Handles API communication (`ApiService`) and Share Intent management (`ShareIntentService`).
- **Data Layer**: Models for API requests and responses (`AnalysisResponse`, `SharedContent`).

### 2. Share Sheet / Share Intent Handling
#### Android
- Uses `intent-filter` in `AndroidManifest.xml` to register for `SEND` and `SEND_MULTIPLE` actions with `text/plain` and `image/*` mime types.
- `receive_sharing_intent` plugin listens for these intents and provides the data to the Flutter app.

#### iOS
- Implements a **Share Extension** target.
- Uses `RSIShareViewController` from `receive_sharing_intent` to handle incoming content and redirect to the main app.
- Requires a **URL Scheme** in the main app's `Info.plist` to allow the extension to open the app.

### 3. Data Flow
1. **User Action**: User clicks "Share" in an external app and selects "TrustLens".
2. **Platform Handling**:
   - **Android**: OS opens the `MainActivity`.
   - **iOS**: OS opens the `ShareExtension`, which redirects to the main app using the URL scheme.
3. **Flutter Extraction**: `ShareIntentService` detects the shared content (text, URL, or image path).
4. **Immediate Analysis**: `AnalysisScreen` is pushed. It extracts the text/imageUrl and calls the backend `POST /api/analyze`.
5. **UI Update**: `AnalysisScreen` shows a loading state, then displays the score gauge, risk level, and explanation in a bottom-sheet-style UI.
6. **Detailed Analysis**: User clicks "Learn More" to see a full breakdown in `DetailedAnalysisScreen`.

### 4. UX Mapping
| Extension Component | Mobile App Equivalent |
|---------------------|----------------------|
| Shadow DOM Overlay  | `AnalysisScreen` (Bottom-sheet style) |
| Score Gauge (SVG)   | `CredibilityGauge` (CustomPaint) |
| Risk Pill           | `RiskPill` Widget |
| "Learn More" Modal  | `DetailedAnalysisScreen` (Full screen) |

## Source Code Structure
- `lib/main.dart`: App entry point and Share Sheet listener setup.
- `lib/services/share_intent_service.dart`: Unified handler for shared content.
- `lib/services/api_service.dart`: REST client for TrustLens backend.
- `lib/models/analysis_result.dart`: Data models for analysis results.
- `lib/screens/analysis_screen.dart`: Quick results popup/bottom-sheet.
- `lib/screens/detailed_analysis_screen.dart`: Deep dive analysis screen.
- `lib/widgets/analysis_widgets.dart`: Reusable UI components (Gauge, Pill, Card).
- `lib/theme/app_theme.dart`: Design system (colors, typography).

## Interface Changes
- No changes to the backend API are required.
- The mobile app replicates the `POST /api/analyze` request structure: `{ "text": string, "imageUrl": string }`.

## Verification Approach
- **Linting**: Run `flutter analyze` in the `mobile/` directory.
- **Testing**: Manual verification using Android Emulator and iOS Simulator sharing mechanisms.
- **Backend Sync**: Ensure the mobile app correctly handles all response fields (risk levels, scores, AI explanations).
