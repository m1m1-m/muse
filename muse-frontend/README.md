# MUSE – Smart Wardrobe Management and Outfit Recommendation System

## Frontend

This folder contains the Flutter frontend for **MUSE**, a Smart Wardrobe Management and Outfit Recommendation System.

The frontend provides the mobile user interface and communicates with the MUSE backend through REST APIs. Firebase Authentication and Firebase Storage are also integrated into the Flutter application.

---

## My Contribution

**Role:** Frontend Development  
**Technology:** Flutter + Dart

I developed and integrated the mobile frontend for the MUSE application.

### Frontend responsibilities completed

- Developed the Flutter mobile application structure and navigation.
- Implemented Firebase Authentication integration for user registration, login and logout.
- Connected the frontend to the MUSE REST API.
- Implemented authenticated API requests using Firebase ID tokens.
- Developed the Wardrobe interface.
- Implemented adding wardrobe items.
- Implemented wardrobe item fields including:
  - Item name
  - Category
  - Color
  - Season
  - Notes
- Implemented wardrobe image selection using the device gallery.
- Integrated Firebase Storage for wardrobe image uploads.
- Connected uploaded image paths with wardrobe items.
- Developed the Outfit interface and Add Outfit functionality.
- Integrated outfit creation with wardrobe item IDs.
- Developed the Planner interface.
- Integrated planner API operations for assigning outfits to dates.
- Developed the Packing List interface.
- Implemented packing list creation, viewing and item check/uncheck functionality.
- Integrated packing list API operations.
- Developed the Recommendations interface.
- Integrated recommendation API requests.
- Added Firebase Emulator support for local development and testing.
- Configured Android emulator connectivity to the local Firebase and backend services.
- Configured Android cleartext HTTP access for local API development.

---

## Technology Stack

| Area | Technology |
|---|---|
| Frontend | Flutter |
| Programming Language | Dart |
| Authentication | Firebase Authentication |
| Image Storage | Firebase Storage |
| Backend Communication | REST API |
| HTTP Client | Dart `http` package |
| Image Selection | `image_picker` |
| State / Dependency Support | `provider` |
| Backend | Firebase Cloud Functions |
| Database | Cloud Firestore |
| API Documentation | OpenAPI / Swagger |
| Development Testing | Firebase Emulator Suite |
| Android Testing | Android Emulator |

---

## Main Flutter Dependencies

The frontend uses the following packages:

```yaml
firebase_core
firebase_auth
firebase_storage
image_picker
provider
http
```

Run the following command to install dependencies:

```bash
flutter pub get
```

---

## Project Structure

```text
muse-frontend/
│
├── android/
│   └── Android-specific configuration
│
├── lib/
│   ├── main.dart
│   │
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── wardrobe_screen.dart
│   │   ├── add_wardrobe_screen.dart
│   │   ├── outfits_screen.dart
│   │   ├── add_outfit_screen.dart
│   │   ├── planner_screen.dart
│   │   ├── packing_screen.dart
│   │   ├── packing_details_screen.dart
│   │   └── recommendations_screen.dart
│   │
│   └── services/
│       ├── auth_service.dart
│       ├── api_service.dart
│       └── storage_service.dart
│
├── test/
│
├── pubspec.yaml
└── README.md
```

---

## Requirements

### Software

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Android Emulator
- Firebase CLI
- Node.js

### Recommended versions used during development

```text
Flutter: 3.47.5
Dart: 3.13.4
Node.js: 22
```

The project was tested using an Android emulator.

---

## Running the Frontend

### 1. Install Flutter dependencies

From the frontend directory:

```bash
flutter pub get
```

### 2. Start the MUSE backend

The backend is maintained separately in:

```text
muse-backend/
```

Start the Firebase emulators from the backend directory using the project's Firebase configuration.

The local services used during development include:

```text
Firebase Authentication: 9099
Cloud Functions: 5001
Firestore: 8080
Firebase Storage: 9199
Firebase Emulator UI: 4000
```

### 3. Start an Android emulator

Make sure an Android emulator is running.

The frontend was tested on:

```text
emulator-5556
```

### 4. Run the Flutter application

```bash
flutter run -d emulator-5556
```

---

## Local Emulator Configuration

During local development, the Android emulator accesses services running on the host machine using:

```text
10.0.2.2
```

Therefore, the frontend uses local emulator endpoints such as:

```text
Firebase Auth:
10.0.2.2:9099

Firebase Storage:
10.0.2.2:9199

MUSE API:
10.0.2.2:5001
```

`10.0.2.2` is the Android Emulator's special address for accessing the host computer.

---

## API Integration

The frontend communicates with the backend through the MUSE REST API.

The API base URL used for Android emulator development is:

```text
http://10.0.2.2:5001/muse-35420/asia-south1/api
```

Authenticated requests include the Firebase ID token:

```text
Authorization: Bearer <Firebase ID Token>
```

The main API areas integrated into the frontend are:

- Wardrobe
- Outfits
- Planner
- Packing Lists
- Recommendations

---

## Authentication Flow

The frontend uses Firebase Authentication.

Basic flow:

```text
User
  ↓
Flutter Login / Register Screen
  ↓
Firebase Authentication
  ↓
Authenticated Firebase User
  ↓
Firebase ID Token
  ↓
REST API Request
  ↓
MUSE Backend
```

The Firebase ID token is automatically included in authenticated API requests.

---

## Wardrobe Image Flow

When a user adds a wardrobe item with an image:

```text
Select Image
      ↓
Create Wardrobe Item through API
      ↓
Receive Wardrobe Item ID
      ↓
Upload Image to Firebase Storage
      ↓
Save Storage Path to Wardrobe Item
```

Images are stored using the following structure:

```text
users/{uid}/wardrobe/{itemId}/image.jpg
```

---

## Features Integrated

### Authentication

- Register
- Login
- Logout

### Wardrobe

- View wardrobe
- Add wardrobe item
- Select wardrobe image
- Upload wardrobe image
- Store wardrobe image path

### Outfits

- View outfits
- Create outfits
- Select wardrobe items for outfits

### Planner

- View planned outfits
- Assign outfits to dates
- Update planner entries
- Delete planner entries

### Packing

- Create packing lists
- View packing lists
- View packing list details
- Mark items as packed/unpacked
- Delete packing lists

### Recommendations

- Request outfit recommendations
- Filter recommendations using supported parameters

---

## Testing Performed

The frontend was tested using the Android emulator and Firebase Emulator Suite.

The following integration flows were verified:

- User registration
- User authentication
- Authenticated API requests
- Creating wardrobe items
- Saving wardrobe data
- Selecting wardrobe images
- Uploading wardrobe images
- Updating wardrobe image paths
- Creating outfits
- Planner operations
- Packing list operations
- Recommendation requests

The complete wardrobe flow was successfully tested with and without an image.

---

## Important Development Note

The frontend and backend are maintained as separate components.

```text
muse/
│
├── muse-backend/
│
└── muse-frontend/
```

Changes to backend Cloud Functions, Firestore rules, API implementation or backend configuration should be made in `muse-backend`, not in this frontend directory.

---

## Building the APK

For a release APK:

```bash
flutter build apk --release
```

The generated APK will be located under:

```text
build/app/outputs/flutter-apk/
```

---

## Development Status

### Frontend

**Core frontend implementation: Complete**

The implemented frontend features have been integrated with the MUSE backend and tested using the local Firebase Emulator Suite and Android Emulator.
