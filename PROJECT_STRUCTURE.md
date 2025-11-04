# SpeakEasy Complete - Project Structure

Complete SpeakEasy language learning application with native iOS app and Node.js backend.

## 📦 Project Overview

SpeakEasy is a comprehensive language learning platform featuring:
- Native iOS app (Swift/SwiftUI)
- Node.js/Express backend with OpenAI integration
- Google OAuth & Apple Sign In authentication
- Real-time conversation practice with TTS
- Personalized lesson generation
- Progress tracking and analytics

---

## 📁 Complete Directory Structure

```
SpeakEasyComplete/
│
├── 📱 iOS App (Native Swift/SwiftUI)
│   ├── Controllers/              # View models & services
│   ├── Models/                   # Data models
│   ├── Views/                    # SwiftUI views
│   │   ├── Authentication/       # Login, signup
│   │   ├── Onboarding/          # User onboarding
│   │   ├── Learn/               # Learning content
│   │   ├── Practice/            # Conversation practice
│   │   ├── Progress/            # Progress tracking
│   │   └── Settings/            # App settings
│   ├── Data/                    # Lesson data & vocabulary
│   ├── Theme/                   # UI theming
│   ├── Extensions/              # Swift extensions
│   ├── Utilities/               # Helper functions
│   └── SpeakEasyApp.swift       # App entry point
│
├── 🖥️ Backend (Node.js/Express - MVC Pattern)
│   ├── controllers/             # Request handlers
│   │   ├── server-openai.js    # Main production server (OpenAI)
│   │   ├── server.js           # Alternative server (Ollama)
│   │   ├── auth-server.js      # Standalone auth
│   │   └── server-ios.js       # iOS-specific endpoints
│   ├── routes/                  # API route definitions
│   │   ├── auth-routes.js      # Authentication routes
│   │   ├── webhook-routes.js   # Webhook handlers
│   │   └── league-routes.js    # Competition routes
│   ├── services/                # Business logic
│   │   ├── google-auth-service.js
│   │   ├── apple-auth-service.js
│   │   ├── token-service.js
│   │   ├── user-service.js
│   │   └── subscription-service.js
│   ├── middleware/              # Express middleware
│   │   ├── auth-middleware.js
│   │   └── error-handler.js
│   ├── config/                  # Configuration
│   │   ├── firebase-config.js
│   │   ├── init-secrets.js
│   │   ├── secret-manager.js
│   │   └── gcloud-sa-key.json  # ⚠️ Sensitive
│   ├── utils/                   # Utilities
│   │   └── logger.js
│   ├── models/                  # Data models (empty - TODO)
│   ├── package.json            # Dependencies
│   └── README.md               # Backend documentation
│
├── 🚀 Scripts (Deployment & Setup)
│   ├── OAuth & Authentication
│   │   ├── configure-oauth-providers.js
│   │   ├── configure-oauth.sh
│   │   ├── enable-google-oauth.sh
│   │   ├── oauth-quickstart.sh
│   │   └── test-social-auth.js
│   ├── Google Cloud & VM
│   │   ├── setup-gcloud.sh
│   │   ├── open-gcloud-vm.sh
│   │   ├── connect-vm.sh
│   │   └── quick-vm.sh
│   ├── Deployment
│   │   ├── build-apps.sh
│   │   ├── deploy-local.sh
│   │   └── setup-secrets.sh
│   ├── Testing
│   │   ├── test-backend.js
│   │   ├── test-backend-connection.js
│   │   ├── test-auth-endpoints.js
│   │   └── test-webapp-auth.sh
│   ├── AI/Images
│   │   ├── generate-scenario-images.js
│   │   ├── generate-with-imagen.js
│   │   └── extract-prompts-for-manual-generation.js
│   └── Development
│       ├── setup-cloud-sync.sh
│       ├── setup-git-hooks.sh
│       └── watch-and-sync.sh
│
├── 📚 Documentation
│   ├── docs/
│   │   ├── SETUP_FIREBASE_AUTH.md
│   │   └── FIREBASE_OAUTH_CONFIGURATION.md
│   ├── MISSING_BACKEND_FILES.md    # Migration report
│   ├── PROJECT_STRUCTURE.md        # This file
│   └── backend/README.md           # Backend docs
│
└── 🔧 Configuration Files
    ├── .gitignore                  # Git ignore rules
    ├── Podfile                     # CocoaPods dependencies
    ├── SpeakEasy.xcodeproj/        # Xcode project
    └── [Other iOS config files]
```

