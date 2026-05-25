import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final Color darkGreen = const Color(0xFF00432E);

  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  Future<void> takePhoto() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 900,
      maxHeight: 900,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> pickFromGallery() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 900,
      maxHeight: 900,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void goToResult() {
    if (selectedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          image: selectedImage!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              children: [

                /// HEADER
                Row(
                  children: [

                    /// BOTON REGRESAR
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: darkGreen,
                          size: screenWidth * 0.05,
                        ),
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.04),

                    /// TITULO
                    Text(
                      'GreenHouse',
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03),

                /// IMAGEN
                selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.file(
                          selectedImage!,
                          height: screenHeight * 0.32,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )

                    : Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.04,
                          horizontal: screenWidth * 0.05,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [

                            Container(
                              width: screenWidth * 0.22,
                              height: screenWidth * 0.22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF3E5),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                Icons.eco_rounded,
                                size: screenWidth * 0.11,
                                color: darkGreen,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            Text(
                              'Escaneo Inteligente',
                              style: TextStyle(
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.bold,
                                color: darkGreen,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.01),

                            Text(
                              'Detecta plantas usando inteligencia artificial',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),

                SizedBox(height: screenHeight * 0.035),

                /// TITULO
                Text(
                  'Identifica tu planta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.085,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),

                SizedBox(height: screenHeight * 0.018),

                /// TEXTO
                Text(
                  'Toma una foto o sube una imagen para\nobtener un diagnóstico instantáneo y\nconsejos de cuidado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    height: 1.5,
                    color: const Color(0xFF666666),
                  ),
                ),

                SizedBox(height: screenHeight * 0.035),

                /// BOTON CAMARA
                _ActionButton(
                  backgroundColor: darkGreen,
                  icon: Icons.camera_alt_outlined,
                  title: 'Tomar Foto',
                  subtitle: 'Usa tu cámara ahora',
                  textColor: Colors.white,
                  onTap: takePhoto,
                ),

                SizedBox(height: screenHeight * 0.02),

                /// BOTON GALERIA
                _ActionButton(
                  backgroundColor: Colors.white,
                  icon: Icons.image_outlined,
                  title: 'Subir de Galería',
                  subtitle: 'Elige una foto guardada',
                  textColor: Colors.black,
                  onTap: pickFromGallery,
                ),

                /// BOTON CONTINUAR
                if (selectedImage != null) ...[
                  SizedBox(height: screenHeight * 0.03),

                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: goToResult,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: screenHeight * 0.05),

                /// TEXTO ABAJO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: screenWidth * 0.035,
                      color: Colors.green.shade300,
                    ),

                    SizedBox(width: screenWidth * 0.015),

                    Text(
                      'Tus fotos son procesadas de forma privada',
                      style: TextStyle(
                        fontSize: screenWidth * 0.028,
                        color: Colors.green.shade300,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.backgroundColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    final screenWidth = size.width;
    final screenHeight = size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [

            /// ICONO
            Container(
              width: screenWidth * 0.13,
              height: screenWidth * 0.13,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: textColor,
                size: screenWidth * 0.07,
              ),
            ),

            SizedBox(width: screenWidth * 0.045),

            /// TEXTO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.005),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.033,
                      color: textColor.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),

            /// FLECHA
            Icon(
              Icons.chevron_right,
              color: textColor.withOpacity(0.75),
              size: screenWidth * 0.07,
            ),
          ],
        ),
      ),
    );
  }
}
