# SpeakEasy Backend - MVC Architecture

Complete Node.js/Express backend for the SpeakEasy language learning application.

## 📁 Directory Structure (MVC Pattern)

```
backend/
├── controllers/          # Request handlers & main server files
│   ├── server-openai.js       # Production server (OpenAI GPT-4o-mini)
│   ├── server.js              # Alternative server (Ollama local LLM)
│   ├── auth-server.js         # Standalone auth server
│   ├── server-simple-auth.js  # Simplified auth implementation
│   └── server-ios.js          # iOS-specific endpoints
│
├── routes/              # API route definitions
│   ├── auth-routes.js        # Firebase authentication routes
│   ├── webhook-routes.js     # Webhook handlers (Stripe, Apple)
│   └── league-routes.js      # League/competition routes
│
├── services/            # Business logic layer
│   ├── google-auth-service.js    # Google OAuth verification
│   ├── apple-auth-service.js     # Apple Sign In verification
│   ├── token-service.js          # JWT token management
│   ├── user-service.js           # User CRUD operations
│   └── subscription-service.js   # Payment/subscription handling
│
├── middleware/          # Express middleware
│   ├── auth-middleware.js    # JWT verification
│   └── error-handler.js      # Global error handling
│
├── models/             # Data models (currently minimal)
│   └── (Add your Mongoose/Sequelize models here)
│
├── config/             # Configuration files
│   ├── firebase-config.js        # Firebase admin SDK
│   ├── init-secrets.js           # Secret Manager integration
│   ├── secret-manager.js         # Secret loading utilities
│   ├── secrets-loader.js         # Legacy secret loader
│   └── gcloud-sa-key.json        # Google Cloud service account
│
├── utils/              # Utility functions
│   └── logger.js              # Logging utilities
│
├── package.json        # Node.js dependencies
└── package-lock.json   # Dependency lockfile
```

---

## 🚀 Quick Start

**Important:** The iOS app uses **Swift Package Manager** (not npm). Only the backend uses npm!

### 1. Install Backend Dependencies (Node.js)

```bash
cd backend
npm install
```

**Note:** This installs Node.js/JavaScript packages for the backend server only.

### 2. Set Up Environment Variables

Create a `.env` file in the `backend/` directory:

```env
# Server Configuration
PORT=8080
NODE_ENV=production

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Apple Sign In
APPLE_TEAM_ID=E7B9UE64SF
APPLE_KEY_ID=864SJW3HGZ
APPLE_CLIENT_ID=com.speakeasy.webapp
APPLE_PRIVATE_KEY=your_apple_private_key

# Firebase
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_CLIENT_EMAIL=your_firebase_client_email
FIREBASE_PRIVATE_KEY=your_firebase_private_key

# Google Cloud
GOOGLE_CLOUD_PROJECT=modular-analog-476221-h8
GOOGLE_APPLICATION_CREDENTIALS=./config/gcloud-sa-key.json
```

### 3. Start the Server

#### Production Mode (OpenAI):
```bash
node controllers/server-openai.js
```

#### Development Mode (Ollama):
```bash
node controllers/server.js
```

#### Auth-Only Server:
```bash
node controllers/auth-server.js
```

The server will start on `http://localhost:8080` (or the PORT specified in .env)

---

## 📡 API Endpoints

### Health & Info
- `GET /` - API welcome page with endpoint list
- `GET /health` - Health check

### Authentication
- `POST /api/auth/google` - Google OAuth sign in
- `POST /api/auth/apple` - Apple Sign In
- `POST /api/auth/login` - Guest/email login
- `POST /api/auth/logout` - Logout
- `POST /api/auth/profile` - Update user profile
- `GET /api/auth/session/:sessionId` - Get session info
- `POST /api/auth/apple/notification` - Apple S2S notifications

