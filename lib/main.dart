import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yummies_food_app/panals/customers%20panal/welcome_screen.dart';
import 'package:yummies_food_app/provider/favorites_provider.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // --- REGISTER ALL PROVIDERS HERE ---
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
        ), // Favorites added here
      ],
      child: MaterialApp(
        title: 'ForkLane',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF6A1B9A),
          scaffoldBackgroundColor: Colors.grey[50],
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6A1B9A),
            secondary: const Color(0xFFC2185B),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
