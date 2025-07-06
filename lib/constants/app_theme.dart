import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Tema Renkleri (Logo-bazlı yeni tema renkleri)
  static const Color primaryColor = Color(
    0xFFAD4134,
  ); // Kırmızımsı kahverengi (kitap rengi)
  static const Color secondaryColor = Color(
    0xFFE39B25,
  ); // Altın/turuncu (logo yazısı)
  static const Color accentColor = Color(
    0xFF303846,
  ); // Koyu gri-mavi (kalkan rengi)
  static const Color backgroundDark = Color(
    0xFF0F1620,
  ); // Koyu lacivert-siyah (arka plan)
  static const Color backgroundLight = Color(0xFFEEDFB4); // Krem/parşömen
  static const Color textDark = Color(0xFF303846); // Koyu gri-mavi
  static const Color textLight = Color(0xFFF2E8D5); // Açık krem
  static const Color purpleAccent = Color(0xFF732659); // Mor (d20 rengi)

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
        tertiary: purpleAccent,
        surface: accentColor,
        onSurface: textLight,
        background: backgroundDark,
        onBackground: textLight,
        error: Colors.red,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark.withOpacity(0.95),
        elevation: 5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzelDecorative(
          color: secondaryColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: secondaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: secondaryColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          elevation: 4,
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      // Kartlar için renk ve biçim ayarları
      cardColor: accentColor.withOpacity(0.85),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: purpleAccent,
        foregroundColor: textLight,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: secondaryColor, width: 1),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundDark,
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
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: secondaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: secondaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
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
        errorStyle: GoogleFonts.lato(color: Colors.red.shade300, fontSize: 14),
      ),
    );
  }

  // Özel yazı tipi teması
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.cinzelDecorative(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: secondaryColor,
        letterSpacing: 1.2,
      ),
      displayMedium: GoogleFonts.cinzelDecorative(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: secondaryColor,
        letterSpacing: 1.1,
      ),
      displaySmall: GoogleFonts.cinzelDecorative(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: secondaryColor,
        letterSpacing: 1,
      ),
      headlineMedium: GoogleFonts.cinzelDecorative(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        letterSpacing: 0.9,
      ),
      headlineSmall: GoogleFonts.cinzelDecorative(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
      ),
      titleLarge: GoogleFonts.cinzelDecorative(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
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
      bodyLarge: GoogleFonts.lato(fontSize: 16, color: textLight, height: 1.5),
      bodyMedium: GoogleFonts.lato(fontSize: 14, color: textLight, height: 1.5),
      labelLarge: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        color: textLight.withOpacity(0.8),
        height: 1.4,
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
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
    border: Border.all(color: secondaryColor.withOpacity(0.6), width: 1.5),
  );

  // Ana arka plan dekoratörü
  static BoxDecoration mainBackground = BoxDecoration(
    color: backgroundDark,
    image: DecorationImage(
      image: const AssetImage('assets/images/fantasy_background.jpg'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        backgroundDark.withOpacity(0.75),
        BlendMode.darken,
      ),
    ),
  );

  // Yeni Kart Dekorasyonu - Logo-inspired
  static BoxDecoration fancyCardDecoration = BoxDecoration(
    color: accentColor.withOpacity(0.85),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
      BoxShadow(
        color: secondaryColor.withOpacity(0.15),
        blurRadius: 12,
        offset: Offset(0, 0),
      ),
    ],
    border: Border.all(color: secondaryColor.withOpacity(0.4), width: 1),
  );
}
