import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/services/weather_service.dart';
import '../../profile/providers/app_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _currentWeather;
  bool _isLoadingWeather = true;
  late List<FarmingTip> _tips;
  late FarmingTip _tipOfTheDay;

  @override
  void initState() {
    super.initState();
    _tips = _weatherService.getFarmingTips();
    _tipOfTheDay = _tips[DateTime.now().day % _tips.length];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeather();
    });
  }

  Future<void> _loadWeather() async {
    if (!mounted) return;
    setState(() {
      _isLoadingWeather = true;
    });

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final weather = await _weatherService.fetchLiveWeather(
      locationName: appProvider.farmerLocation,
    );

    if (mounted) {
      setState(() {
        _currentWeather = weather;
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _refreshWeather() async {
    await _loadWeather();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live weather parameters updated!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showLocationSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Local Weather'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter City (e.g. Faridabad, Delhi, London)',
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final query = searchController.text.trim();
                if (query.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() {
                    _isLoadingWeather = true;
                  });
                  final weather = await _weatherService.fetchWeatherByCity(query);
                  if (mounted) {
                    setState(() {
                      _currentWeather = weather;
                      _isLoadingWeather = false;
                    });
                  }
                }
              },
              child: const Text('Search'),
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
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('AgriVision AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => _showNotifications(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWeather,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildHeader(context, appProvider),
              const SizedBox(height: 20),

              // Weather Card
              _buildWeatherCard(context),
              const SizedBox(height: 24),

              // Quick Actions (Now Realignment for 6 items)
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Farming Tip of the day
              _buildTipCard(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          child: Icon(Icons.account_circle, size: 40, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${provider.farmerName.split(' ').first}!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'Healthy leaves mean high yields.',
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoadingWeather || _currentWeather == null) {
      return Card(
        elevation: 0,
        color: colorScheme.primaryContainer.withOpacity(0.2),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Fetching Live Weather Parameters...',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final weather = _currentWeather!;
    IconData weatherIcon;
    switch (weather.condition.toLowerCase()) {
      case 'sunny':
        weatherIcon = Icons.wb_sunny_rounded;
        break;
      case 'cloudy':
      case 'partly cloudy':
        weatherIcon = Icons.cloud_rounded;
        break;
      case 'drizzling':
      case 'rainy':
      case 'rain showers':
        weatherIcon = Icons.grain_rounded;
        break;
      case 'foggy':
        weatherIcon = Icons.blur_on;
        break;
      case 'thunderstorm':
        weatherIcon = Icons.thunderstorm;
        break;
      default:
        weatherIcon = Icons.wb_cloudy_rounded;
    }

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.35),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              weather.location,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.search, size: 20, color: colorScheme.primary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Search City Weather',
                            onPressed: () => _showLocationSearchDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weather.temperature}°C',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        weather.condition,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Icon(weatherIcon, size: 80, color: Colors.amber.shade700),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherStat(
                  context,
                  Icons.water_drop,
                  'Humidity',
                  '${weather.humidity}%',
                ),
                _buildWeatherStat(
                  context,
                  Icons.grass,
                  'Soil Moist',
                  '${weather.soilMoisture}%',
                ),
                _buildWeatherStat(
                  context,
                  Icons.umbrella,
                  'Rain Chance',
                  weather.rainChance,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherStat(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: [
        _buildActionCard(
          context,
          Icons.center_focus_strong_rounded,
          'Scan Disease',
          'Diagnose crops',
          Colors.green,
          () => context.go('/?tab=1'),
        ),
        _buildActionCard(
          context,
          Icons.bug_report_rounded,
          'Pest Detector',
          'Identify insects',
          Colors.red,
          () => context.go('/pest-scan'),
        ),
        _buildActionCard(
          context,
          Icons.yard_rounded,
          'Weed Detector',
          'Identify weeds',
          Colors.orange,
          () => context.go('/weed-scan'),
        ),
        _buildActionCard(
          context,
          Icons.auto_awesome,
          'Crop Recommend',
          'AI Soil Advisor',
          Colors.teal,
          () => context.go('/crop-recommendation'),
        ),
        _buildActionCard(
          context,
          Icons.menu_book_rounded,
          'Crop Guide',
          'Offline manual',
          Colors.blue,
          () => context.go('/crop-guide'),
        ),
        _buildActionCard(
          context,
          Icons.forum_rounded,
          'Agri Community',
          'Farmer forum',
          Colors.purple,
          () => context.go('/community'),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Farming Tip of the Day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _tipOfTheDay.category,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _tipOfTheDay.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              _tipOfTheDay.content,
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Alerts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              _buildNotificationItem(
                context,
                Icons.warning_amber_rounded,
                'Weather Alert',
                'Precipitation levels suggest high humidity today. Protect your tomato crops from potential leaf blight.',
                Colors.orange,
              ),
              _buildNotificationItem(
                context,
                Icons.eco,
                'Weekly Scout Reminder',
                'Time to inspect fields. Check leaf structures for potential spots and lesions.',
                Colors.green,
              ),
              _buildNotificationItem(
                context,
                Icons.chat,
                'Assistant Tip',
                'Ask Agri AI chatbot how to prepare high-quality compost for nitrogen boost.',
                Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    IconData icon,
    String title,
    String body,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
