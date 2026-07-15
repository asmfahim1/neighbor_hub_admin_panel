import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  // --- LIGHT THEME COLORS (Modern Estate) ---
  static const Color lightBackground = Color(0xFFFAFAF9); // Alabaster
  static const Color lightSurface = Color(0xFFFFFFFF);    // Pure White
  static const Color lightTextPrimary = Color(0xFF1E293B); // Midnight Slate
  static const Color lightTextSecondary = Color(0xFF78716C); // Warm Taupe
  static const Color lightBorder = Color(0xFFE7E5E4);     // Soft Stone

  // --- DARK THEME COLORS (Midnight Penthouse) ---
  static const Color darkBackground = Color(0xFF0C0A09);   // Obsidian
  static const Color darkSurface = Color(0xFF1C1917);      // Charcoal Graphite
  static const Color darkTextPrimary = Color(0xFFF5F5F4);  // Moonstone
  static const Color darkTextSecondary = Color(0xFFA8A29E); // Mist Gray
  static const Color darkBorder = Color(0xFF292524);       // Shadow Line

  // --- BRAND & ACCENT (Shared/Adaptive) ---
  static const Color brandNavyLight = Color(0xFF0F172A);   // Royal Navy
  static const Color brandNavyDark = Color(0xFF1E3A8A);    // Deep Ocean
  static const Color accentCopper = Color(0xFFD97706);     // Burnished Copper (Light)
  static const Color accentAmber = Color(0xFFF59E0B);      // Glowing Amber (Dark)

  // Semantic Colors
  static const Color success = Color(0xFF059669);          // Sage Green
  static const Color error = Color(0xFFEF4444);            // Coral Red
}