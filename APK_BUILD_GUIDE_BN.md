# Yug Adda APK build guide (বাংলা)

এই workflow GitHub Actions ব্যবহার করে **debug/testing APK** তৈরি করবে। এটি Play Store release-এর signed production APK নয় এবং বর্তমান অ্যাপটি demo UI; live backend/auth/chat/calls/maps এখনো যুক্ত নয়।

## APK পাওয়ার ধাপ
1. ZIP extract করে পুরো project একটি GitHub repository-তে upload করুন।
2. Repository-র **Actions** tab খুলুন।
3. `Build Yug Adda Android APK` workflow নির্বাচন করে **Run workflow** চাপুন (অথবা `main` branch-এ push করুন)।
4. সফল হলে workflow run-এর নিচে **Artifacts** থেকে `yug-adda-debug-apk` ডাউনলোড করুন।
5. ZIP artifact extract করলে `app-debug.apk` পাবেন। Android ফোনে ইনস্টল করার সময় unknown-source install permission চাইতে পারে।

## সীমাবদ্ধতা ও নিরাপত্তা
- এই build-এ production authentication/backend নেই; বাস্তব ব্যক্তিগত তথ্য ব্যবহার করবেন না।
- Debug APK শুধু পরীক্ষা/ব্যক্তিগত ব্যবহারের জন্য। Public distribution-এর আগে release signing, app icon/metadata, privacy policy, permission review, automated/device testing ও security review দরকার।
- Public GitHub repository-তে source code সবাই দেখতে পাবে; চাইলে private repository ব্যবহার করুন।
- Password, signing key বা service-account JSON repository-তে commit করবেন না।
