# V-Sync Student Portal: UI/UX Design Specification

**Version:** 2.0  
**Target:** iOS & Android (Cross-Platform)  
**Style:** Apple Glassmorphism

## 1. Product Overview

V-Sync is a next-generation university student portal designed to replace clunky, legacy web wrappers. Using a premium iOS-inspired spatial glass interface, it shifts the experience from merely displaying data to providing actionable insights in a fluid and visually rich environment.

## 2. Design System & Branding

- **Primary Theme:** Adaptive glassmorphism with a deep mesh-gradient background sitting behind the app.
- **Glass Panels:** Semi-transparent panels, heavy blur, subtle inner border, and large continuous corners in the `20px-28px` range.
- **Core Accent Color:** iOS System Blue for primary actions, with neon green, orange, and red reserved for status feedback.
- **Typography:** `SF Pro` where available, with `Inter` as the Android-friendly fallback.
- **Iconography:** SF Symbols style, thin and elegant, especially for action buttons and utility surfaces.

## 3. Core Architecture & Screens

### 3.1 Authentication & Onboarding

- A single floating glass login card sits over an animated mesh background.
- Biometrics should feel primary, with login inputs as inset glass elements.
- OTP handling stays frictionless with auto-paste, smart suggestions, and auto-submit.
- Semester selection appears as floating glass pills, with the selected option becoming more opaque and vivid.

### 3.2 Home Dashboard

- The header uses large-title behavior and blurs into navigation while scrolling.
- The `Up Next` card behaves like a premium widget with countdown and room details.
- Quick actions use squircle glass tiles inspired by Control Center.
- Announcements appear in wide swipeable glass cards.

### 3.3 Timetable

- Date selection uses horizontal glass pills, with the current choice shown as a filled vibrant state.
- The current-time indicator becomes a glowing dot and neon guide line.
- Class blocks are frosted glass with subtle theory-blue and lab-green tinting.
- Content should visually slide behind frosted headers for a layered spatial effect.

### 3.4 Attendance

- Attendance health is represented with Apple Watch style rings rather than flat bars.
- The bunk meter lives inside or beside the ring with short, decisive guidance.
- Daily risk messaging appears as a compact pinned banner similar to a dynamic island cue.
- Eligibility states use compact inline frosted pills with glowing status dots.

### 3.5 Course Page & Materials

- The course page uses large-title navigation that compresses on scroll.
- Faculty lists resemble iOS Contacts or Settings with inset grouped sections.
- Materials are grouped cleanly by module with restrained glass section treatment.
- Search should feel native and tucked under the large title when expanded.

## 4. Technical UI Considerations

- Preserve login state when the user leaves the app to fetch OTP details.
- Sanitize and normalize faculty and material data before display.
- Merge duplicate class or material entries when the backend repeats identical records.
- Use friendly empty states rather than blank pages or raw backend errors.

## 5. Developer Notes

- In Flutter, rely on `BackdropFilter`, `ImageFilter.blur`, layered gradients, and reusable glass surface widgets.
- Use blur strategically to avoid performance issues on lower-end Android devices.
- Prioritize the visual foundation first: backdrop, glass containers, navigation chrome, and large-title behavior.
