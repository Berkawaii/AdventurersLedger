import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Tema Renkleri
  static const Color primaryColor = Color(0xFF8B0000); // Koyu kırmızı
  static const Color secondaryColor = Color(0xFFD4AF37); // Altın
  static const Color accentColor = Color(0xFF3A2921); // Koyu kahverengi
  static const Color backgroundDark = Color(0xFF2C1E16); // Çok koyu kahverengi
  static const Color backgroundLight = Color(0xFFF5E6CA); // Parşömen sarısı
  static const Color textDark = Color(0xFF3A2921); // Koyu kahverengi
  static const Color textLight = Color(0xFFF5E6CA); // Parşömen sarısı

  // Gölgelendirme
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 4.0,
      spreadRadius: 0.0,
      offset: Offset(0, 2),
    ),
  ];

  // Ana tema
  static ThemeData get fantasyTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: textLight,
        secondary: secondaryColor,
        onSecondary: textDark,
        surface: accentColor,
        onSurface: textLight,
        background: backgroundDark,
        onBackground: textLight,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: accentColor,
        elevation: 5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzelDecorative(
          color: secondaryColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: secondaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: secondaryColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          elevation: 4,
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Kartlar için renk ve biçim ayarları
      cardColor: accentColor,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textLight,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: secondaryColor, width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: accentColor,
        selectedItemColor: secondaryColor,
        unselectedItemColor: textLight.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.lato(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.lato(fontSize: 12),
      ),
      iconTheme: IconThemeData(color: secondaryColor),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: accentColor.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: secondaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: secondaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        labelStyle: GoogleFonts.lato(color: textLight, fontSize: 16),
        hintStyle: GoogleFonts.lato(
          color: textLight.withOpacity(0.6),
          fontSize: 16,
        ),
      ),
    );
  }

  // Özel yazı tipi teması
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.cinzelDecorative(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      displayMedium: GoogleFonts.cinzelDecorative(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      displaySmall: GoogleFonts.cinzelDecorative(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      headlineMedium: GoogleFonts.cinzelDecorative(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      headlineSmall: GoogleFonts.cinzelDecorative(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      titleLarge: GoogleFonts.cinzelDecorative(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textLight,
      ),
      titleSmall: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textLight,
      ),
      bodyLarge: GoogleFonts.lato(fontSize: 16, color: textLight),
      bodyMedium: GoogleFonts.lato(fontSize: 14, color: textLight),
      labelLarge: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        color: textLight.withOpacity(0.8),
      ),
      labelSmall: GoogleFonts.lato(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: textLight.withOpacity(0.8),
      ),
    );
  }

  // Özel kart arka plan dekoratörleri
  static BoxDecoration parchmentBackground = BoxDecoration(
    color: backgroundLight.withOpacity(0.92),
    borderRadius: BorderRadius.circular(12),
    image: DecorationImage(
      image: const AssetImage('assets/images/parchment_texture.jpg'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        backgroundLight.withOpacity(0.5),
        BlendMode.softLight,
      ),
    ),
    boxShadow: cardShadow,
    border: Border.all(color: secondaryColor.withOpacity(0.6), width: 1.5),
  );

  // Ana arka plan dekoratörü
  static BoxDecoration mainBackground = BoxDecoration(
    color: backgroundDark,
    image: DecorationImage(
      image: const AssetImage('assets/images/fantasy_background.jpg'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        backgroundDark.withOpacity(0.7),
        BlendMode.darken,
      ),
    ),
  );
}
