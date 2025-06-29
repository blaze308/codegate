import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Verify Firestore connection
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('test').add({
      'timestamp': FieldValue.serverTimestamp(),
    });
    dev.log('Firestore connection successful', name: 'Firebase');
  } catch (e) {
    dev.log('Firebase initialization error: $e', name: 'Firebase', error: e);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define our brand colors based on the logo
    const primaryBlue = Color(0xFF00A4FF); // Bright blue from logo
    const accentBlue = Color(0xFF0088FF); // Slightly darker blue for accents
    const surfaceWhite = Colors.white;
    const textDark = Color(0xFF2D3142); // Dark text color from logo

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CodeGate',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: primaryBlue,
          secondary: accentBlue,
          tertiary: primaryBlue.withOpacity(0.7),
          surface: surfaceWhite,
          background: surfaceWhite,
          error: const Color(0xFFFF3B30),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textDark,
          onBackground: textDark,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              16,
            ), // Matching logo's rounded corners
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: primaryBlue,
          secondary: accentBlue,
          tertiary: primaryBlue.withOpacity(0.7),
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
          error: const Color(0xFFFF453A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          color: const Color(0xFF2D2D2D),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
