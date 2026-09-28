# MUSE Backend Setup and Testing Guide

## 1. Overview

This repository contains the backend API for **MUSE**.

The backend is built using:

* Firebase Cloud Functions
* Firebase Authentication
* Cloud Firestore
* Express.js
* Node.js

The backend provides APIs for:

* User authentication
* Wardrobe management
* Outfit creation
* Outfit recommendations
* Outfit planner
* Packing list generation

---

# 2. Prerequisites

Install the following:

### Node.js

Recommended:

```
Node.js >= 22
```

Check:

```bash
node -v
npm -v
```

### Firebase CLI

Install:

```bash
npm install -g firebase-tools
```

Verify:

```bash
firebase --version
```

### Git

```bash
git --version
```

---

# 3. Firebase Project Setup

Copy and configure the project ID:

```bash
cp .firebaserc.example .firebaserc
```

Edit `.firebaserc` and replace `YOUR_FIREBASE_PROJECT_ID` with the actual project ID:

```json
{
  "projects": {
    "default": "muse-35420"
  }
}
```

**Note:** `.firebaserc` is git-ignored; never commit it with real project IDs.

---

# 4. Project Structure

```
muse-backend/

│
├── .firebaserc.example
├── .gitignore
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── openapi.yaml
├── getToken.js
├── README.md
│
└── functions/
    │
    ├── src/
    │   ├── index.js
    │   └── logic.js
    │
    ├── test/
    │   └── logic.test.js
    │
    ├── package.json
    ├── package-lock.json
    │
    └── node_modules/
```

---

# 5. Install Dependencies

Go to functions folder:

```bash
cd functions
```

Install packages:

```bash
npm ci
```

---

# 6. Start Firebase Emulator

From the project root:

```bash
firebase emulators:start --project muse-35420
```

Successful output:

```
✔ All emulators ready! It is now safe to connect your app.
✔ Authentication Emulator running on http://127.0.0.1:9099
✔ Functions Emulator running on http://127.0.0.1:5001
✔ Firestore Emulator running on http://127.0.0.1:8080
✔ Emulator UI running on http://127.0.0.1:4000
```

---

# 7. Get Authentication Token

## Method 1: Browser UI (Recommended for Testing)

1. Open Emulator UI: http://127.0.0.1:4000/auth
2. Click **Add user**:
   - Email: `test@example.com`
   - Password: `test123`
3. Open browser DevTools (F12) → Console tab
4. Run:
   ```javascript
   const token = await firebase.auth().currentUser.getIdToken();
   console.log(token);
   ```
5. Copy the token output

## Method 2: Automated (Node.js)

Run the provided script:

```bash
node getToken.js
```

Copy the generated token from output.

---

# 8. API Base URL

All requests use:

```
http://127.0.0.1:5001/muse-35420/asia-south1/api
```

---

# 9. Database Structure

All user data is stored under `users/{uid}`:

| Path | Contents |
|------|----------|
| `users/{uid}/wardrobe/{id}` | Clothing items (name, category, color, season, occasions, imagePath, notes, archived) |
| `users/{uid}/outfits/{id}` | Outfit combinations (name, itemIds, occasion, season, notes) |
| `users/{uid}/planner/{YYYY-MM-DD}` | Daily outfit plans (outfitId, date, notes) |
| `users/{uid}/packingLists/{id}` | Packing snapshots (name, startDate, endDate, outfitIds, extraItemIds, items) |
| `users/{uid}/auditLogs/{id}` | Action audit trail (uid, action, target, targetId, timestamp) |

**Full API schema:** See `openapi.yaml` for complete endpoint documentation.

---

# 10. API Testing

## Health Check

```bash
curl http://127.0.0.1:5001/muse-35420/asia-south1/api/health
```

Response:

```json
{
  "status":"ok"
}
```

---

## Authentication Header

All protected endpoints (`/v1/*`) require:

```bash
-H "Authorization: Bearer $TOKEN"
```

Replace `$TOKEN` with your Firebase ID token from step 7.

---

# 11. User API

## Get User Profile

```bash
curl http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/me \
  -H "Authorization: Bearer $TOKEN"
```

Response:

```json
{
  "uid": "user-id",
  "email": "test@example.com",
  "displayName": null
}
```

---

# 12. Wardrobe API

## Add Wardrobe Item

```bash
curl -X POST \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/wardrobe \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Black T-Shirt",
    "category": "top",
    "color": "black",
    "season": "all",
    "occasions": ["casual"]
  }'
```

Response (201):

```json
{
  "id": "item-id",
  "name": "Black T-Shirt",
  "category": "top",
  "color": "black",
  "season": "all",
  "occasions": ["casual"],
  "imagePath": null,
  "archived": false,
  "createdAt": "2026-09-29T12:00:00.000Z",
  "updatedAt": "2026-09-29T12:00:00.000Z"
}
```

---

## List Wardrobe Items

```bash
curl http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/wardrobe \
  -H "Authorization: Bearer $TOKEN"
```

Query params: `limit` (1-100, default 50), `after` (pagination cursor)

---

## Get Single Item

```bash
curl http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/wardrobe/<ITEM_ID> \
  -H "Authorization: Bearer $TOKEN"
```

---

## Update Wardrobe Item

```bash
curl -X PATCH \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/wardrobe/<ITEM_ID> \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "color": "dark black",
    "archived": false
  }'
```

