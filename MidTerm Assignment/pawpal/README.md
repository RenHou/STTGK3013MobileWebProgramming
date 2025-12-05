# pawpal– Flutter Pet Care Companion App

Below is a clean and professional **README.md** template for your project.
You can copy-paste directly into a `README.md` file.

---

# 🐾 PawPal API – Backend Documentation

This repository contains the backend API for **PawPal**, a pet adoption & listing app.
The backend is built using **PHP (XAMPP)** and connects to **MySQL** to manage users, pets, and images.

---

## 📌 Table of Contents

1. [Project Setup](#project-setup)
2. [Folder Structure](#folder-structure)
3. [API Endpoints](#api-endpoints)
4. [Submit Pet API](#submit-pet-api)
5. [Sample JSON Request](#sample-json-request)
6. [Response Format](#response-format)

---

## 🚀 Project Setup

### **1. Requirements**

* XAMPP / PHP 8+
* MySQL / MariaDB
* Flutter mobile client (optional)

### **2. Installation**

1. Clone or copy this API folder into:

   ```
   htdocs/pawpal/api/
   ```

2. Import the database:

   * Open *phpMyAdmin*
   * Create a database: **pawpal**
   * Import your SQL file

3. Configure database connection in **dbconnect.php**:

```php
<?php
$servername = "localhost";
$username   = "root";
$password   = "";
$database   = "pawpal";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
```

4. Ensure this folder exists for image uploads:

```
pawpal/api/uploads/
```

---

## 📁 Folder Structure

```
pawpal/
│
├── api/
│   ├── dbconnect.php
│   ├── submit_pet.php
│   ├── get_my_pets.php
│   ├── uploads/
│   │     └── (saved pet images)
│   └── ...
```

---

## 🔌 API Endpoints

| Endpoint               | Method | Description                      |
| ---------------------- | ------ | -------------------------------- |
| `/api/submit_pet.php`  | POST   | Add new pet with multiple images |
| `/api/get_my_pets.php` | GET    | Retrieve all pets with user info |
| `/api/uploads/*`       | GET    | Access uploaded images           |

---

# 🐶 Submit Pet API

### **URL**

```
POST /pawpal/api/submit_pet.php
```

### **Content-Type**

`application/x-www-form-urlencoded`

### **Required Fields**

| Field         | Type                | Description                    |
| ------------- | ------------------- | ------------------------------ |
| `userid`      | int                 | ID of user                     |
| `name`        | string              | Pet name                       |
| `type`        | string              | Pet type (dog, cat, etc.)      |
| `category`    | string              | Category (adopt, lost, donate) |
| `latitude`    | string              | Pet location latitude          |
| `longitude`   | string              | Pet location longitude         |
| `description` | string              | Pet description                |
| `images`      | JSON array (base64) | List of base64 image strings   |

---

## 📤 Sample JSON Request (Flutter)

```dart
{
  "userid": "12",
  "name": "Lucky",
  "type": "Dog",
  "category": "Adopt",
  "latitude": "6.12345",
  "longitude": "100.12345",
  "description": "Very friendly dog.",
  "images": [
      "iVBORw0KGgoAAAANSUhEUgAABk...",
      "iVBORw0KGgzDAsdsadadsAAABBB..."
  ]
}
```

Flutter encoding example:

```dart
final body = {
  "userid": userId,
  "name": petName,
  "type": petType,
  "category": category,
  "latitude": lat.toString(),
  "longitude": lng.toString(),
  "description": desc,
  "images": jsonEncode(base64ImagesList),
};
```

---

## 🟢 Sample Success Response

```json
{
  "status": "success",
  "message": "Pet added successfully"
}
```

## 🔴 Sample Error Response

```json
{
  "status": "failed",
  "message": "Missing fields"
}
```

---

# 🧩 Notes

* All uploaded images are stored inside:

  ```
  /api/uploads/pet_<id>_<index>.png
  ```
* `image_paths` in database is stored as **JSON array** for easy parsing in Flutter.

---

Just tell me!
