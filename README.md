# 📋 فواتيري — Fawatiri

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-2.x-4A90E2)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**تطبيق إدارة الفواتير بين طرفين — بسيط، آمن، وفعّال**

</div>

---

## 🎯 نظرة عامة

**فواتيري** هو تطبيق Flutter مصمم لإدارة عملية الشراء بين طرفين:
- 👤 **المالك (Owner)** — يُنشئ ويُرسل الفواتير
- ✅ **المستلم (Receiver)** — يستلم ويعتمد الفواتير

---

## ✨ الميزات الرئيسية

| الميزة | الوصف |
|--------|-------|
| 🧾 **إنشاء الفواتير** | إضافة منتجات بسعر وكمية مع إكمال تلقائي من مكتبة المنتجات |
| 🔄 **حالات الفواتير** | مرسلة ➜ معتمدة مع تتبع في الوقت الفعلي |
| 🔐 **حماية PIN** | تأمين اعتماد الفواتير برمز PIN محلي (4 أرقام) |
| 📚 **مكتبة المنتجات** | حفظ المنتجات السابقة للاستخدام السريع |
| 📊 **لوحة التحكم** | إجمالي المشتريات المعتمدة + عدد الفواتير المعلقة |
| 🕐 **سجل الفواتير** | تصفية حسب الحالة (الكل / مرسلة / معتمدة) |
| ✏️ **تعديل الفواتير** | تعديل الفواتير المرسلة قبل الاعتماد |
| 🎨 **تصميم عصري** | واجهة عربية أنيقة باستخدام خط Cairo |

---

## 🏗️ المعمارية

```
┌─────────────────────────────────────────────────────────────┐
│                         Flutter UI                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │  Login   │  │   Home   │  │ Invoice  │  │ Settings │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │     Riverpod        │
                    │   State Management  │
                    └─────────┬─────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────▼────┐          ┌────▼────┐          ┌────▼────┐
   │  Auth   │          │ Invoice │          │   PIN   │
   │Provider │          │Provider │          │Provider │
   └────┬────┘          └────┬────┘          └────┬────┘
        │                     │                     │
   ┌────▼────┐          ┌────▼────┐          ┌────▼────┐
   │Firebase │          │Firestore│          │Secure   │
   │  Auth   │          │Service  │          │Storage  │
   └─────────┘          └─────────┘          └─────────┘
```

---

## 📁 هيكل المشروع

```
lib/
├── 📂 models/
│   ├── invoice.dart          # نموذج الفاتورة + حالاتها
│   ├── item.dart             # نموذج عنصر الفاتورة
│   └── product.dart          # نموذج المنتج
│
├── 📂 services/
│   ├── firestore_service.dart    # CRUD العمليات مع Firestore
│   └── pin_service.dart          # إدارة PIN المحلي
│
├── 📂 providers/
│   ├── auth_provider.dart        # حالة المصادقة والأدوار
│   ├── invoice_provider.dart     # حالة الفواتير والبناء
│   └── pin_provider.dart         # حالة PIN والإعدادات
│
├── 📂 screens/
│   ├── login_screen.dart         # شاشة تسجيل الدخول
│   ├── home_screen.dart          # الصفحة الرئيسية
│   ├── invoice_builder_screen.dart   # إنشاء فاتورة جديدة
│   ├── invoice_detail_screen.dart    # تفاصيل الفاتورة
│   ├── invoice_edit_screen.dart      # تعديل الفاتورة
│   ├── history_screen.dart       # سجل الفواتير
│   ├── product_library_screen.dart   # مكتبة المنتجات
│   └── settings_screen.dart      # الإعدادات
│
├── 📂 widgets/
│   ├── invoice_card.dart         # بطاقة الفاتورة
│   ├── item_tile.dart            # عنصر القائمة
│   └── pin_dialog.dart           # حوار إدخال PIN
│
└── main.dart                     # نقطة الدخول + التوجيه
```

---

## 🚀 التشغيل السريع

### 1️⃣ إنشاء المشروع

```bash
flutter create fawatiri --org com.yourname
cd fawatiri
```

### 2️⃣ تثبيت الاعتماديات

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.5.1
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.1.0
  flutter_secure_storage: ^9.0.0
  go_router: ^14.0.0
  uuid: ^4.4.0
  google_fonts: ^6.2.1
  intl: ^0.19.0