### Language Learning
- `POST /api/generate` - Generic LLM completion
- `POST /api/onboarding/message` - Onboarding conversation
- `POST /api/practice/message` - Practice conversation (with TTS)
- `POST /api/practice/stream` - Streaming practice responses
- `POST /api/lessons/generate` - Generate lesson plans
- `POST /api/assessment/evaluate` - Evaluate language proficiency

### User Progress
- `POST /api/progress/update` - Update user progress
- `GET /api/progress/:sessionId` - Get user progress
- `GET /api/analytics/progress` - Analytics dashboard

### Webhooks
- `POST /webhooks/stripe` - Stripe payment webhooks
- `POST /webhooks/apple` - Apple notification webhooks

---

## 🔐 Authentication Flow

### Google OAuth
1. Client obtains ID token from Google Sign In SDK
2. Client sends token to `POST /api/auth/google`
3. Server verifies token with Google OAuth client
4. Server creates/updates user and returns session token

### Apple Sign In
1. Client obtains identity token from Apple
2. Client sends token to `POST /api/auth/apple`
3. Server verifies JWT signature with Apple's public keys
4. Server creates/updates user and returns session token

### Session Management
- Sessions stored in-memory (Map)
- Session ID format: `sess_${timestamp}_${random}`
- Include session ID in subsequent requests for progress tracking

---

## 🏗️ MVC Architecture Explanation

### Controllers (`controllers/`)
Handle HTTP requests and responses. Main entry points for the application.
- Parse request data
- Call services for business logic
- Return formatted responses
- **Main file:** `server-openai.js` combines controller logic with Express setup

### Routes (`routes/`)
Define API endpoints and map them to controller functions.
- Group related endpoints
- Apply middleware (auth, validation)
- Keep routes clean and readable

### Services (`services/`)
Contain business logic and external API integrations.
- Reusable across multiple routes
- Handle complex operations
- Interact with databases and external APIs
- Examples: OAuth verification, token generation, user management

### Middleware (`middleware/`)
Process requests before they reach controllers.
- Authentication/authorization
- Error handling
- Request logging
- Rate limiting

### Models (`models/`)
Define data structures and database schemas.
- Currently minimal (using in-memory storage)
- **TODO:** Add Mongoose models for MongoDB or Sequelize for PostgreSQL

### Config (`config/`)
Application configuration and secrets management.
- Firebase setup
- Google Cloud Secret Manager
- Environment-specific configs

### Utils (`utils/`)
Helper functions and utilities.
- Logging
- Data formatting
- Common operations

---

## 🔧 Technology Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **AI Provider:** OpenAI (GPT-4o-mini) / Ollama (local)
- **Authentication:** Firebase Admin SDK, Google OAuth, Apple Sign In
- **Cloud:** Google Cloud Platform (Cloud Run, Secret Manager)
- **Storage:** In-memory Maps (production should use database)
- **Text-to-Speech:** OpenAI TTS API

---

## 🚀 Deployment

### Local Development
```bash
npm install
node controllers/server-openai.js
```

### Google Cloud Run
```bash
# Build and deploy
gcloud run deploy speakeasy-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Using Deployment Scripts
See `../scripts/` directory for automated deployment tools:
- `setup-gcloud.sh` - Initial GCloud setup
- `setup-secrets.sh` - Configure Secret Manager
- `deploy-local.sh` - Local deployment
- `test-backend.js` - Backend testing

---

## 📊 Production Considerations

### Current Limitations
1. **In-Memory Storage** - Sessions and users stored in memory
   - ⚠️ Data lost on server restart
   - ⚠️ No horizontal scaling
   - **Solution:** Add MongoDB or PostgreSQL

2. **No Database** - No persistent storage
   - **Solution:** Add Mongoose (MongoDB) or Sequelize (PostgreSQL)

3. **Security Concerns**
   - `gcloud-sa-key.json` contains private keys
   - Should use Secret Manager in production
   - **Solution:** Load from environment variables

4. **No Rate Limiting** - API can be abused
   - **Solution:** Add express-rate-limit middleware

5. **No Request Validation** - Missing input validation
   - **Solution:** Add express-validator or Joi

### Recommended Enhancements

1. **Add Database Layer**
   ```bash
   npm install mongoose  # for MongoDB
   # or
   npm install sequelize pg  # for PostgreSQL
   ```

2. **Add Models**
   - Create `models/User.js`
   - Create `models/Session.js`
   - Create `models/Progress.js`
   - Create `models/Lesson.js`

3. **Add Caching**
   ```bash
   npm install redis ioredis
   ```

4. **Add Queue System**
   ```bash
   npm install bull  # for background jobs
   ```

5. **Add Monitoring**
   ```bash
   npm install @google-cloud/logging
   npm install @google-cloud/trace-agent
   ```

6. **Add Testing**
   ```bash
   npm install --save-dev jest supertest
   ```

---

## 🧪 Testing

### Run Backend Tests
```bash
cd ../scripts
node test-backend.js
```

### Test Specific Endpoints
```bash
# Test auth endpoints
node test-auth-endpoints.js

