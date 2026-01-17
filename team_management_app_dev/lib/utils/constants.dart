import 'package:flutter/material.dart';

// Design system constants for consistent app-wide styling
class AppColors {
  // primary brand colors for main UI elements
  static const primary = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF1976D2);
  static const primaryLight = Color(0xFF64B5F6);

  // accent colors for secondary actions and highlights
  static const accent = Color(0xFF4CAF50);
  static const accentLight = Color(0xFF81C784);

  // status colors for feedback messages
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);

  // event type colors for visual categorization
  static const training = Color(0xFF9C27B0);
  static const match = Color(0xFFFF5722);
  static const meeting = Color(0xFF00BCD4);

  // neutral colors for text and backgrounds
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);
  static const divider = Color(0xFFE0E0E0);
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;

  // event status colors for timeline visualization
  static const upcoming = Color(0xFF2196F3); 
  static const past = Color(0xFF9E9E9E);
}

// AppSpacing provides consistent spacing values
class AppSpacing {
  // padding and margin sizes for layout 
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  // border radius for rounded corners
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;

  // shadow elevation depths for material design
  static const elevationSm = 2.0;
  static const elevationMd = 4.0;
  static const elevationLg = 8.0;
}

// AppTextStyles defines typography hierarchy
class AppTextStyles {
  // heading styles for titles and section headers
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // body text styles for paragraphs and content
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // special text styles for UI elements
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );
}

// AppShadows provides shadow styles
class AppShadows {
  // subtle shadow for cards and buttons
  static const small = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  // medium shadow for elevated elements
  static const medium = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  // strong shadow for modals and overlays
  static const large = [
    BoxShadow(color: Color(0x29000000), blurRadius: 16, offset: Offset(0, 8)),
  ];
}

// EventTypeHelper provides utilities for event categorization
class EventTypeHelper {
  static IconData getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'training':
        return Icons.fitness_center;
      case 'match':
        return Icons.sports_soccer;
      case 'meeting':
        return Icons.groups;
      default:
        return Icons.event;
    }
  }

  // returns color matching event type
  static Color getColor(String type) {
    switch (type.toLowerCase()) {
      case 'training':
        return AppColors.training;
      case 'match':
        return AppColors.match;
      case 'meeting':
        return AppColors.meeting;
      default:
        return AppColors.primary;
    }
  }

  // returns emoji representing event type
  static String getEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'training':
        return '🏃';
      case 'match':
        return '⚽';
      case 'meeting':
        return '📋';
      default:
        return '📅';
    }
  }
}
