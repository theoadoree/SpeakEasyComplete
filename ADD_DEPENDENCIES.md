# Adding Swift Package Manager Dependencies

## ✅ Alamofire Usage Confirmed

Your code **DOES use Alamofire** in these files:
- `Services/APIService.swift`
- `Services/OpenAIService.swift`
- `Controllers/OpenAIService.swift`
- `Views/Components/APIService.swift`
- `Views/Components/OpenAIService.swift`

You **NEED** Alamofire for your OpenAI API integration!

## 📦 Required Dependencies

### 1. Firebase iOS SDK
**Repository**: https://github.com/firebase/firebase-ios-sdk
**Version**: 11.5.0 or higher
**Products to Add**:
- FirebaseAuth
- FirebaseAnalytics
- FirebaseFirestore
- FirebaseStorage

### 2. Google Sign-In
**Repository**: https://github.com/google/GoogleSignIn-iOS
**Version**: 7.1.0 or higher
**Products to Add**:
- GoogleSignIn
- GoogleSignInSwift

### 3. Alamofire
**Repository**: https://github.com/Alamofire/Alamofire
**Version**: 5.9.0 or higher
**Products to Add**:
- Alamofire

---

## 🔧 How to Add Dependencies in Xcode

### Step 1: Open the Project
The project is already open in Xcode at:
`/Users/scott/dev/SpeakEasyComplete/SpeakEasyComplete.xcodeproj`

### Step 2: Access Package Dependencies
1. Click on the **blue project file** at the top of the navigator (SpeakEasyComplete)
2. Select the **SpeakEasyComplete target** (not the project)
3. Click on the **"Package Dependencies"** tab (or "General" → scroll to "Frameworks, Libraries, and Embedded Content")

**OR** use the menu:
- Go to **File** → **Add Package Dependencies...**

### Step 3: Add Each Package

#### Adding Firebase:
1. Click **"+"** button
2. Paste: `https://github.com/firebase/firebase-ios-sdk`
3. Set version: **"Up to Next Major Version"** with **"11.5.0"**
4. Click **"Add Package"**
5. In the product selection dialog, check:
   - ✅ FirebaseAuth
   - ✅ FirebaseAnalytics
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
6. Click **"Add Package"**

#### Adding Google Sign-In:
1. Click **"+"** button
2. Paste: `https://github.com/google/GoogleSignIn-iOS`
3. Set version: **"Up to Next Major Version"** with **"7.1.0"**
4. Click **"Add Package"**
5. Select:
   - ✅ GoogleSignIn
   - ✅ GoogleSignInSwift
6. Click **"Add Package"**

#### Adding Alamofire:
1. Click **"+"** button
2. Paste: `https://github.com/Alamofire/Alamofire`
3. Set version: **"Up to Next Major Version"** with **"5.9.0"**
4. Click **"Add Package"**
5. Select:
   - ✅ Alamofire
6. Click **"Add Package"**

### Step 4: Wait for Resolution
Xcode will download and resolve all packages. This may take a few minutes.

### Step 5: Build the Project
Press **⌘B** or go to **Product** → **Build**

---

## 🚀 Quick Copy-Paste URLs

```
https://github.com/firebase/firebase-ios-sdk
https://github.com/google/GoogleSignIn-iOS
https://github.com/Alamofire/Alamofire
```

---

## 🔍 Verifying Dependencies Were Added

After adding packages, you should see in Xcode's Project Navigator:
```
SpeakEasyComplete
├── Package Dependencies
│   ├── firebase-ios-sdk
│   ├── GoogleSignIn-iOS
│   └── Alamofire
```

---

## ⚠️ Troubleshooting

### "Cannot find package"
- Check your internet connection
- Make sure the URL is correct (no typos)

### Build errors after adding packages
- Clean build folder: **⌘⇧K** (Cmd+Shift+K)
- Close and reopen Xcode
- Delete derived data: **File** → **Project Settings** → **Derived Data** → **Delete...**

### Package resolution takes forever
- Cancel and try again
- Check if GitHub is accessible
- Try adding packages one at a time

---

## 📝 What These Dependencies Do

### Firebase SDK
- **FirebaseAuth**: User authentication (email, Google, etc.)
- **FirebaseAnalytics**: Track app usage and events
- **FirebaseFirestore**: NoSQL cloud database
- **FirebaseStorage**: Store user files, images, audio

### Google Sign-In
- Enables "Sign in with Google" functionality
- Required for Google OAuth authentication

### Alamofire
- Simplifies HTTP networking
- Used for OpenAI API calls in your app
- Makes REST API requests cleaner and more maintainable

---

## ✅ Once Complete

After adding all dependencies and building successfully, you can:
1. Run the app (⌘R)
2. Test Firebase authentication
3. Test OpenAI API calls
4. Deploy to device or simulator

The project is now **100% ready** with all code from your archive integrated!
