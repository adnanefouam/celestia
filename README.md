# Celestia Weather App - Case Study

## 🌤️ Project Overview

**Celestia** is a modern, intuitive weather application designed to provide accurate, real-time weather insights with a focus on user experience and visual appeal. The app combines beautiful design with powerful functionality to deliver weather information that keeps users ahead of the storm.

## 🎯 Project Goals

- **User-Centric Design**: Create an intuitive interface that makes weather information accessible to everyone
- **Real-Time Accuracy**: Provide up-to-date weather data with precise location-based insights
- **Visual Excellence**: Implement time-based background imagery that reflects actual weather conditions
- **Seamless Experience**: Ensure smooth state management and instant UI updates
- **Global Reach**: Support worldwide weather data with proper timezone handling

## 🏗️ Architecture & Technology Stack

### Frontend Framework
- **Flutter**: Cross-platform mobile development for iOS and Android
- **Dart**: Modern programming language with strong typing and null safety

### State Management

- **Riverpod**: Reactive state management for predictable and testable code
- **Provider Pattern**: Clean separation of concerns with centralized state

### Key Features & Implementation

#### 1. **Intelligent Time-Based Backgrounds**
The app dynamically displays weather backgrounds based on each city's actual local time:
- **Morning (6 AM - 12 PM)**: Bright, optimistic morning imagery
- **Noon (12 PM - 6 PM)**: Vibrant daylight scenes
- **Night (6 PM - 6 AM)**: Atmospheric nighttime visuals

*Technical Innovation*: Custom timezone calculation using longitude coordinates ensures each saved city shows the appropriate background regardless of the user's location.

#### 2. **Advanced Search & Discovery**
- **Real-time Search**: Instant city suggestions as users type
- **Global Coverage**: Support for cities, airports, and locations worldwide
- **Smart Filtering**: Intelligent search results with location context

#### 3. **Interactive Weather Maps**
- **Precipitation Visualization**: Color-coded intensity levels (Light, Moderate, Heavy, Extreme)
- **Temperature Overlays**: Real-time temperature data with intuitive color gradients
- **Wind Information**: Dynamic wind speed and direction indicators
- **Interactive Elements**: Tap-to-explore functionality for detailed weather insights

#### 4. **Comprehensive Weather Details**
- **5-Day Forecast**: Extended weather predictions with temperature ranges
- **Hourly Breakdown**: Detailed hourly weather conditions
- **Weather Metrics**: UV Index, Sunrise/Sunset, Wind, Rainfall, Humidity, and "Feels Like" temperature
- **Visual Indicators**: Progress bars and charts for easy data interpretation

#### 5. **Smart City Management**
- **Save & Organize**: Heart icon to save favorite cities
- **Swipe-to-Delete**: Intuitive gesture-based city removal
- **Confirmation Dialogs**: Prevent accidental deletions
- **Real-time Updates**: Instant UI updates without app restart

## 🎨 Design Philosophy

### Visual Design Principles
- **Clean Minimalism**: Uncluttered interface focusing on essential information
- **Consistent Typography**: Hierarchical text system for optimal readability
- **Intuitive Icons**: Universal symbols that transcend language barriers
- **Color Psychology**: Strategic use of colors to convey weather emotions

### User Experience Focus
- **Progressive Disclosure**: Information revealed at appropriate interaction levels
- **Gesture-Based Navigation**: Natural swipe and tap interactions
- **Loading States**: Smooth shimmer animations during data fetching
- **Error Handling**: Graceful degradation with helpful user feedback

## 📱 Key Screens & User Journey

### 1. **Welcome Screen**
- **Purpose**: First impression and app introduction
- **Features**: 
  - Time-based greeting ("Good morning", "Good afternoon", "Good evening")
  - Global landmark showcase featuring iconic locations like the Colosseum, Golden Gate Bridge, and Statue of Liberty
  - Clear call-to-action with "Discover the weather" button
- **Design**: Serene landscape illustration with rolling hills, trees, and houses under a bright sky
- **Visual Elements**: Clean typography with the Celestia logo prominently displayed in orange

### 2. **Main Weather Screen**
- **Purpose**: Central hub for weather discovery and saved cities
- **Features**:
  - Dynamic search functionality with magnifying glass icon
  - Saved cities with time-based backgrounds showing actual local time
  - Location permission handling with "Allow current location" button
