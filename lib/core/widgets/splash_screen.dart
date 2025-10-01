import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon with theme-aware styling
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceVariant.withOpacity(0.8)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.school,
                size: 60,
                color: isDark
                    ? colorScheme.primary
                    : colorScheme.primary
                        .withBlue(150), // Softer blue for light mode
              ),
            ),
            const SizedBox(height: 32),
            // App Name with theme-aware styling
            Text(
              'Skuupay',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? colorScheme.onSurface
                    : Colors.white.withOpacity(0.95),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            // Tagline with theme-aware styling
            Text(
              'School Management Made Simple',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? colorScheme.onSurface.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 60),
            // Loading indicator with theme-aware styling
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceVariant.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? colorScheme.primary : Colors.white),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