```

```bash
flutter pub get
```

### 3️⃣ إعداد Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. أنشئ مشروعًا جديدًا باسم `fawatiri`
3. أضف تطبيق Android — Package: `com.yourname.fawatiri`
4. نزّل `google-services.json` → ضعه في `android/app/`
5. فعّل **Authentication → Email/Password**
6. أنشئ **Firestore Database** → وضع الاختبار
7. شغّل `flutterfire configure`

### 4️⃣ إنشاء الحسابين

في Firebase Console → Authentication → Add user:

```
📧 YOUR_OWNER_EMAIL / 🔒 YOUR_PASSWORD
📧 YOUR_RECEIVER_EMAIL / 🔒 YOUR_PASSWORD
```

### 5️⃣ إعداد الأدوار في Firestore

الأدوار تُحدَّد من Firestore، وليس من `.env`. أنشئ مستنداً جديداً باسم `roles` داخل المجموعة `config`:

```text
config/roles
{
  ownerUid:    "<UID حساب المالك>",
  receiverUid: "<UID حساب المستلم>"
}
```

كيف تجد UID الحساب: Firebase Console ← Authentication ← Users ← انسخ `User UID` لكل حساب.

> عند تسجيل الدخول، يُقرأ التطبيق الأدوار من `config/roles` في Firestore تلقائياً (مصدر الحقيقة). أي مستخدم آخر — ليس المالك ولا المستلم — لن يحصل على أي صلاحية مميزة.

`.env` اختياري ويُستخدم فقط لقيم الإعداد المحلي الفعلية (وليس للأدوار) — انسخ `.env.example` إلى `.env` عند الحاجة فقط. `.env` غير مرفوع إلى Git.
### 6️⃣ تشغيل التطبيق

```bash
flutter run
```

---

## 🔐 قواعد Firestore

الأدوار تُقرأ من `config/roles` في Firestore — تُدار في Firebase Console (الحقول `ownerUid` و `receiverUid`)، ولا توجد قيم UID مكتوبة في الكود أو القواعد. انشر من الملف `fawatiri/firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── Roles from config/roles (Firebase Console is the source of truth) ──
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner() {
      return isSignedIn() &&
        request.auth.uid == get(/databases/$(database)/documents/config/roles).data.ownerUid;
    }

    function isReceiver() {
      return isSignedIn() &&
        request.auth.uid == get(/databases/$(database)/documents/config/roles).data.receiverUid;
    }

    function isMember() {
      return isOwner() || isReceiver();
    }

    // ── config ──────────────────────────────────────────────
    match /config/roles {
      allow read: if isMember();
      allow write: if false; // managed in Firebase Console only
    }

    match /config/receiver_security {
      allow read: if isMember();
      allow write: if isReceiver()
        && request.resource.data.keys().hasOnly(['pin', 'pinEnabled', 'updatedAt'])
        && request.resource.data.pin is string
        && request.resource.data.pinEnabled is bool;
    }

    // ── invoices ────────────────────────────────────────────
    match /invoices/{invoiceId} {
      allow read: if isMember();

      allow create: if isOwner()
        && request.resource.data.status in ['sent', 'approved']
        && request.resource.data.invoiceNumber is int
        && request.resource.data.total is number
        && request.resource.data.createdAt is timestamp;

      allow update: if
        // owner edits lines/total and resets status to sent/approved
        (isOwner()
          && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['items', 'total', 'status'])
          && request.resource.data.status in ['sent', 'approved'])
        ||
        // receiver approves a sent invoice only
        (isReceiver()
          && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status'])
          && resource.data.status == 'sent'
          && request.resource.data.status == 'approved');

      allow delete: if false;
    }

    // ── products ────────────────────────────────────────────
    match /products/{productId} {
      allow read: if isMember();
      allow create: if isOwner();
      allow update: if isOwner();
      allow delete: if isOwner();
    }

    // ── payments ────────────────────────────────────────────
    match /payments/{paymentId} {
      allow read: if isMember();

      allow create: if isOwner()
        && request.resource.data.status == 'pending'
        && request.resource.data.amount is number
        && request.resource.data.totalAtTime is number
        && request.resource.data.createdAt is timestamp;

      allow update: if isReceiver()
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status', 'confirmedAt'])
        && resource.data.status == 'pending'
        && request.resource.data.status == 'confirmed'
        && request.resource.data.confirmedAt is timestamp;

      allow delete: if false;
    }
  }
}
```


---

## 🛡️ الأمان

- ✅ مصادقة Firebase Email/Password
- ✅ PIN محلي مشفّر (flutter_secure_storage)
- ✅ قواعد Firestore صارمة حسب الدور
- ✅ اعتماد الفواتير محمي بـPIN اختياري

---

