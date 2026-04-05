# Firebase Analytics - Quick Start Guide

## 🚀 Quick Setup (5 Minutes)

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Login to Firebase & Configure
```bash
# Login to Firebase
firebase login

# Or if firebase CLI not installed, use FlutterFire directly
flutterfire configure
```

**What this does:**
- Connects to your Firebase project
- Creates `firebase_options.dart`
- Configures iOS and Android automatically

### Step 3: Run Your App
```bash
flutter run
```

That's it! Analytics is now tracking users.

---

## 📊 View Your Analytics

### Option 1: Firebase Console (Recommended)
1. Go to: https://console.firebase.google.com
2. Select your project
3. Click **Analytics** → **Dashboard**

### Option 2: Real-time Debug View
1. Firebase Console → **Analytics** → **DebugView**
2. See live events as they happen

---

## 📈 What's Being Tracked?

### Automatic Tracking:
✅ Active users (DAU/MAU)  
✅ App opens  
✅ Session duration  
✅ Screen views  
✅ Device info  
✅ Geographic location  

### Dr. Saathi Specific Events:
- Symptom checker usage
- Doctor searches
- Emergency services accessed
- Health articles viewed
- Appointments booked
- Patient/Doctor logins
- Language changes
- Payment transactions
- And more...

---

## 🔍 Key Metrics to Monitor

| Metric | Where to Find | Why It Matters |
|--------|---------------|----------------|
| **Daily Active Users** | Dashboard → Users | Growth indicator |
| **Retention Rate** | Retention → Cohorts | User stickiness |
| **Popular Features** | Events → Top Events | Feature adoption |
| **Session Duration** | Engagement → Overview | User engagement |
| **User Demographics** | Demographics | Target audience |

---

## 💡 Pro Tips

### 1. Check Data Daily
First week: Check daily to ensure tracking works  
After that: Weekly reviews are sufficient

### 2. Use DebugView for Testing
- See events in real-time
- Verify analytics implementation
- Debug tracking issues

### 3. Set Up Conversion Tracking
Track key actions:
- Appointment bookings
- Patient registrations
- Payment completions

### 4. Monitor Retention
- Day 1 retention: Did they come back?
- Day 7 retention: Are they engaged?
- Day 30 retention: Are they loyal?

### 5. A/B Testing
Use Firebase Remote Config + Analytics for:
- Testing new features
- UI variations
- Pricing experiments

---

## 🛠️ Troubleshooting

### No Data Showing?
⏰ **Wait 24-48 hours** for initial data  
🔍 Use **DebugView** for immediate feedback  
📱 Ensure app has **internet connection**

### Events Not Tracking?
Check if Firebase is initialized in `main.dart`  
Verify `firebase_options.dart` exists  
Look for errors in console logs

### iOS Not Working?
Run `pod install` in `ios/` directory  
Check minimum iOS version (11.0+)

### Android Not Working?
Check `minSdkVersion` is 21+  
Verify `google-services.json` in `android/app/`

---

## 📞 Need Help?

- 📖 Full Setup Guide: See `FIREBASE_SETUP.md`
- 🔗 Firebase Docs: https://firebase.google.com/docs/analytics
- 🔧 FlutterFire Docs: https://firebase.flutter.dev

---

## ✅ Checklist

- [ ] FlutterFire CLI installed
- [ ] `flutterfire configure` executed
- [ ] `firebase_options.dart` generated
- [ ] App runs without errors
- [ ] Firebase Console accessible
- [ ] Can see project in console
- [ ] DebugView shows events (test mode)
- [ ] Waiting for analytics data (24-48 hrs)

---

**You're all set! 🎉**

Analytics is now tracking your users. Check the Firebase Console dashboard to see your data.
