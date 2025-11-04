# Dependency Management - SpeakEasy Complete

This project has two separate components with different dependency managers:

---

## 📱 iOS App - Swift Package Manager (SPM)

### Native Swift Dependencies

The iOS app uses **Swift Package Manager** (built into Xcode), NOT npm.

### How to Install iOS Dependencies

#### Option 1: Automatic (Recommended)
```bash
# Open the project in Xcode
open SpeakEasy.xcodeproj

# Xcode will automatically resolve Swift Package dependencies
# File → Packages → Resolve Package Versions
```

#### Option 2: Command Line
```bash
# Using xcodebuild
xcodebuild -resolvePackageDependencies

# Or using swift package command
swift package resolve
```

### Current iOS Dependencies

The iOS app likely uses Swift packages for:
- Firebase iOS SDK (if used)
- Network libraries
- UI components
- Analytics

**Location:** Dependencies defined in:
- `SpeakEasy.xcodeproj/project.pbxproj` (Xcode project)
- Or `Package.swift` (if using SPM manifest)

### Adding New Swift Packages

1. Open project in Xcode
2. File → Add Package Dependencies...
3. Enter package URL (e.g., `https://github.com/firebase/firebase-ios-sdk`)
4. Select version
5. Add to target

### Alternative: CocoaPods (Legacy)

If the project uses CocoaPods (check for `Podfile`):
```bash
# Install CocoaPods if not installed
sudo gem install cocoapods

# Install dependencies
pod install

# Always open .xcworkspace, not .xcodeproj
open SpeakEasy.xcworkspace
```

**Note:** Check if `Podfile` exists. If it does, use CocoaPods. Otherwise, use SPM.

---

## 🖥️ Backend - npm (Node Package Manager)

### Node.js Dependencies

The backend is Node.js/Express and **requires npm**.

### How to Install Backend Dependencies

```bash
# Navigate to backend directory
cd /Users/scott/dev/SpeakEasyComplete/backend

# Install all dependencies from package.json
npm install

# Or using yarn (alternative)
yarn install
```

### Backend Dependencies Include:

**Core:**
- `express` - Web framework
- `cors` - CORS middleware
- `dotenv` - Environment variables

**Authentication:**
- `firebase-admin` - Firebase Admin SDK
- `google-auth-library` - Google OAuth
- `jsonwebtoken` - JWT tokens

**AI/ML:**
- `openai` - OpenAI API client
- `axios` - HTTP client (for Ollama)

**Cloud:**
- `@google-cloud/secret-manager` - GCP Secret Manager

**See:** `backend/package.json` for complete list

### Managing Backend Dependencies

```bash
# Add new dependency
npm install package-name

# Add dev dependency
npm install --save-dev package-name

# Update dependencies
npm update

# Check for outdated packages
npm outdated

# Audit for security issues
npm audit
npm audit fix
```

---

## 📦 Dependency Overview

### What Uses What

| Component | Dependency Manager | Install Command | Location |
|-----------|-------------------|-----------------|----------|
| **iOS App** | Swift Package Manager (SPM) | Xcode auto-resolves | Project file |
| **iOS App (legacy)** | CocoaPods (if Podfile exists) | `pod install` | Podfile |
| **Backend** | npm (Node.js) | `npm install` | backend/package.json |
| **Scripts** | npm (Node.js) | `npm install` (if needed) | scripts/package.json |

---

## 🚀 Complete Setup Guide

### First Time Setup

#### 1. iOS App Setup
```bash
# Check if using CocoaPods
cd /Users/scott/dev/SpeakEasyComplete

if [ -f "Podfile" ]; then
    echo "Using CocoaPods"
    pod install
    open SpeakEasy.xcworkspace
else
    echo "Using Swift Package Manager"
    open SpeakEasy.xcodeproj
    # Xcode will auto-resolve packages
fi
```

#### 2. Backend Setup
```bash
# Install Node.js dependencies
cd /Users/scott/dev/SpeakEasyComplete/backend
npm install

# Configure environment
cp .env.example .env
# Edit .env with your API keys

# Start backend
node controllers/server-openai.js
```

