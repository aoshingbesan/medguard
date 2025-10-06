# MedGuard - Design Documentation

## Design Process Overview

### 1. User Interface Design Philosophy
MedGuard follows Material Design principles with a focus on:
- **Accessibility**: Clear typography, high contrast colors, intuitive navigation
- **Simplicity**: Clean, uncluttered interface that doesn't overwhelm users
- **Trust**: Professional appearance that instills confidence in medicine verification
- **Efficiency**: Quick access to core features with minimal taps

### 2. Color Scheme
```dart
// Primary Brand Colors
const kBrandPrimary = Color(0xFF2563EB);    // Blue - Trust, medical
const kSuccess = Color(0xFF22C55E);         // Green - Verified, safe
const kWarning = Color(0xFFD48806);         // Orange - Caution, unverified
const kDanger = Color(0xFFEF4444);          // Red - Danger, counterfeit

// Neutral Colors
const kTextPrimary = Color(0xFF1F2937);     // Dark gray - Primary text
const kTextSecondary = Color(0xFF6B7280);   // Medium gray - Secondary text
const kBackground = Color(0xFFF9FAFB);      // Light gray - Background
```

### 3. Typography
- **Headlines**: Roboto Bold, 24px
- **Body Text**: Roboto Regular, 16px
- **Captions**: Roboto Regular, 14px
- **Buttons**: Roboto Medium, 16px

### 4. Component Design

#### Navigation Cards
```dart
Card(
  elevation: 0,
  color: Colors.white,
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: kBrandPrimary.withOpacity(0.12),
      child: Icon(icon, color: kBrandPrimary),
    ),
    title: Text(title, style: titleMedium),
    subtitle: Text(subtitle, style: bodyMedium),
  ),
)
```

#### Status Indicators
- **Verified**: Green background with checkmark icon
- **Not Verified**: Orange/Red background with warning icon
- **Loading**: Circular progress indicator

### 5. Screen Layouts

#### Home Screen
- Hero section with app branding
- Four main action cards in 2x2 grid
- Consistent spacing and padding
- Clear visual hierarchy

#### Result Screen
- Large status icon (64px)
- Clear success/error messaging
- Detailed product information
- Action buttons for next steps
- Scrollable content for long information

#### History Screen
- List view with cards
- Status badges for each item
- Timestamp formatting
- Pull-to-refresh functionality

### 6. Responsive Design Considerations
- **Mobile First**: Designed primarily for mobile devices
- **Touch Targets**: Minimum 44px touch targets
- **Safe Areas**: Proper handling of notches and status bars
- **Orientation**: Portrait orientation optimized

### 7. Accessibility Features
- **Screen Reader Support**: Semantic labels and descriptions
- **High Contrast**: Sufficient color contrast ratios
- **Large Text**: Support for system font scaling
- **Touch Accessibility**: Proper focus management

## Wireframes and Mockups

### Screen Flow
```
Splash Screen → Home Screen → Manual Entry/Scan → Result Screen
                    ↓
              History Screen ← → Pharmacies Screen
```

### Key Screens

#### 1. Home Screen
- App logo and title
- "Verify Medicine" card (primary action)
- "Scan Barcode" card
- "View History" card
- "Find Pharmacies" card

#### 2. Manual Entry Screen
- Input field for GTIN
- Validation feedback
- Submit button
- Loading state

#### 3. Result Screen
- Status icon (verified/not verified)
- Product details
- Action buttons
- Back navigation

#### 4. History Screen
- List of past verifications
- Status indicators
- Timestamps
- Clear history option

## Style Guide

### Spacing
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **Extra Large**: 32px

### Border Radius
- **Small**: 8px (buttons, small cards)
- **Medium**: 12px (input fields)
- **Large**: 16px (large cards)

### Shadows
- **Light**: elevation: 0 (flat design)
- **Medium**: elevation: 2 (hover states)
- **Heavy**: elevation: 4 (modals, dialogs)

## Design Tools Used
- **Figma**: For wireframes and mockups
- **Flutter Inspector**: For debugging layouts
- **Material Design Guidelines**: For component specifications

## Future Design Enhancements
- [ ] Dark mode support
- [ ] Custom illustrations
- [ ] Animation transitions
- [ ] Advanced filtering in history
- [ ] Map integration for pharmacies
