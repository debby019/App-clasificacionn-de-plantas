import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

const _modelAsset = 'assets/models/plant_classifier_mobilenetv2_v2.tflite';
const _classNames = ['Aloe_Vera', 'Monstera_Deliciosa', 'Orchid'];
const _confidenceThreshold = 75.0;
const _imageSize = 224;

class ResultScreen extends StatefulWidget {
  final File image;

  const ResultScreen({
    super.key,
    required this.image,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  static const darkGreen = Color(0xFF00432E);

  PredictionResult? _result;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _predictPlant();
  }

  Future<void> _predictPlant() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _runLocalPrediction();

      if (!mounted) return;
      setState(() {
        _result = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo ejecutar el modelo local: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<PredictionResult> _runLocalPrediction() async {
    final imageBytes = await widget.image.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('La imagen no se pudo leer.');
    }

    final resizedImage = img.copyResize(
      decodedImage,
      width: _imageSize,
      height: _imageSize,
    );

    final input = List.generate(
      1,
      (_) => List.generate(
        _imageSize,
        (y) => List.generate(
          _imageSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    final output = [List<double>.filled(_classNames.length, 0.0)];
    final interpreter = await Interpreter.fromAsset(_modelAsset);

    try {
      interpreter.run(input, output);
    } finally {
      interpreter.close();
    }

    final predictions = output.first;
    var predictedIndex = 0;
    var confidence = predictions.first * 100;

    for (var i = 1; i < predictions.length; i++) {
      final currentConfidence = predictions[i] * 100;
      if (currentConfidence > confidence) {
        predictedIndex = i;
        confidence = currentConfidence;
      }
    }

    final identified = confidence >= _confidenceThreshold;
    final allPredictions = <ClassPrediction>[];

    for (var i = 0; i < _classNames.length; i++) {
      allPredictions.add(
        ClassPrediction(
          className: _classNames[i],
          confidence: predictions[i] * 100,
        ),
      );
    }

    allPredictions.sort((a, b) => b.confidence.compareTo(a.confidence));

    return PredictionResult(
      prediction: identified
          ? _classNames[predictedIndex]
          : 'No se identifico la planta',
      confidence: confidence,
      identified: identified,
      threshold: _confidenceThreshold,
      message: identified
          ? 'Planta identificada correctamente'
          : 'La imagen no coincide con ninguna planta conocida',
      allPredictions: allPredictions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: darkGreen,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Resultado',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.file(
                  widget.image,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const _LoadingResult()
              else if (_error != null)
                _ErrorCard(
                  message: _error!,
                  onRetry: _predictPlant,
                )
              else if (_result != null)
                _ResultContent(
                  result: _result!,
                  onRetry: _predictPlant,
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PredictionResult {
  final String prediction;
  final double confidence;
  final bool identified;
  final double threshold;
  final String message;
  final List<ClassPrediction> allPredictions;

  const PredictionResult({
    required this.prediction,
    required this.confidence,
    required this.identified,
    required this.threshold,
    required this.message,
    required this.allPredictions,
  });
}

class ClassPrediction {
  final String className;
  final double confidence;

  const ClassPrediction({
    required this.className,
    required this.confidence,
  });
}

class PlantInfo {
  final String displayName;
  final String location;
  final String description;
  final String pets;
  final String care;

  const PlantInfo({
    required this.displayName,
    required this.location,
    required this.description,
    required this.pets,
    required this.care,
  });
}

PlantInfo plantInfoFor(String className) {
  switch (className) {
    case 'Aloe_Vera':
      return const PlantInfo(
        displayName: 'Aloe Vera (Sabila)',
        location:
            'Interior con mucha luz o exterior en climas calidos/templados. Ama el sol directo si se acostumbra gradualmente.',
        description:
            'Una suculenta todoterreno, famosa por el gel medicinal de sus hojas que alivia quemaduras. Es ideal para principiantes porque es casi indestructible.',
        pets:
            'Toxica. Contiene saponinas. Si un perro o gato la ingiere, puede causar vomitos, diarrea y letargo.',
        care:
            'Riego muy escaso. Deja que la tierra se seque por completo antes de volver a regar. Frecuencia: cada 15 a 20 dias en primavera/verano, y practicamente una vez al mes o nada en invierno. Tip pro: su peor enemigo es el exceso de agua; necesita una maceta con muy buen drenaje.',
      );
    case 'Monstera_Deliciosa':
      return const PlantInfo(
        displayName: 'Monstera Deliciosa (Costilla de Adan)',
        location:
            'Interior en un lugar luminoso sin sol directo, o exterior en sombra solo en climas tropicales sin heladas.',
        description:
            'La reina de Instagram. Es una planta trepadora tropical con hojas gigantescas que desarrollan agujeros, llamados fenestraciones, a medida que madura. Crece rapido y es muy vistosa.',
        pets:
            'Toxica. Contiene cristales de oxalato de calcio. Si la muerden, causa irritacion severa en la boca, babeo, dificultad para tragar y vomitos.',
        care:
            'Riego moderado. Espera a que los primeros 3-5 cm de tierra esten completamente secos antes de regar. Frecuencia: generalmente 1 vez por semana en verano y cada 10 o 12 dias en invierno. Tip pro: le encanta la humedad ambiental y agradece que le limpien el polvo de las hojas con un pano humedo.',
      );
    case 'Orchid':
      return const PlantInfo(
        displayName: 'Orquidea (Phalaenopsis)',
        location:
            'Interior. Necesita mucha luz, pero siempre indirecta; el sol directo quema sus hojas.',
        description:
            'Es una de las plantas de interior mas elegantes. Sus flores son muy duraderas y tiene raices aereas que cambian de color segun su necesidad de agua.',
        pets:
            'Segura, no toxica. Es completamente pet-friendly, asi que si el gato la muerde, no pasara nada mas alla del drama estetico.',
        care:
            'Riego por inmersion: sumerge la maceta en agua unos 10-15 minutos solo cuando sus raices se pongan grises. Si estan verdes, no necesita agua. Frecuencia: aproximadamente cada 7 a 10 dias, dependiendo del clima. Tip pro: odia el agua estancada en la corona, el centro de las hojas; se pudre facil.',
      );
    default:
      return PlantInfo(
        displayName: className.replaceAll('_', ' '),
        location: 'Ubicala en un lugar con luz natural adecuada.',
        description: 'El modelo identifico esta planta a partir de la imagen.',
        pets: 'Verifica la toxicidad antes de dejarla al alcance de mascotas.',
        care: 'Ajusta riego, luz y humedad segun la especie identificada.',
      );
  }
}

class _LoadingResult extends StatelessWidget {
  const _LoadingResult();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 18),
          Text(
            'Analizando la planta...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _ResultScreenState.darkGreen,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'El modelo local esta revisando la imagen y calculando la especie mas probable.',
            style: TextStyle(
              height: 1.4,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  final PredictionResult result;
  final VoidCallback onRetry;

  const _ResultContent({
    required this.result,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!result.identified) {
      return _UnidentifiedContent(
        result: result,
        onRetry: onRetry,
      );
    }

    final info = plantInfoFor(result.prediction);
    final predictions = [...result.allPredictions]
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _ResultScreenState.darkGreen,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Planta identificada',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                info.displayName,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Precision estimada: ${result.confidence.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _InfoCard(
          icon: Icons.home_outlined,
          title: 'Interior o exterior',
          content: info.location,
        ),
        _InfoCard(
          icon: Icons.info_outline,
          title: 'Informacion breve',
          content: info.description,
        ),
        _InfoCard(
          icon: Icons.pets,
          title: 'Toxicidad en mascotas',
          content: info.pets,
        ),
        _InfoCard(
          icon: Icons.water_drop_outlined,
          title: 'Cuidados',
          content: info.care,
        ),
        const SizedBox(height: 6),
        for (final prediction in predictions)
          _ConfidenceCard(prediction: prediction),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _ResultScreenState.darkGreen,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Analizar otra planta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar prediccion'),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: _ResultScreenState.darkGreen,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _ResultScreenState.darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnidentifiedContent extends StatelessWidget {
  final PredictionResult result;
  final VoidCallback onRetry;

  const _UnidentifiedContent({
    required this.result,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final predictions = [...result.allPredictions]
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF6B3F12),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resultado no concluyente',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No se identifico la planta',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mayor coincidencia: ${result.confidence.toStringAsFixed(1)}%. Minimo requerido: ${result.threshold.toStringAsFixed(0)}%.',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _InfoCard(
          icon: Icons.info_outline,
          title: 'Intenta otra imagen',
          content: result.message.isEmpty
              ? 'La imagen no coincide con Aloe Vera, Monstera Deliciosa u Orquidea con suficiente confianza.'
              : result.message,
        ),
        for (final prediction in predictions)
          _ConfidenceCard(prediction: prediction),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _ResultScreenState.darkGreen,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Probar otra foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar prediccion'),
        ),
      ],
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  final ClassPrediction prediction;

  const _ConfidenceCard({
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (prediction.confidence / 100).clamp(0.0, 1.0);
    final info = plantInfoFor(prediction.className);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  info.displayName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _ResultScreenState.darkGreen,
                  ),
                ),
              ),
              Text('${prediction.confidence.toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFB42318)),
              SizedBox(width: 10),
              Text(
                'No se pudo hacer la prediccion',
                style: TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF7A271A)),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