#### 3. Verify Everything Works
```bash
# Test backend
cd /Users/scott/dev/SpeakEasyComplete/scripts
node test-backend.js

# Run iOS app in Xcode
# Press ⌘+R to build and run
```

---

## 📋 Quick Reference

### iOS App Commands
```bash
# Open in Xcode (will handle dependencies automatically)
open SpeakEasy.xcodeproj

# Or with CocoaPods
pod install
open SpeakEasy.xcworkspace

# Build from command line
xcodebuild -scheme SpeakEasy -configuration Debug
```

### Backend Commands
```bash
# Install dependencies
npm install

# Start production server (OpenAI)
node controllers/server-openai.js

# Start development server (Ollama)
node controllers/server.js

# Run tests
npm test  # if test scripts are configured
```

### Script Commands
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run deployment scripts
cd scripts
./setup-gcloud.sh
./deploy-local.sh
```

---

## 🔍 Checking Your Setup

### Check iOS Dependencies

```bash
# Check if using CocoaPods
ls Podfile 2>/dev/null && echo "✅ Using CocoaPods" || echo "❌ No Podfile found"

# Check if using SPM
grep -r "swift-tools-version" . 2>/dev/null && echo "✅ Using SPM" || echo "❌ No Package.swift found"

# Check Xcode project for SPM packages
# Open in Xcode and check: File → Packages
```

### Check Backend Dependencies

```bash
# Check if Node.js is installed
node --version  # Should show v18.x.x or higher
npm --version   # Should show 9.x.x or higher

# Check if dependencies are installed
ls backend/node_modules 2>/dev/null && echo "✅ Dependencies installed" || echo "❌ Run npm install"

# List installed packages
npm list --depth=0
```

---

## 🛠️ Troubleshooting

### iOS App Issues

**Problem:** "Package resolution failed"
```bash
# Solution: Clean and resolve
rm -rf ~/Library/Developer/Xcode/DerivedData
# Open Xcode → File → Packages → Reset Package Caches
# File → Packages → Resolve Package Versions
```

**Problem:** CocoaPods issues
```bash
# Update CocoaPods
sudo gem install cocoapods
pod repo update
pod install --repo-update
```

**Problem:** "No such module" errors
```bash
# Clean build folder
# In Xcode: Product → Clean Build Folder (⇧⌘K)
# Then rebuild
```

### Backend Issues

**Problem:** "Cannot find module"
```bash
# Reinstall dependencies
cd backend
rm -rf node_modules
rm package-lock.json
npm install
```

**Problem:** "node: command not found"
```bash
# Install Node.js
brew install node
# Or download from https://nodejs.org/
```

**Problem:** npm permission errors
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm
# Or use nvm (Node Version Manager)
```

---

## 📚 Additional Resources

### Swift Package Manager
- [Official SPM Documentation](https://swift.org/package-manager/)
- [Using SPM in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

### CocoaPods
- [CocoaPods Guides](https://guides.cocoapods.org/)
- [Installation Instructions](https://cocoapods.org/)

### npm (Node Package Manager)
- [npm Documentation](https://docs.npmjs.com/)
- [package.json Guide](https://docs.npmjs.com/cli/v9/configuring-npm/package-json)

---

## ✅ Summary

| What | Dependency Manager | Why |
|------|-------------------|-----|
| **iOS App** | Swift Package Manager | Native Swift dependencies |
| **iOS App (legacy)** | CocoaPods | If Podfile exists |
| **Backend** | npm | Node.js/JavaScript dependencies |
| **Scripts** | npm | Node.js utility scripts |

**Key Point:** Only the backend (Node.js) uses `npm install`. The iOS app uses Xcode's built-in Swift Package Manager or CocoaPods.

---

**Last Updated:** 2025-11-04
**Project:** SpeakEasy Complete
**Architecture:** Native iOS + Node.js Backend
