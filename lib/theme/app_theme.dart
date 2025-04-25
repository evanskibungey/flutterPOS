import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary brand colors
  static const Color primaryColor = Color(0xFFD35400);      // Deep Orange
  static const Color secondaryColor = Color(0xFFE67E22);    // Medium Orange
  static const Color tertiaryColor = Color(0xFFF39C12);     // Light Orange/Amber
  
  // Accent colors
  static const Color accentColor = secondaryColor;
  
  // Feedback colors
  static const Color errorColor = Color(0xFFE74C3C);        // Red
  static const Color successColor = Color(0xFF2ECC71);      // Green
  static const Color warningColor = Color(0xFFF39C12);      // Amber
  static const Color infoColor = Color(0xFF3498DB);         // Blue
  
  // Background colors
  static const Color backgroundColor = Color(0xFFF5F7FA);   // Light grey background
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  
  // Text colors
  static const Color textPrimaryColor = Color(0xFF2D3436);  // Dark grey for primary text
  static const Color textSecondaryColor = Color(0xFF636E72); // Medium grey for secondary text
  static const Color textTertiaryColor = Color(0xFFB2BEC3); // Light grey for disabled/hint text
  
  // Border colors
  static const Color borderColor = Color(0xFFEEEEEE);
  static const Color borderActiveColor = secondaryColor;
  
  // Status colors
  static const Color statusSuccess = Color(0xFF2ECC71);    // Green
  static const Color statusWarning = Color(0xFFF39C12);    // Amber
  static const Color statusError = Color(0xFFE74C3C);      // Red
  
  // Other utility colors
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color shadowColor = Color(0x1A000000);      // Black with 10% opacity
  
  // Color for status indicators
  static Color getStockStatusColor(int stock, int minStock) {
    if (stock <= 0) {
      return statusError;  // Out of stock
    } else if (stock <= minStock) {
      return statusWarning;  // Low stock
    } else {
      return statusSuccess;  // In stock
    }
  }
}

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondaryColor,
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        tertiary: AppColors.tertiaryColor,
        error: AppColors.errorColor,
        background: AppColors.backgroundColor,
        surface: AppColors.surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.poppins(
          color: AppColors.textSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
        ),
        bodySmall: GoogleFonts.poppins(
          color: AppColors.textSecondaryColor,
        ),
        labelLarge: GoogleFonts.poppins(
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.poppins(
          color: AppColors.textSecondaryColor,
        ),
        labelSmall: GoogleFonts.poppins(
          color: AppColors.textTertiaryColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: AppColors.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryColor,
          side: const BorderSide(color: AppColors.secondaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        labelStyle: TextStyle(color: AppColors.textSecondaryColor),
      ),
      dividerTheme: const DividerThemeData(
        space: 20,
        thickness: 1,
        color: AppColors.dividerColor,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        selectedColor: AppColors.secondaryColor.withOpacity(0.2),
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primaryColor,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.secondaryColor;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppColors.surfaceColor,
        elevation: 5,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.secondaryColor,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textTertiaryColor,
        showUnselectedLabels: true,
        elevation: 8,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.textSecondaryColor,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 3.0,
            color: AppColors.primaryColor,
          ),
        ),
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  // Custom text styles for special cases
  static TextStyle get pageTitle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  
  static TextStyle get sectionTitle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryColor,
  );
  
  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryColor,
  );
  
  static TextStyle get cardSubtitle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryColor,
  );

  // Custom card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surfaceColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Status indicator styles
  static BoxDecoration statusIndicator(int stock, int minStock) {
    Color color = getStockStatusColor(stock, minStock);
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withOpacity(0.5),
        width: 1,
      ),
    );
  }
  
  // Helper method for status colors
  static Color getStockStatusColor(int stock, int minStock) {
    return AppColors.getStockStatusColor(stock, minStock);
  }
}
