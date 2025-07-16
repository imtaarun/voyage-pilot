import 'package:flutter/material.dart';
import 'package:voyageui/src/app/screens/plan_trip_screen.dart';

void main() {
  runApp(const VoyagePilotApp());
}

class VoyagePilotApp extends StatelessWidget {
  const VoyagePilotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a vibrant accent color
    const accentColor = Colors.cyanAccent;

    return MaterialApp(
      title: 'Voyage Pilot',
      debugShowCheckedModeBanner: false,
      // Define the dark theme for the entire app
      theme: ThemeData.dark().copyWith(
        // Core color scheme
          scaffoldBackgroundColor: Colors.transparent, // Required for gradient background
          primaryColor: const Color(0xFF0D1B2A),
          colorScheme: const ColorScheme.dark(
            primary: accentColor,
            secondary: accentColor,
            background: Color(0xFF0D1B2A),
            surface: Color(0xFF1B263B),
          ),

          // Component Themes
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            // This creates the "glass" effect for cards
            color: Colors.black.withOpacity(0.25),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.black.withOpacity(0.3),
            indicatorColor: accentColor,
            labelTextStyle: MaterialStateProperty.all(const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            )),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          toggleButtonsTheme: ToggleButtonsThemeData(
            selectedColor: Colors.black,
            color: Colors.white,
            fillColor: accentColor,
            borderRadius: BorderRadius.circular(8),
            selectedBorderColor: accentColor,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.white.withOpacity(0.1),
            selectedColor: accentColor,
            labelStyle: const TextStyle(color: Colors.white),
            secondaryLabelStyle: const TextStyle(color: Colors.black),
            padding: const EdgeInsets.all(8),
          )
      ),
      // Set the root widget which will have the gradient background
      home: const AppContainer(),
    );
  }
}

// This widget wraps the entire app to provide the gradient background
class AppContainer extends StatelessWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF2d004f), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: PlanTripScreen(),
    );
  }
}