- **Innovation**: Real-time state management with Riverpod
- **Visual Elements**: Time-based greeting, search bar with orange accent, and saved cities cards with weather backgrounds

### 3. **Search Results**
- **Purpose**: Help users find and select locations
- **Features**:
  - Real-time search suggestions as users type
  - Location context (city, state, country) with arrow navigation
  - Empty state handling with "No cities found" message
- **UX**: Immediate feedback and clear navigation paths
- **Visual Elements**: Search suggestions with city names and countries, empty state with folder icon and helpful messaging

### 4. **Weather Details Screen**
- **Purpose**: Comprehensive weather information display
- **Features**:
  - Current conditions with large, readable temperature (12° prominently displayed)
  - 5-day forecast with visual temperature ranges and color-coded bars
  - Hourly breakdown with weather icons (sun, clouds, rain)
  - Detailed metrics in organized cards (UV Index, Sunrise/Sunset, Wind, Rainfall, Humidity)
- **Interaction**: Save/unsave cities with heart icon
- **Visual Elements**: Large temperature display, weather condition text, high/low temperatures, and comprehensive forecast cards

### 5. **Interactive Weather Map**
- **Purpose**: Visual weather data exploration
- **Features**:
  - Precipitation intensity visualization with color-coded legend (Light, Moderate, Heavy, Extreme)
  - Temperature overlays with color coding and numerical values
  - Wind speed indicators with mph scale
  - Interactive weather data points showing current conditions
- **Innovation**: Real-time data visualization with intuitive legends
- **Visual Elements**: Map of New Zealand with weather overlays, circular temperature indicators, and floating action buttons for different weather metrics

### 6. **Saved Cities List**
- **Purpose**: Quick access to favorite weather locations
- **Features**:
  - Time-based background images (morning, noon, night) based on each city's local time
  - City name and country prominently displayed at the top
  - Current temperature in large, bold text
  - Weather condition at the bottom
  - Swipe-to-delete functionality with confirmation dialog
- **Visual Elements**: Beautiful time-appropriate backgrounds for Casablanca (night), Auckland (day), and Bogota (evening), with consistent card layout and white text overlay

## 📊 Project Impact

### User Experience Improvements
- **Instant Feedback**: No more app restarts needed for state updates
- **Visual Clarity**: Time-appropriate backgrounds enhance weather understanding
- **Intuitive Navigation**: Gesture-based interactions feel natural
- **Comprehensive Data**: All weather information accessible in one place

### Technical Achievements
- **Scalable Architecture**: Clean separation of concerns with Riverpod
- **Cross-Platform**: Single codebase for iOS and Android
- **Real-Time Updates**: Reactive state management ensures UI consistency
- **Performance**: Optimized loading states and efficient data handling

## 📸 App Screenshots

<div align="center" style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">

  <img src="https://github.com/user-attachments/assets/0d298a81-8ed8-4a7c-ad0b-56ca921e0cf2" width="23%" />
  <img src="https://github.com/user-attachments/assets/72602510-e67d-4129-a8fb-974b79778f7c" width="23%" />
  <img src="https://github.com/user-attachments/assets/37b3fef4-8699-4cbe-8dae-bd4b45c4c5ac" width="23%" />
  <img src="https://github.com/user-attachments/assets/d10defcd-1a23-4f7d-bb1d-beb0d62a9514" width="23%" />

  <img src="https://github.com/user-attachments/assets/f0e44c89-c06e-4716-96ae-099bcc7ebe45" width="23%" />
  <img src="https://github.com/user-attachments/assets/c9c41f51-5f6b-460e-800a-a5b9a44581df" width="23%" />
  <img src="https://github.com/user-attachments/assets/701496af-a9c5-4d7f-a097-5f4be2e3a08c" width="23%" />
  <img src="https://github.com/user-attachments/assets/d021cc74-4e22-4684-978f-602c5d875659" width="23%" />

  <img src="https://github.com/user-attachments/assets/eb9026c5-4793-429f-8802-7ed0102559d6" width="23%" />
  <img src="https://github.com/user-attachments/assets/23e028f5-be8a-452f-97b3-79741b6e0f01" width="23%" />

</div>

---

*Designed & developed with ❤️ by @Fouham Adnane*