---

## 🏗️ Architecture Overview

### iOS App Architecture

**Pattern:** MVVM (Model-View-ViewModel)

```
User Interaction
       ↓
   Views (SwiftUI)
       ↓
  ViewModels (Controllers)
       ↓
   Services (API calls)
       ↓
  Models (Data structures)
```

**Key Components:**
- **Views:** SwiftUI declarative UI components
- **Controllers:** `@ObservableObject` view models managing state
- **Models:** Swift structs/classes for data
- **Services:** API communication, speech recognition, etc.
- **Theme:** Centralized styling and colors

### Backend Architecture

**Pattern:** MVC (Model-View-Controller)

```
HTTP Request
       ↓
  Routes (Express)
       ↓
  Middleware (Auth, logging)
       ↓
  Controllers (server-*.js)
       ↓
  Services (Business logic)
       ↓
  Models (Data layer - TODO)
       ↓
  Database (In-memory/TODO)
```

**Key Components:**
- **Controllers:** Request handlers and main server files
- **Routes:** API endpoint definitions
- **Services:** OAuth, tokens, users, subscriptions
- **Middleware:** Authentication, error handling
- **Config:** Firebase, Secret Manager, credentials

---

## 🔑 Key Technologies

### iOS App
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Networking:** URLSession
- **Authentication:** Firebase Auth SDK
- **Speech:** AVFoundation, Speech Framework
- **Dependencies:** CocoaPods

### Backend
- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **AI Provider:** OpenAI GPT-4o-mini
- **TTS:** OpenAI TTS API
- **Authentication:** Firebase Admin SDK, JWT
- **Cloud:** Google Cloud Platform
- **Storage:** In-memory (production needs database)

### Infrastructure
- **Hosting:** Google Cloud Run
- **Secrets:** Google Cloud Secret Manager
- **OAuth:** Google & Apple Sign In
- **Payments:** Stripe (webhooks configured)

---

## 🚀 Quick Start Guide

### Prerequisites
- **iOS Development:**
  - macOS with Xcode 15+
  - CocoaPods installed
  - iOS Simulator or physical device

- **Backend Development:**
  - Node.js 18+ and npm
  - Google Cloud SDK (for deployment)
  - Firebase project
  - OpenAI API key

### Setup Steps

#### 1. iOS App Setup
```bash
# Install dependencies
cd /Users/scott/dev/SpeakEasyComplete
pod install

# Open in Xcode
open SpeakEasy.xcworkspace

# Configure signing and run
```

#### 2. Backend Setup
```bash
# Install dependencies
cd backend
npm install

# Configure environment variables
cp .env.example .env
# Edit .env with your API keys

# Start development server
node controllers/server-openai.js
```

#### 3. Configure OAuth
```bash
# Run OAuth setup script
cd scripts
./oauth-quickstart.sh

# Or manual configuration
./configure-oauth.sh
```

#### 4. Set Up Google Cloud (Optional)
```bash
cd scripts
./setup-gcloud.sh
./setup-secrets.sh
```

---

## 🔐 Security Notes

### ⚠️ Sensitive Files (NEVER COMMIT TO GIT)

The following files contain sensitive credentials:
- `backend/config/gcloud-sa-key.json` - Google Cloud service account
- `backend/.env` - Environment variables with API keys
- Any files with API keys, passwords, or tokens

### Recommended Security Practices

1. **Use Secret Manager in Production**
   - Store all secrets in Google Cloud Secret Manager
   - Load via `backend/config/init-secrets.js`
   - Never hardcode credentials

2. **Environment Variables**
   - Use `.env` for local development only
   - Add `.env` to `.gitignore`
   - Use different keys for dev/staging/production

3. **Service Account Keys**
   - Rotate keys regularly
   - Use minimal required permissions
   - Store in Secret Manager, not in files

4. **API Keys**
   - Never expose in client-side code
   - Always validate on backend
   - Use rate limiting

5. **Git Safety**
   ```bash
   # Check before committing
   git status

   # Review changes
   git diff

   # Ensure .gitignore is working
   git check-ignore backend/.env
   ```

---

## 📊 Development Workflow

### iOS App Development
```bash
# 1. Make changes in Xcode
# 2. Build and test
# 3. Commit Swift files only
git add Controllers/ Models/ Views/
git commit -m "Add new feature"
```

