# UberFlutterApp

A Flutter-based Uber-inspired application consisting of three main components: Admin Panel, Rider App, and User App. This project demonstrates real-time ride requests, Google Maps navigation, and Firebase integration for backend services.

---

## Table of Contents
- [Project Objective](#project-objective)
- [Folder Structure](#folder-structure)
- [Features](#features)
  - [1. Button Sheet for Location Acceptance](#1-button-sheet-for-location-acceptance)
  - [2. Navigation to Destination](#2-navigation-to-destination)
  - [3. State Management](#3-state-management)
  - [4. Backend](#4-backend)
  - [5. Clean Code](#5-clean-code)
  - [6. Additional Features](#6-additional-features)
- [Technologies Used](#technologies-used)
- [Setup & Installation](#setup--installation)
- [Screenshots](#screenshots)
- [License](#license)

---

## Project Objective

The objective of this project is to create a simple app inspired by Uber, where users can accept or reject ride requests and navigate to the destination using live Google Maps integration. Once the user reaches within 50 meters of the destination, a notification appears automatically.

---

## Folder Structure

UberFlutterApp/
├── uber_admin_panel/ # Admin functionalities for managing rides and users
├── uber_drivers_app/ # Rider/driver app to accept/reject rides and navigate
└── uber_users_app/ # User app to request rides and track drivers


---

## Features

### 1. Button Sheet for Location Acceptance
- Displays a bottom sheet with location details (e.g., destination address) when a ride request is received.
- Provides two options for the driver:
  - **Accept**: Start navigation to the destination.
  - **Reject**: Decline the ride request.

---

### 2. Navigation to Destination
- Upon accepting a ride request, the app starts **Google Maps navigation** to the destination.
- Utilizes the **Google Maps API** for real-time navigation.
- Automatically shows a **“You have reached your destination”** message when within 50 meters of the destination.

---

### 3. State Management
- **Provider** is used as the sole state management solution.
- Ensures smooth UI updates and efficient data handling between components.

---

### 4. Backend
- **Firebase** is used for storing and managing location data, ride requests, and user details.
- Optional: Firebase can also store user preferences.
- Custom backend can be implemented if Firebase does not cover specific use cases.

---

### 5. Clean Code
- Follows **best practices** for Flutter development.
- Code is clean, maintainable, and well-documented.
- Easy to scale and extend for additional features.

---

### 6. Additional Features
- **Notifications**: Alerts the user when within 50 meters of the destination.
- **ETA Display**: Shows estimated time of arrival during navigation.
- Designed to enhance **user and driver experience**.

---

## Technologies Used
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Firebase** - Backend services for authentication, real-time database, and storage
- **Google Maps API** - Real-time navigation and location tracking
- **Provider** - State management

---

## Screenshots

### User App
![User App](screenshot3.png)

### Rider App
![Rider App](screenshot2.png)

### Admin Panel
![Admin Panel](screenshot1.png)


## Setup & Installation

1. Clone the repository:
```bash
git clone https://github.com/Gouravlamba/UberFlutterApp.git