---

## Delete Wardrobe Item

```bash
curl -X DELETE \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/wardrobe/<ITEM_ID> \
  -H "Authorization: Bearer $TOKEN"
```

Response (204): No content

---

# 13. Outfit API

## Create Outfit

```bash
curl -X POST \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/outfits \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Casual Outfit",
    "itemIds": ["item-id-1", "item-id-2", "item-id-3"],
    "occasion": "casual",
    "season": "summer"
  }'
```

Response (201): Created outfit with id

---

## List Outfits

```bash
curl http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/outfits \
  -H "Authorization: Bearer $TOKEN"
```

---

## Update Outfit

```bash
curl -X PATCH \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/outfits/<OUTFIT_ID> \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Outfit",
    "occasion": "formal"
  }'
```

---

## Delete Outfit

```bash
curl -X DELETE \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/outfits/<OUTFIT_ID> \
  -H "Authorization: Bearer $TOKEN"
```

---

# 14. Recommendations API

Get outfit recommendations based on wardrobe:

```bash
curl http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/recommendations \
  -H "Authorization: Bearer $TOKEN"
```

Optional filters:

```bash
curl "http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/recommendations?occasion=casual&season=summer" \
  -H "Authorization: Bearer $TOKEN"
```

Response:

```json
{
  "method": "rule-based-v1",
  "recommendations": [
    {
      "itemIds": ["top-id", "bottom-id", "shoes-id"]
    }
  ]
}
```

---

# 15. Planner API

## Add to Planner

```bash
curl -X PUT \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/planner/2026-10-01 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "outfitId": "outfit-id"
  }'
```

Response (201 or 200): Planned outfit for the date

---

## View Planner Range

```bash
curl "http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/planner?from=2026-10-01&to=2026-10-05" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Delete Planner Entry

```bash
curl -X DELETE \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/planner/2026-10-01 \
  -H "Authorization: Bearer $TOKEN"
```

---

# 16. Packing List API

## Create Packing List

```bash
curl -X POST \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/packing-lists \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Chennai Trip",
    "startDate": "2026-10-01",
    "endDate": "2026-10-05",
    "outfitIds": ["outfit-id-1", "outfit-id-2"]
  }'
```

Response (201): Generated packing list with items

---

## List Packing Lists

```bash
curl http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/packing-lists \
  -H "Authorization: Bearer $TOKEN"
```

---

## Get Packing List

```bash
curl http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/packing-lists/<LIST_ID> \
  -H "Authorization: Bearer $TOKEN"
```

---

## Update Item in Packing List

Mark item as packed:

```bash
curl -X PATCH \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/packing-lists/<LIST_ID>/items/<ITEM_ID> \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "packed": true
  }'
```

---

## Delete Packing List

```bash
curl -X DELETE \
  http://127.0.0.1:5001/muse-35420/asia-south1/api/v1/packing-lists/<LIST_ID> \
  -H "Authorization: Bearer $TOKEN"
```

---

# 17. Error Handling

Common error responses:

```json
{
  "error": {
    "code": "unauthorized",
    "message": "Firebase ID token required"
  }
}
```

| Status | Code | Meaning |
|--------|------|---------|
| 400 | `invalid_request` | Bad request / validation failed |
| 401 | `unauthorized` | Invalid/missing token |
| 404 | `not_found` | Resource not found |
| 409 | `conflict` | Conflict (e.g., item in use) |
| 422 | `invalid_request` | Validation failed (e.g., archived items) |
| 500 | `internal` | Server error |

---

# 18. Firebase Emulator UI

Inspect data in real-time:

```
http://127.0.0.1:4000
```

Access:

* **Authentication:** Users and sign-in methods
* **Firestore:** Database collections and documents
* **Functions:** Live logs and execution details
* **Storage:** Cloud storage objects

---

# 19. Run Tests

Unit tests for business logic:

```bash
cd functions
npm test
```

Tests cover:

* Recommendation algorithm
* Packing list generation
* Validation logic

---

# 20. Troubleshooting

### Function fails to load

Reinstall dependencies:

```bash
cd functions
rm -rf node_modules package-lock.json
npm install
```

Check for syntax errors:

```bash
npm run check
```

---

### Port already in use

Stop the emulator:

```bash
Ctrl + C
```

Or kill the process:

```bash
killall node
```

---

### Firestore data not visible

Ensure emulator is running on port 8080:

```bash
firebase emulators:start --project muse-35420
```

Check Emulator UI: http://127.0.0.1:4000/firestore

---

### Invalid token errors

Generate a fresh token:

1. Open http://127.0.0.1:4000/auth
2. Create/sign in as a test user
3. Get token from browser console (see step 7)

---

# 21. API Contract

**Full OpenAPI specification:** `openapi.yaml`

Use this for:
* Frontend integration
* Request/response schemas
* Endpoint contracts

---

# 22. Backend Verification Status

Testing completed:

✅ Firebase Emulator  
✅ Authentication (Firebase ID tokens)  
✅ User API  
✅ Wardrobe CRUD  
✅ Outfit CRUD  
✅ Recommendation System  
✅ Outfit Planner  
✅ Packing List Generation  
✅ Audit Logging  
✅ Error Handling  

**Backend is ready for frontend integration.**

---

## Questions?

Check `openapi.yaml` for the complete API schema or review the source code in `functions/src/`.