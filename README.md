# MUSE - Smart Wardrobe Management and Outfit Recommendation System

## Overview

MUSE is a smart wardrobe management application designed to help users organize their clothing collection, create outfits, plan daily outfits, and generate packing lists for trips.

The application provides an intelligent and user-friendly platform where users can digitally manage their wardrobe and receive personalized outfit suggestions based on occasions and seasons.

---

## Features

### 1. Digital Wardrobe Management

Users can:

* Add clothing items with details such as category, color, season, and occasion
* Upload clothing images
* View and manage wardrobe items
* Update or delete existing items

---

### 2. Outfit Creation and Recommendation

The system allows users to:

* Create custom outfits using wardrobe items
* Generate outfit recommendations based on:

  * Occasion
  * Season
  * Available wardrobe items

---

### 3. Outfit Planner

Users can schedule outfits for specific dates.

Features:

* Assign outfits to calendar dates
* View planned outfits
* Manage upcoming outfit schedules

---

### 4. Smart Packing List Generation

MUSE helps users prepare for trips by generating packing lists based on:

* Trip duration
* Destination
* Planned occasions
* Available wardrobe items

---

# System Architecture

```
Flutter Mobile Application
             |
             |
        REST API
             |
             |
 Firebase Cloud Functions
             |
       ----------------
       |              |
 Firestore       Firebase Auth
 Database
```

---

# Technology Stack

## Frontend

* Flutter
* Dart

## Backend

* Node.js
* TypeScript
* Express.js
* Firebase Cloud Functions

## Database

* Firebase Firestore

## Authentication

* Firebase Authentication

## API Documentation

* OpenAPI / Swagger

---

# Backend Features

The backend provides:

## Authentication

* Firebase authentication verification
* Secure API access using Firebase ID tokens

---

## REST APIs

Implemented APIs:

### Wardrobe

```
POST    /v1/wardrobe
GET     /v1/wardrobe
GET     /v1/wardrobe/{id}
PATCH   /v1/wardrobe/{id}
DELETE  /v1/wardrobe/{id}
```

---

### Outfit

```
POST    /v1/outfits
GET     /v1/outfits
POST    /v1/outfits/recommendations
```

---

### Planner

```
POST    /v1/planner
GET     /v1/planner
DELETE  /v1/planner/{id}
```

---

### Packing List

```
POST /v1/packing-lists/generate
```

---

# Database Design

Firestore structure:

```
users
 |
 └── userId
        |
        ├── wardrobe
        |
        ├── outfits
        |
        ├── planner
        |
        ├── packingLists
        |
        └── auditLogs
```

---

# Security Implementation

The application implements:

* Firebase Authentication
* Token-based API authorization
* Firestore access control
* Input validation
* Error handling
* Audit logging
* HTTPS communication through Firebase Cloud Functions

---

# Backend Setup

## Prerequisites

Install:

* Node.js 20+
* Firebase CLI

---

## Installation

Clone repository:

```bash
git clone <repository-url>
```

Navigate to backend:

```bash
cd muse-backend
```

Install dependencies:

```bash
npm install
```

---

## Run Locally

Build project:

```bash
npm run build
```

Start Firebase emulator:

```bash
firebase emulators:start
```

The API will be available through Firebase Functions emulator.

---

# API Documentation

The complete API specification is available in:

```
openapi.yaml
```

It can be viewed using Swagger UI or any OpenAPI-compatible tool.

---

# Project Team

| Member           | Role                   |
| ---------------- | ---------------------- |
| Akshara Sree     | UI/UX Design           |
| Akshaya Kanagala | Frontend Development   |
| Mamatha S        | Backend Development    |
| Sam MG Harish    | Deployment and Testing |

---

# Future Enhancements

* AI-based outfit recommendations
* Weather-based outfit suggestions
* Clothing recognition using computer vision
* Personalized style learning
* Social wardrobe sharing

---

# License

This project was developed as part of the MUSE academic project.
