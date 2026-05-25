import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scan_screen.dart';

void main() {
  runApp(const GreenHouseApp());
}

class GreenHouseApp extends StatelessWidget {
  const GreenHouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenHouse',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7FAF4),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF123C2C);
    const mediumGreen = Color(0xFF4F8A5B);
    const softGreen = Color(0xFFE7F1E4);

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: (w * 0.06).clamp(20.0, 28.0),
            vertical: (h * 0.025).clamp(16.0, 24.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'GreenHouse',
                style: GoogleFonts.playfairDisplay(
                  fontSize: (w * 0.085).clamp(30.0, 38.0),
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),

              SizedBox(height: h * 0.025),

              Container(
                width: double.infinity,
                height: (h * 0.43).clamp(300.0, 430.0),
                decoration: BoxDecoration(
                  color: softGreen,
                  borderRadius: BorderRadius.circular(34),
                  image: const DecorationImage(
                    image: AssetImage('assets/plant.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 18,
                      left: 18,
                      child: _MiniTag(
                        icon: Icons.auto_awesome,
                        text: 'IA inteligente',
                      ),
                    ),
                    Positioned(
                      bottom: 18,
                      right: 18,
                      child: _MiniTag(
                        icon: Icons.eco_outlined,
                        text: 'Cuidados verdes',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.035),

              Text(
                'Identifica plantas\ncon inteligencia artificial',
                style: GoogleFonts.playfairDisplay(
                  fontSize: (w * 0.09).clamp(31.0, 40.0),
                  height: 1.08,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),

              SizedBox(height: h * 0.018),

              Text(
                'Toma una foto y conoce el tipo de planta, sus cuidados, toxicidad en mascotas y recomendaciones básicas.',
                style: GoogleFonts.poppins(
                  fontSize: (w * 0.04).clamp(14.0, 17.0),
                  height: 1.6,
                  color: const Color(0xFF526258),
                ),
              ),

              SizedBox(height: h * 0.035),

              SizedBox(
                width: double.infinity,
                height: (h * 0.07).clamp(56.0, 66.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    'Comenzar',
                    style: GoogleFonts.poppins(
                      fontSize: (w * 0.048).clamp(17.0, 21.0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: h * 0.035),

              Row(
                children: [
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.camera_alt_outlined,
                      title: 'Escaneo',
                      text: 'Sube/toma una foto.',
                    ),
                  ),
                  SizedBox(width: w * 0.035),
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.spa_outlined,
                      title: 'Cuidados',
                      text: 'Consejos simples.',
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniTag({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: const Color(0xFF123C2C),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF123C2C),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1E4),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF123C2C),
            size: 30,
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF123C2C),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF526258),
            ),
          ),
        ],
      ),
    );
  }
}