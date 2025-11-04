# Missing Backend and Infrastructure Files

This document lists important backend and infrastructure files found in the Archive subdirectories that are **NOT** present in the SpeakEasyComplete project.

## Overview

The SpeakEasyComplete project is missing the entire backend infrastructure and configuration files that were present in the Archive/speakeasy project. The Complete project only contains Swift iOS app files.

---

## 🚨 Critical Missing Components

### 1. Backend Server Files (Node.js/Express)

**Location in Archive:** `/Users/scott/dev/ARchive/speakeasy/backend/`

#### Main Server Files
- **`server-openai.js`** - Primary production backend using OpenAI GPT-4o-mini
  - Includes Google OAuth & Apple Sign In authentication
  - OpenAI chat completions API integration
  - Language practice, lesson generation, and assessment endpoints
  - Session management and user progress tracking
  - TTS (text-to-speech) support via OpenAI API

- **`server.js`** - Alternative backend using Ollama (local LLM)
  - Uses Qwen and Llama models locally
  - Same endpoint structure as OpenAI version

- **`firebase-config.js`** - Firebase admin SDK configuration
- **`init-secrets.js`** - Google Cloud Secret Manager integration
- **`secret-manager.js`** - Secret loading utilities
- **`secrets-loader.js`** - Legacy secret loading

#### Authentication & Routes
- **`auth-routes.js`** - Firebase authentication routes
- **`auth-server.js`** - Standalone auth server
- **`server-simple-auth.js`** - Simplified auth implementation
- **`server-ios.js`** - iOS-specific server endpoints
- **`routes/auth-routes.js`** - Modular auth routes
- **`routes/webhook-routes.js`** - Webhook handlers (Stripe, Apple notifications)

#### Authentication Services
- **`services/google-auth-service.js`** - Google OAuth verification
- **`services/apple-auth-service.js`** - Apple Sign In verification
- **`services/token-service.js`** - JWT token management
- **`services/user-service.js`** - User CRUD operations
- **`services/subscription-service.js`** - Subscription/payment handling

#### Middleware & Utilities
- **`middleware/auth-middleware.js`** - JWT verification middleware
- **`middleware/error-handler.js`** - Global error handling
- **`utils/logger.js`** - Logging utilities

#### Configuration Files
- **`package.json`** - Node.js dependencies
- **`package-lock.json`** - Dependency lockfile
- **`.env`** (not in git) - Environment variables
- **`secrets/serviceAccountKey.json`** - Firebase service account key

---

### 2. Google Cloud Configuration

**Location in Archive:** `/Users/scott/dev/ARchive/speakeasy/`

- **`gcloud-sa-key.json`** - Google Cloud service account credentials
  - Project: `modular-analog-476221-h8`
  - Service account: `github-actions@modular-analog-476221-h8.iam.gserviceaccount.com`
  - ⚠️ **SECURITY WARNING:** Contains private key - should be in Secret Manager

---

### 3. Deployment & Infrastructure Scripts

**Location in Archive:** `/Users/scott/dev/ARchive/speakeasy/scripts/`

#### OAuth & Authentication Setup
- **`configure-oauth-providers.js`** - OAuth provider configuration script
- **`configure-oauth.sh`** - OAuth setup automation
- **`enable-google-oauth.sh`** - Enable Google Sign In
- **`oauth-quickstart.sh`** - Quick OAuth setup
- **`setup-secrets.sh`** - Secret Manager setup for production
- **`test-social-auth.js`** - Test social authentication flows
- **`test-webapp-auth.sh`** - Web app authentication testing

#### Google Cloud & VM Management
- **`setup-gcloud.sh`** - Google Cloud SDK setup
- **`open-gcloud-vm.sh`** - Connect to GCloud VM
- **`connect-vm.sh`** - VM connection utilities
- **`quick-vm.sh`** - Quick VM setup
- **`setup-cloud-sync.sh`** - Cloud file synchronization

#### Development & Testing
- **`build-apps.sh`** - Build mobile apps
- **`deploy-local.sh`** - Local deployment
- **`start-easy.sh`** - Easy server startup
- **`test-backend.js`** - Backend API testing
- **`test-backend-connection.js`** - Connection testing
- **`test-auth-endpoints.js`** - Auth endpoint testing

#### AI/Image Generation (Imagen)
- **`generate-scenario-images.js`** - Generate images with Google Imagen
- **`generate-with-imagen.js`** - Imagen API integration
- **`extract-prompts-for-manual-generation.js`** - Extract image prompts

#### Git & Sync
- **`setup-git-hooks.sh`** - Git hooks configuration
- **`watch-and-sync.sh`** - File watching and syncing

---

### 4. Documentation

**Location in Archive:** `/Users/scott/dev/ARchive/speakeasy/`

- **`SETUP_FIREBASE_AUTH.md`** - Firebase authentication setup guide
- **`FIREBASE_OAUTH_CONFIGURATION.md`** - OAuth configuration documentation
- **`scripts/README-VM.md`** - VM setup documentation
- **`scripts/README_OAUTH.md`** - OAuth setup guide

---

### 5. React Native/Expo Mobile App (iOS Implementation)

**Location in Archive:** `/Users/scott/dev/ARchive/speakeasy/SpeakEasy/SpeakEasy/`

The Archive contains a complete React Native/Expo-based iOS app with:

