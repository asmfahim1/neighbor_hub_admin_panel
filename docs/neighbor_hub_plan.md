# NeighborHub – Project Plan

## Vision

NeighborHub is a Flutter + Firebase community platform for apartment buildings. Each building is an isolated community where administrators manage residents and residents interact through posts, announcements and notifications.

## Goals

* 100% Flutter + Firebase (no custom backend)
* Multi-tenant (supports multiple buildings)
* Offline-friendly
* Secure using Firebase Authentication and Firestore Security Rules
* Initial target: 2 buildings, ~100 residents

## Technology Stack

* Flutter
* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Firebase Cloud Messaging
* Firebase Analytics
* Firebase Crashlytics
* Firebase Hosting (Flutter Web Admin Panel)

---

# Roles

## Super Admin (future)

* Manage platform
* View all buildings
* Manage building admins

## Building Admin

### Building Management

* Create building
* Update building
* Delete building
* Upload building image
* Configure:

  * Name
  * Address
  * Floors
  * Apartments per floor

### Apartment Management

* Create apartment
* Update apartment
* Delete apartment
* Apartment name
* Description
* Status (Vacant / Occupied / Reserved)

### Resident Management

* Approve apartment requests
* Assign residents
* Remove residents
* Update resident information
* Manage family members

### Community Management

* Publish announcements
* Publish notices
* Create polls
* Create events (future)
* Remove inappropriate posts
* Remove comments (future)
* Moderate reports (future)

### Dashboard

* Total apartments
* Vacant apartments
* Occupied apartments
* Resident count
* Pending requests
* Recent activities
* Apartment vs Residence chart
* User engagement summary

### Analytics

* Daily active users
* Total posts
* Total reactions
* Most active residents
* Most viewed announcements
* Poll participation

---

## Resident

### Authentication

* Email/Password
* Google Sign-in

### Apartment

* View vacant apartments
* Apply for apartment
* Submit:

  * Name
  * Family members
  * Optional description
* Optional apartment nickname
* Request apartment change

### Community

* Create text post
* Create image post
* Create poll
* React to posts
* View feed

### Notifications

* Receive announcements
* Receive notices
* Receive community notifications

### Profile

* Update profile
* Upload avatar
* Delete account

---

# Firebase Collections

* users
* buildings
* apartments
* apartment_requests
* posts
* polls
* reactions
* announcements
* notices
* notifications
* analytics

---

# Firestore Structure

buildings/{buildingId}

* apartments
* announcements
* notices
* posts
* polls

users/{uid}

---

# Security Rules

Residents:

* Read only their building
* Create posts
* React to posts
* Update own profile

Building Admin:

* Full control of own building
* Moderate community

Super Admin:

* Full platform access

---

# MVP Roadmap

Phase 1

* Authentication
* Building Management
* Apartment Management
* Resident Approval
* Community Feed
* Announcements
* Notifications
* User Profiles

Phase 2

* Polls
* Apartment Change Requests
* Analytics Dashboard
* Post Moderation

Phase 3

* Events
* Marketplace
* Visitor Management
* Maintenance Requests
* Facility Booking
* Billing

---

# Future Business Model

* Building subscriptions
* Visitor management
* Facility booking
* Maintenance billing
* Verified local businesses
* Premium analytics
* White-label deployments
