import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/services/recommendation_service.dart';
import '../../../core/services/weather_service.dart';
import '../../profile/providers/app_provider.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final CropRecommendationService _recommendationService = CropRecommendationService();
  final WeatherService _weatherService = WeatherService();

  double _n = 50.0;
  double _p = 50.0;
  double _k = 50.0;
  double _ph = 6.5;
  double _rainfall = 100.0;
  double _temp = 25.0;
  double _humidity = 60.0;

  bool _isRecommending = false;
  bool _showSettings = false;
  final _ipController = TextEditingController(text: 'http://10.0.2.2:5000');

  @override
  void initState() {
    super.initState();
    _loadWeatherDefaults();
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherDefaults() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      final weather = await _weatherService.fetchLiveWeather(
        locationName: appProvider.farmerLocation,
      );
      setState(() {
        _temp = weather.temperature;
        _humidity = weather.humidity.toDouble();
      });
    } catch (_) {}
  }

  void _getRecommendation() async {
    setState(() {
      _isRecommending = true;
    });

    _recommendationService.serverUrl = _ipController.text.trim();

    final result = await _recommendationService.getRecommendation(
      N: _n,
      P: _p,
      K: _k,
      temp: _temp,
      humidity: _humidity,
      ph: _ph,
      rainfall: _rainfall,
    );

    setState(() {
      _isRecommending = false;
    });

    if (mounted) {
      _showResultDialog(result);
    }
  }

  void _showResultDialog(RecommendationResult result) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final crop = result.recommendedCrop.toUpperCase();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.stars, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Recommendation Result'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'OPT-IN TARGET CROP:',
                      style: TextStyle(fontSize: 10, color: theme.hintColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      crop,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Based on soil chemistry (N: ${_n.toInt()}, P: ${_p.toInt()}, K: ${_k.toInt()}), soil acidity (pH: $_ph), and climate statistics, $crop is highly recommended.',
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prediction Mode:',
                    style: TextStyle(fontSize: 11, color: theme.hintColor),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: result.isSimulated ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      result.status.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: result.isSimulated ? Colors.orange.shade800 : Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/');
              },
              child: const Text('Back to Dashboard'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showSettings ? Icons.settings : Icons.settings_outlined),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Backend URL settings
            if (_showSettings) ...[
              Card(
                elevation: 0,
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Flask Server IP Configurations',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _ipController,
                        decoration: const InputDecoration(
                          hintText: 'http://192.168.1.100:5000',
                          prefixIcon: Icon(Icons.link),
                          helperText: 'Enter local PC IP address to connect physical phone.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Analyze Soil & Climate Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Input soil nutrients and meteorological parameters for AI recommendation',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
            const SizedBox(height: 20),

            // Soil chemistry parameters
            _buildNutrientSlider('Nitrogen (N) - Soil Nutrient', _n, 0, 140, (val) {
              setState(() => _n = val);
            }, colorScheme.primary),
            const SizedBox(height: 16),

            _buildNutrientSlider('Phosphorus (P) - Soil Nutrient', _p, 0, 140, (val) {
              setState(() => _p = val);
            }, Colors.orange),
            const SizedBox(height: 16),

            _buildNutrientSlider('Potassium (K) - Soil Nutrient', _k, 0, 200, (val) {
              setState(() => _k = val);
            }, Colors.blue),
            const SizedBox(height: 16),

            // Soil acidity & Rainfall parameters
            _buildAcidAndRainCard(theme, colorScheme),
            const SizedBox(height: 16),

            // Climate variables
            _buildClimateCard(theme, colorScheme),
            const SizedBox(height: 28),

            // Action button
            ElevatedButton(
              onPressed: _isRecommending ? null : _getRecommendation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isRecommending
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Text('Evaluating Decision Boundary...'),
                      ],
                    )
                  : const Text('Get Crop Recommendation'),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientSlider(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    Color activeColor,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  '${value.toInt()} mg/kg',
                  style: TextStyle(fontWeight: FontWeight.bold, color: activeColor, fontSize: 13),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              activeColor: activeColor,
              inactiveColor: activeColor.withOpacity(0.15),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcidAndRainCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // pH Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Soil Acidity (pH)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  _ph.toStringAsFixed(1),
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 13),
                ),
              ],
            ),
            Slider(
              value: _ph,
              min: 4.0,
              max: 9.0,
              divisions: 50,
              onChanged: (val) {
                setState(() => _ph = val);
              },
            ),
            const Divider(height: 24),
            // Rainfall Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Average Rainfall (mm)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  '${_rainfall.toInt()} mm',
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 13),
                ),
              ],
            ),
            Slider(
              value: _rainfall,
              min: 0,
              max: 300,
              onChanged: (val) {
                setState(() => _rainfall = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClimateCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined, color: colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Climate Metrics (Live Weather Synced)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const Divider(height: 20),
            // Temp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Air Temperature (°C)', style: TextStyle(fontSize: 12)),
                Text('${_temp.toStringAsFixed(1)}°C', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            Slider(
              value: _temp,
              min: 0.0,
              max: 50.0,
              onChanged: (val) {
                setState(() => _temp = val);
              },
            ),
            const SizedBox(height: 10),
            // Humidity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Air Humidity (%)', style: TextStyle(fontSize: 12)),
                Text('${_humidity.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            Slider(
              value: _humidity,
              min: 10.0,
              max: 100.0,
              onChanged: (val) {
                setState(() => _humidity = val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