#### Swift Files (iOS-specific)
- **`ViewModels/AuthenticationManager.swift`** - Auth state management
- **`ViewModels/AppManager.swift`** - App lifecycle management
- **`Models/User.swift`** - User model
- **`Services/APIService.swift`** - Backend API communication
- **`Utilities/KeychainHelper.swift`** - Secure token storage
- **`Utilities/UserDefaultsHelper.swift`** - User preferences

#### Views
- **`Views/AuthView.swift`** - Authentication screen
- **`Views/LoginView.swift`** - Login form
- **`Views/SignUpView.swift`** - Registration form
- **`Views/OnboardingView.swift`** - Onboarding flow
- **`Views/HomeView.swift`** - Home screen
- **`Views/PracticeView.swift`** - Language practice
- **`Views/ReaderView.swift`** - Reading content
- **`Views/AnimatedTeacherView.swift`** - Animated teacher avatar
- **`Views/SettingsView.swift`** - Settings screen

#### Key Differences from Complete Project
The Archive iOS app appears to be a **React Native/Expo hybrid** with iOS native components, while SpeakEasyComplete is a **pure native Swift/SwiftUI** app. The Archive version has more emphasis on backend integration and social authentication.

---

### 6. OpenAI Service Implementation

**In Complete Project:** `/Users/scott/dev/SpeakEasyComplete/Controllers/OpenAIService.swift`
**In Archive:** Backend handles OpenAI integration server-side

The Complete project has a **client-side** OpenAI service, but the Archive backend has a more robust **server-side** implementation with:
- Session management
- User progress tracking
- TTS audio generation
- Streaming responses
- Better error handling
- Rate limiting capabilities

---

## 📋 Summary

### What's Missing from SpeakEasyComplete:

1. **Entire Node.js/Express backend** (10+ server files)
2. **Google Cloud configuration and credentials**
3. **20+ deployment and setup scripts**
4. **OAuth configuration and testing tools**
5. **Firebase admin integration**
6. **Secret Manager integration**
7. **Webhook handlers for payments/notifications**
8. **Backend authentication services**
9. **API testing and validation scripts**
10. **Production deployment configuration**

### What SpeakEasyComplete Has:

1. **Complete native Swift/SwiftUI iOS app**
2. **Comprehensive view controllers and models**
3. **Client-side OpenAI integration**
4. **Rich UI components and animations**
5. **Progress tracking and analytics views**
6. **Multi-language support architecture**

---

## 🔧 Recommendations

### To Make SpeakEasyComplete Production-Ready:

1. **Copy Backend Infrastructure:**
   ```bash
   cp -r /Users/scott/dev/ARchive/speakeasy/backend /Users/scott/dev/SpeakEasyComplete/
   ```

2. **Copy Deployment Scripts:**
   ```bash
   cp -r /Users/scott/dev/ARchive/speakeasy/scripts /Users/scott/dev/SpeakEasyComplete/
   ```

3. **Set Up Environment Variables:**
   - Create `.env` file with API keys
   - Configure Google Cloud project
   - Set up Firebase project
   - Configure OAuth credentials

4. **Update API Endpoints:**
   - Review all `URLSession` calls in Swift files
   - Update backend URL to production endpoint
   - Add proper error handling for network failures

5. **Security Review:**
   - Move `gcloud-sa-key.json` to Secret Manager
   - Never commit API keys or credentials
   - Use environment variables for all secrets
   - Implement proper token rotation

6. **Testing:**
   - Run backend locally: `cd backend && npm install && npm start`
   - Test all API endpoints with Postman or provided test scripts
   - Verify OAuth flows work correctly
   - Test payment webhooks (if using Stripe)

---

## 📁 Directory Structure Comparison

### Archive Structure:
```
ARchive/speakeasy/
├── backend/           # Node.js Express server
├── scripts/           # Deployment & setup scripts
├── SpeakEasy/         # React Native iOS app
├── node_modules/      # Frontend dependencies
├── gcloud-sa-key.json # GCloud credentials
└── [config files]     # Firebase, OAuth, etc.
```

### Complete Structure:
```
SpeakEasyComplete/
├── Controllers/       # View models & services
├── Models/           # Data models
├── Views/            # SwiftUI views
├── Data/             # Lesson & vocab data
├── Theme/            # UI theming
└── [Swift files]     # Pure native iOS app
```

---

## 🚀 Next Steps

1. **Decide on Architecture:**
   - Keep backend separate or integrate?
   - Use server-side OpenAI or client-side?
   - Deploy backend to Cloud Run, Heroku, or AWS?

2. **Copy Essential Files:**
   - At minimum, copy `backend/` folder
   - Copy OAuth setup scripts
   - Copy API testing scripts

3. **Configure Production Environment:**
   - Set up Google Cloud project
   - Configure Firebase
   - Set up Secret Manager
   - Deploy backend to production

4. **Update iOS App:**
   - Update API base URL in Swift files
   - Add proper authentication flow
   - Implement token refresh logic
   - Add offline support

5. **Documentation:**
   - Create deployment guide
   - Document API endpoints
   - Add troubleshooting guide
   - Create developer onboarding docs

---

**Generated:** 2025-11-04
**Source:** Archive comparison analysis
**Status:** ⚠️ Backend infrastructure missing from Complete project
