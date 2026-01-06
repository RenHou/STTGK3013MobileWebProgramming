Here is the updated, comprehensive `README.md`. I have integrated the **Server-Side Installation** steps, detailed **Live API Endpoints**, and expanded the **Flutter configuration** section into the previous documentation.

---

# PawPal – Flutter Pet Care Companion App

**PawPal** is a cross-platform pet management and community support ecosystem. It enables users to manage pet profiles, facilitate adoptions, and contribute to animal welfare through a secure integrated wallet and donation system.

---

## 📌 Table of Contents

1. [Project Setup (Local)](https://www.google.com/search?q=%23local-setup)
2. [Server-Side Installation (Production)](https://www.google.com/search?q=%23server-side-installation)
3. [Folder Structure](https://www.google.com/search?q=%23folder-structure)
4. [API Endpoints](https://www.google.com/search?q=%23api-endpoints)
5. [Key Features](https://www.google.com/search?q=%23key-features)
6. [Technical Notes](https://www.google.com/search?q=%23technical-notes)

---

## 🚀 Local Setup

### **1. Requirements**

* **Frontend:** Flutter SDK (3.0.0+)
* **Backend:** XAMPP (PHP 7.4+ & MySQL)
* **Plugins:** * `geolocator`, `image_picker`, `image_cropper`, `webview_flutter`, `shared_preferences`.

### **2. Local Installation**

1. **Backend:** Copy the API folder to `htdocs/pawpal/api/`.
2. **Database:** * Create database: `pawpal_db`.
* Import the provided SQL structure.


3. **Flutter:** Run `flutter pub get` and update `lib/myconfig.dart` with your local IP.

---

## 🌐 Server-Side Installation

To deploy PawPal to a live Linux-based web server (Shared Hosting or VPS):

### **1. Database Production Setup**

1. **Create Database:** Use your hosting panel (cPanel/Plesk) to create `canortxw_THR_pawpal_db`.
2. **Import Schema:** Use **phpMyAdmin** to upload your SQL file.
3. **User Privileges:** Ensure your DB user has "ALL PRIVILEGES" assigned to the database.

### **2. Backend Deployment**

1. **Upload Files:** Upload all PHP files to `public_html/pawpal/api/`.
2. **Permissions:** * Create a folder: `api/uploads/`.
* Set permissions to `755` (or `777` if required by your host) to allow base64 image saving.


3. **Production Config:** Update `dbconnect.php` with your live credentials:
```php
$servername = "localhost";
$db_name = "canortxw_THR_pawpal_db";
$username = "canortxw_THR_user";
$passowrd = "YOUR_SECURE_PASSWORD";

```



### **3. SSL & API Security**

* **HTTPS:** Ensure an SSL certificate (Let's Encrypt) is active. The Flutter app requires `https://` for secure wallet transactions.
* **API Keys:** Verify `apikey.php` contains your production keys for payment gateways.

---

## 🔌 API Endpoints

Once live, the base URL is: `https://yourdomain.com/pawpal/api/`

| Endpoint | Method | Description |
| --- | --- | --- |
| `/login_user.php` | POST | Authenticates user; returns profile and wallet balance. |
| `/register_user.php` | POST | Registers a new user account. |
| `/submit_pet.php` | POST | Adds pet listing with JSON images & GPS coords. |
| `/get_my_pets.php` | GET | Retrieves pets with `searchQuery` & `filterQuery`. |
| `/donate_pet.php` | POST | Processes Money/Food/Med donations; updates wallet. |
| `/get_my_donation.php` | GET | Fetches donation history for a specific `userid`. |
| `/payment.php` | GET | Directs to WebView gateway for wallet top-ups. |
| `/update_profile.php` | POST | Updates user details and profile image. |

---

## 📁 Folder Structure

```text
pawpal/
├── lib/                  # Flutter Code
│   ├── models/           # user.dart, mypet.dart, donation.dart
│   ├── screens/          # loginscreen.dart, mainscreen.dart, etc.
│   └── myconfig.dart     # Central Server URL Config
├── assets/               # Branding and Icons
└── api/                  # PHP Server Files
    ├── dbconnect.php     # DB Connection Configuration
    ├── apikey.php        # Third-party Keys (Payment/Maps)
    ├── uploads/          # Stored Pet/User Images
    └── *.php             # Functional API Endpoints

```

---

## ✨ Key Features

* **Smart Pet Search:** Filter pets by type (Dog, Cat, Rabbit) and proximity using `geolocator`.
* **Multi-Image Support:** Up to 3 images per pet with built-in cropping and compression.
* **Integrated Digital Wallet:** * Balance managed in **Cents** for 100% mathematical precision.
* Secure top-ups via `webview_flutter`.


* **Community Donations:** Users can donate funds directly to a pet's profile, which is deducted in real-time from their wallet balance.
* **Auto-Login:** Persistence powered by `SharedPreferences` for a seamless user experience.

---

## 🧩 Technical Notes

* **Precision:** To avoid floating-point errors, the database and Flutter models store money as `int` (Cents). 1000 cents = RM 10.00.
* **Images:** Images are converted from `File` to `Base64` strings for transmission and saved as `.png` files on the server to save DB space.
* **Latency:** The app includes a 10-second timeout for registration and login requests to handle poor network conditions.