### Backend Development
```bash
# 1. Start backend server
cd backend
node controllers/server-openai.js

# 2. Test endpoints
curl http://localhost:8080/health

# 3. Make changes and test
# 4. Commit (excluding sensitive files)
git add controllers/ routes/ services/
git commit -m "Update API endpoints"
```

### Full Stack Testing
```bash
# 1. Start backend
cd backend && node controllers/server-openai.js

# 2. Update iOS app backend URL
# Edit Controllers/APIService.swift
# Change baseURL to http://localhost:8080

# 3. Run iOS app in simulator
# 4. Test full authentication and API flow
```

---

## 🧪 Testing

### Backend Testing
```bash
cd scripts

# Test all endpoints
node test-backend.js

# Test authentication
node test-auth-endpoints.js

# Test social auth
node test-social-auth.js

# Test connection
node test-backend-connection.js
```

### iOS Testing
- Run unit tests in Xcode (⌘+U)
- Test on multiple iOS versions
- Test on physical devices
- Test offline functionality

---

## 🚀 Deployment

### Backend Deployment to Google Cloud Run
```bash
cd backend

# Deploy with gcloud
gcloud run deploy speakeasy-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# Or use deployment script
cd ../scripts
./deploy-local.sh
```

### iOS App Deployment to App Store
1. Archive in Xcode (Product → Archive)
2. Upload to App Store Connect
3. Configure app metadata
4. Submit for review

---

## 📝 Environment Variables

### Backend Required Variables

Create `backend/.env`:
```env
# Server
PORT=8080
NODE_ENV=production

# OpenAI
OPENAI_API_KEY=sk-...

# Google OAuth
GOOGLE_CLIENT_ID=...apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=...

# Apple Sign In
APPLE_TEAM_ID=...
APPLE_KEY_ID=...
APPLE_CLIENT_ID=...
APPLE_PRIVATE_KEY=...

# Firebase
FIREBASE_PROJECT_ID=...
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY=...

# Google Cloud
GOOGLE_CLOUD_PROJECT=modular-analog-476221-h8
GOOGLE_APPLICATION_CREDENTIALS=./config/gcloud-sa-key.json
```

### iOS App Configuration

Update `Info.plist`:
- Google Sign In URL schemes
- Apple Sign In capability
- Backend API base URL

---

## 🔧 Troubleshooting

### iOS App Issues
- **Build fails:** Run `pod install` and clean build folder
- **Signing errors:** Check team and provisioning profiles
- **API errors:** Verify backend URL and connectivity

### Backend Issues
- **Port in use:** Change PORT in .env or kill process
- **Auth fails:** Check OAuth credentials and callback URLs
- **OpenAI errors:** Verify API key and check quota

### Common Problems
- **CORS errors:** Check backend CORS configuration
- **Network timeout:** Increase timeout in URLSession config
- **Session expired:** Implement token refresh logic

---

## 📚 Additional Resources

- [Backend Documentation](backend/README.md)
- [Firebase Auth Setup](docs/SETUP_FIREBASE_AUTH.md)
- [OAuth Configuration](docs/FIREBASE_OAUTH_CONFIGURATION.md)
- [Missing Files Report](MISSING_BACKEND_FILES.md)
- [Deployment Scripts](scripts/README-VM.md)
- [OAuth Setup Guide](scripts/README_OAUTH.md)

---

## 🎯 Next Steps

### Immediate TODOs
1. ✅ Copy backend files to Complete project
2. ✅ Organize in MVC structure
3. ✅ Create documentation
4. ⏳ Add database layer (MongoDB/PostgreSQL)
5. ⏳ Update iOS app API endpoints
6. ⏳ Test full authentication flow
7. ⏳ Deploy backend to production
8. ⏳ Submit iOS app to App Store

### Future Enhancements
- Add offline mode support
- Implement caching layer (Redis)
- Add push notifications
- Create admin dashboard
- Add analytics and monitoring
- Implement A/B testing
- Add more languages
- Create web app version

---

## 👥 Project Information

**Project Name:** SpeakEasy Complete
**Version:** 1.0.0
**Created:** 2025-11-04
**Architecture:** Native iOS + Node.js Backend
**Status:** Ready for Development

**Migrated From:**
- iOS App: Pure Swift/SwiftUI rewrite
- Backend: Archive/speakeasy/backend
- Scripts: Archive/speakeasy/scripts

---

## 📄 License

[Add your license information here]

---

## 🤝 Contributing

[Add contributing guidelines here]

---

**Last Updated:** 2025-11-04
**Documentation Status:** Complete
**Backend Migration:** Complete ✅
