# Student Management System Pro (SFML)

A **desktop-based Student Management System** built in **C++ using SFML 3.0**.  
This application provides a modern GUI to manage students, view class-wise records, search students, and delete records using an efficient linked-list–based data structure.

---

## 📌 Features

- 🎓 **Add Students**
  - Roll Number
  - Full Name
  - Class (1–12)
  - Category (e.g. CS, Bio, Pre-Eng)

- 🏫 **View Students by Class**
  - Class-wise grid (Class 1–12)
  - Table-style display with:
    - Registration Number
    - Student Name
    - Category

- 🔍 **Search Student**
  - Search by Roll Number
  - Instant result feedback

- ❌ **Delete Student**
  - Remove student by Roll Number
  - Safe deletion from linked list

- 🖱️ **Modern GUI**
  - Hover effects
  - Buttons and input boxes
  - Notifications for success and errors

---

## 🛠 Technologies Used

- **Language:** C++ (Modern C++)
- **GUI Library:** SFML 3.0
- **Data Structures:**
  - Singly Linked List (Students)
  - Singly Linked List (Subjects per student)




---

## 🧠 Internal Design

### Core Classes

- **Subject**
  - Stores subject name and marks status
- **Student**
  - Stores student info and subject list
- **StudentManager**
  - Handles add, search, delete operations
- **App**
  - Controls UI states and rendering
- **Button**
  - Reusable clickable UI component
- **InputBox**
  - Text input fields with focus handling


MENU
ADD_STUDENT
VIEW_CLASSES
VIEW_CLASS_DETAILS
SEARCH
DELETE_STUDENT
---

## How to Build & Run
### 1️⃣ Install SFML 3.0

Make sure SFML 3.0 is installed and properly linked.

### linux
sudo apt install libsfml-dev

### macOS (Homebrew)
brew install sfml

### 2️⃣ Compile
g++ main.cpp -o student_system \
-lsfml-graphics -lsfml-window -lsfml-system

### 3️⃣ Run
./student_system


📜 License

This project is open for educational and personal use.
Feel free to modify, enhance, and extend it.

👤 Author

Sarmad Durrani
SFML & C++ GUI Project