# Test social authentication
node test-social-auth.js

# Test backend connection
node test-backend-connection.js
```

### Manual API Testing
Use Postman, curl, or HTTPie:

```bash
# Health check
curl http://localhost:8080/health

# Google auth (replace with real token)
curl -X POST http://localhost:8080/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"idToken": "your_google_token", "name": "Test User", "email": "test@example.com"}'

# Practice conversation
curl -X POST http://localhost:8080/api/practice/message \
  -H "Content-Type: application/json" \
  -d '{"message": "Hola, ¿cómo estás?", "targetLanguage": "Spanish", "userLevel": "beginner"}'
```

---

## 📝 Environment Variables Reference

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `PORT` | Server port | No | 8080 |
| `NODE_ENV` | Environment | No | development |
| `OPENAI_API_KEY` | OpenAI API key | Yes (for AI) | - |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID | Yes (for Google auth) | - |
| `APPLE_TEAM_ID` | Apple developer team ID | Yes (for Apple auth) | - |
| `APPLE_KEY_ID` | Apple key ID | Yes (for Apple auth) | - |
| `APPLE_CLIENT_ID` | Apple service ID | Yes (for Apple auth) | - |
| `APPLE_PRIVATE_KEY` | Apple private key | Yes (for Apple auth) | - |
| `FIREBASE_PROJECT_ID` | Firebase project ID | Yes (for Firebase) | - |
| `GOOGLE_CLOUD_PROJECT` | GCP project ID | Yes (for Secret Manager) | - |
| `OLLAMA_URL` | Ollama server URL | No | http://localhost:11434 |

---

## 🔗 Related Documentation

- [Firebase Auth Setup](../docs/SETUP_FIREBASE_AUTH.md)
- [OAuth Configuration](../docs/FIREBASE_OAUTH_CONFIGURATION.md)
- [Missing Backend Files Report](../MISSING_BACKEND_FILES.md)
- [Deployment Scripts](../scripts/README-VM.md)

---

## 🐛 Troubleshooting

### Server won't start
- Check if port 8080 is already in use: `lsof -i :8080`
- Verify all required environment variables are set
- Check logs for specific error messages

### Authentication fails
- Verify OAuth credentials are correct
- Check that Google/Apple client IDs match your app configuration
- Ensure Firebase is properly initialized

### OpenAI errors
- Verify API key is valid and has credits
- Check rate limits (GPT-4o-mini: 10,000 RPM)
- Monitor token usage

### Secret Manager errors
- Verify service account has `secretmanager.secretAccessor` role
- Check that secrets exist in Secret Manager
- Verify `GOOGLE_APPLICATION_CREDENTIALS` points to valid key file

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the deployment scripts in `../scripts/`
3. Check the documentation in `../docs/`
4. Review backend logs for error details

---

**Backend Version:** 1.0.0
**Last Updated:** 2025-11-04
**Migrated From:** Archive/speakeasy/backend
**Architecture:** MVC Pattern with Express.js
