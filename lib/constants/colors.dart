import 'package:flutter/material.dart';

class AppColors {
  // Main Theme Colors
  static const Color primaryDark = Color(0xFF0C1A3A);
  static const Color primaryBlue = Color(0xFF0A2952);
  static const Color accentCyan = Color(0xFF00B4FF);
  static const Color accentTeal = Color(0xFF00E6B4);
  
  // Backgrounds
  static const Color background = Color(0xFFF0F4FF);
  static const Color cardWhite = Colors.white;
  static const Color splashBackground = Color(0xFF061428); // From linear gradient

  // Text Colors
  static const Color textDark = Color(0xFF0A2952);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textGray = Color(0xFF4A5568);

  // Borders
  static const Color borderLight = Color(0xFFE8EDF8);

  // Blood Bank Theme
  static const Color bloodDark = Color(0xFF8B0000);
  static const Color bloodPrimary = Color(0xFFCC1A1A);
  static const Color bloodLight = Color(0xFFFF4A4A);
  static const Color bloodBackground = Color(0xFFFFF8F8);

  // Status badges
  static const Color statusPending = Color(0xFFD97706); // Orange-amber
  static const Color statusConfirmed = Color(0xFF059669); // Green
  static const Color statusCompleted = Color(0xFF3B82F6); // Blue
  static const Color statusCancelled = Color(0xFFDC3545); // Red
  
  // Legacy support (to avoid breaking other screens immediately)
  static const Color primary = Color(0xFF0C1A3A); 
  static const Color primaryLight = Color(0xFF00B4FF);
  static const Color secondary = Color(0xFF0A2952);
  static const Color textLight = Color(0xFF94A3B8);
}
