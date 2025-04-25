# EldoGas POS App Theme System

This document explains how to use the new centralized theme system in the EldoGas POS application.

## Overview

The theming system is built around two main files:
- `app_theme.dart`: Contains all theme definitions and helper methods
- `AppColors`: A class with all color constants used throughout the app

## How to Use the Theme in Your Screens

### 1. Import the Theme

```dart
import '../theme/app_theme.dart';
```

### 2. Use Theme Colors

Use the predefined color constants from the `AppColors` class:

```dart
// Example - Using primary or secondary colors
Container(
  color: AppColors.primaryColor,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.secondaryColor),
  ),
)

// Example - Using status colors
Icon(
  Icons.warning,
  color: AppColors.warningColor,
)
```

### 3. Use Helper Methods for Status Indicators

For inventory items, use the helper method to get the right color based on stock status:

```dart
Color statusColor = AppTheme.getStockStatusColor(product.stock, product.minStock);

// Or use the predefined decoration
Container(
  decoration: AppTheme.statusIndicator(product.stock, product.minStock),
  child: Text('Stock: ${product.stock}'),
)
```

### 4. Use Predefined Text Styles

```dart
Text(
  'Page Title',
  style: AppTheme.pageTitle,
)

Text(
  'Section Title',
  style: AppTheme.sectionTitle,
)

Text(
  'Card Title',
  style: AppTheme.cardTitle,
)
```

### 5. Use Theme's BoxDecoration for Cards

```dart
Container(
  decoration: AppTheme.cardDecoration,
  child: YourCardContent(),
)
```

## Color Palette

- **Primary Colors**
  - `AppColors.primaryColor`: Deep Orange (#D35400)
  - `AppColors.secondaryColor`: Medium Orange (#E67E22)
  - `AppColors.tertiaryColor`: Light Orange/Amber (#F39C12)

- **Feedback Colors**
  - `AppColors.errorColor`: Red (#E74C3C)
  - `AppColors.successColor`: Green (#2ECC71)
  - `AppColors.warningColor`: Amber (#F39C12)
  - `AppColors.infoColor`: Blue (#3498DB)

- **Background Colors**
  - `AppColors.backgroundColor`: Light Grey (#F5F7FA)
  - `AppColors.surfaceColor`: White (#FFFFFF)
  - `AppColors.cardColor`: White (#FFFFFF)

- **Text Colors**
  - `AppColors.textPrimaryColor`: Dark Grey (#2D3436)
  - `AppColors.textSecondaryColor`: Medium Grey (#636E72)
  - `AppColors.textTertiaryColor`: Light Grey (#B2BEC3)

## Best Practices

1. **Always use the theme colors** instead of hardcoding colors
2. **Use the theme's helper methods** for consistent styling
3. **Update the theme definitions** in `app_theme.dart` if you need to modify styles app-wide
4. **Check existing components** to see how the theme is applied

## Extending the Theme

If you need to add new theme elements, add them to the `AppTheme` class in `app_theme.dart`. Make sure to follow the existing pattern to keep the code maintainable.
