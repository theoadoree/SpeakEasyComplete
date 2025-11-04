# ✅ Production Backend - Google Cloud Run

Your SpeakEasy backend is **already deployed and running** on Google Cloud Run!

---

## 🌐 Production Backend URL

```
https://speakeasy-backend-823510409781.us-central1.run.app
```

### ✅ Verified Working
- **Health Check:** ✅ Responding
- **AI Conversation:** ✅ OpenAI GPT-4o-mini working
- **Provider:** OpenAI
- **Model:** gpt-4o-mini
- **Region:** us-central1 (Iowa, USA)

---

## 📱 iOS App Configuration

### Update Your iOS Backend URL

Find your API service file (likely `Controllers/APIService.swift` or similar) and update:

```swift
// Controllers/APIService.swift
class APIService {
    // CHANGE THIS:
    private let baseURL = "http://localhost:8080"

    // TO THIS:
    private let baseURL = "https://speakeasy-backend-823510409781.us-central1.run.app"

    // ... rest of code
}
```

**That's it!** Your iOS app will now use the production backend with OpenAI.

---

## 🧪 Test Production Endpoints

### Health Check
```bash
curl https://speakeasy-backend-823510409781.us-central1.run.app/health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-11-04T...",
  "provider": "openai",
  "model": "gpt-4o-mini",
  "apiKeyConfigured": true,
  "secretsLoaded": true
}
```

### AI Conversation (TESTED ✅)
```bash
curl -X POST https://speakeasy-backend-823510409781.us-central1.run.app/api/practice/message \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello","targetLanguage":"Spanish","userLevel":"beginner"}'
```

**Response:**
```json
{
  "response": "¡Hola! ¿Cómo estás?",
  "model": "gpt-4o-mini"
}
```

---

## 🔐 Production Configuration

### Google Cloud Run Service
- **Service Name:** speakeasy-backend
- **Project ID:** modular-analog-476221-h8
- **Region:** us-central1
- **Status:** ✅ Running
- **Last Deployed:** 2025-10-31

### Environment Variables (Configured)
```env
NODE_ENV=production
OPENAI_API_KEY=*** (from Secret Manager)
GOOGLE_CLIENT_ID=823510409781-7am96n366leset271qt9c8djo265u24n.apps.googleusercontent.com
GOOGLE_CLOUD_PROJECT=modular-analog-476221-h8
APPLE_REDIRECT_URI=https://modular-analog-476221-h8.firebaseapp.com/__/auth/handler
```

### Resource Configuration
- **Memory:** 512 MB
- **Timeout:** 300 seconds
- **Max Instances:** 10
- **Authentication:** Allow unauthenticated (public API)

---

## 📋 Available Production Endpoints

All endpoints are available at:
```
https://speakeasy-backend-823510409781.us-central1.run.app
```

### Authentication
- `POST /api/auth/google` - Google OAuth
- `POST /api/auth/apple` - Apple Sign In
- `POST /api/auth/login` - Guest login
- `POST /api/auth/logout` - Logout
- `GET /api/auth/session/:sessionId` - Session info

### Language Learning
- `POST /api/practice/message` - Conversation practice ✅
- `POST /api/practice/stream` - Streaming responses
- `POST /api/lessons/generate` - Generate lessons
- `POST /api/assessment/evaluate` - Evaluate proficiency
- `POST /api/onboarding/message` - Onboarding chat

### Monitoring
- `GET /` - API info
- `GET /health` - Health check ✅

---

## 🔄 Update Backend Code

If you need to update the backend:

### 1. Make Changes Locally
```bash
cd /Users/scott/dev/SpeakEasyComplete/backend
# Edit files...
```

### 2. Deploy to Cloud Run
```bash
gcloud run deploy speakeasy-backend \
  --source . \
  --region us-central1 \
  --platform managed
```

### 3. Verify Deployment
```bash
curl https://speakeasy-backend-823510409781.us-central1.run.app/health
```

---

## 📊 Monitor Your Backend

### View Logs
```bash
gcloud run logs read speakeasy-backend --region=us-central1 --limit=50
```

### View Service Details
```bash
gcloud run services describe speakeasy-backend --region=us-central1
```

### Check Traffic
```bash
gcloud run services list --region=us-central1
```

### Google Cloud Console
View metrics and logs: https://console.cloud.google.com/run?project=modular-analog-476221-h8

---

## 💰 Cost Monitoring

### Cloud Run Pricing
- **Free Tier:** 2 million requests/month
- **After Free Tier:** $0.40 per million requests
- **Memory:** $0.0000025 per GB-second
- **CPU:** $0.00001 per vCPU-second

### OpenAI Pricing (GPT-4o-mini)
- **Input:** $0.15 per 1M tokens (~750K words)
- **Output:** $0.60 per 1M tokens (~750K words)
- Very cost-effective model!

### Monitor Usage
- **OpenAI:** https://platform.openai.com/usage
- **Google Cloud:** https://console.cloud.google.com/billing

---

## 🚀 Other Deployed Services

You have several services already deployed:

```
✅ speakeasy-backend          - Main API (OpenAI)
✅ speakeasy-auth-api         - Authentication service
✅ speakeasy-web              - Web interface
✅ speakeasy-python-web       - Python web service
✅ server-1f6a                - Additional server
```

All are available in your Google Cloud Console.

---

## 🔐 Security Best Practices

### ✅ Already Configured
- Secrets stored in Secret Manager
- HTTPS only (automatic with Cloud Run)
- CORS enabled
- Environment variables protected

### ⚠️ Recommended Actions
1. **Rotate API Keys** (OpenAI, Google Cloud)
2. **Enable Cloud Armor** for DDoS protection
3. **Set up Cloud Monitoring** alerts
4. **Configure rate limiting** per user
5. **Add authentication** to sensitive endpoints

---

## 🎯 iOS App Update Checklist

- [ ] Update backend URL in iOS code
- [ ] Change from `localhost:8080` to production URL
- [ ] Test authentication flow
- [ ] Test AI conversation
- [ ] Test all API endpoints
- [ ] Update for production (if using different credentials)
- [ ] Build and test on device
- [ ] Submit to App Store

---

## 📝 Quick Reference

**Production URL:**
```
https://speakeasy-backend-823510409781.us-central1.run.app
```

**Health Check:**
```bash
curl https://speakeasy-backend-823510409781.us-central1.run.app/health
```

**Deploy Update:**
```bash
cd /Users/scott/dev/SpeakEasyComplete/backend
gcloud run deploy speakeasy-backend --source . --region us-central1
```

**View Logs:**
```bash
gcloud run logs read speakeasy-backend --region=us-central1
```

---

## ✅ Status Summary

| Component | Status | URL |
|-----------|--------|-----|
| Production Backend | ✅ Running | https://speakeasy-backend-823510409781.us-central1.run.app |
| Health Check | ✅ Healthy | /health |
| OpenAI Integration | ✅ Working | gpt-4o-mini |
| Google OAuth | ✅ Configured | Ready |
| Apple Sign In | ✅ Configured | Ready |
| Secret Manager | ✅ Active | Secrets loaded |

---

**Your production backend is fully operational!** 🎉

Just update your iOS app to use:
```
https://speakeasy-backend-823510409781.us-central1.run.app
```

And you're ready to ship! 🚀
