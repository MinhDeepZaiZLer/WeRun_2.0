// lib/ui/screens/auth/auth_welcome_screen.dart
import 'package:flutter/material.dart';

class AuthWelcomeScreen extends StatelessWidget {
  final VoidCallback onJoinUsClicked;
  final VoidCallback onLoginClicked;

  const AuthWelcomeScreen({
    Key? key,
    required this.onJoinUsClicked,
    required this.onLoginClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Spacer(),
            const _WeRunLogo(),
            const Spacer(),
            ElevatedButton(
              onPressed: onJoinUsClicked,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Join Us',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onLoginClicked,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.primary, width: 2),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Log In',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeRunLogo extends StatelessWidget {
  const _WeRunLogo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'WeRun',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 60,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        Container(
          width: 220,
          height: 4,
          color: colorScheme.primary,
        ),
      ],
    );
  }
}