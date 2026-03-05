import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/presenters/weather_presenter.dart';
import 'package:weather_app/presenters/auth_presenter.dart';
import 'package:weather_app/theme.dart';

class WeatherView extends StatefulWidget {
  final VoidCallback onLogout;

  const WeatherView({
    super.key,
    required this.onLogout,
  });

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Load initial weather data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WeatherPresenter>().loadWeather('Astana');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Погода',style: TextStyle(color: Colors.white,fontSize: 30)),
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<WeatherPresenter>(
        builder: (context, weatherPresenter, _) {
          final weather = weatherPresenter.currentWeather;
          final weekWeather = weatherPresenter.weekWeather ?? [];
          final isLoading = weatherPresenter.isLoading;
          final weatherType = weather?.type ?? 'Clear';

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getWeatherBackgroundAsset(weatherType)),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              // Dark overlay
              color: Colors.black.withValues(alpha: 0.4),
              child: isLoading && weather == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                      children: [
                        // Search field
                        TextField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              weatherPresenter.loadWeather(value);
                            }
                          },
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Поиск города',
                            hintStyle: const TextStyle(
                              color: Colors.white70,
                            ),
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.2),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 40),

                        // Current weather card
                        if (weather != null)
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Weather icon
                                Image.network(
                                  "https://openweathermap.org/img/wn/${weather.icon}@4x.png",
                                  height: 120,
                                  width: 240,
                                ),
                                const SizedBox(height: 20),
                                // City
                                Text(
                                  weatherPresenter.currentCity,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                // Temperature
                                Text(
                                  "${weather.temp}°",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 72,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Max/Min
                                Text(
                                  "Макс: ${weather.maxTemp}° Мин: ${weather.minTemp}°",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (!isLoading)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Не удалось загрузить погоду',
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 40),

                        // Weekly forecast
                        if (weekWeather.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Прогноз на неделю',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const
                                      NeverScrollableScrollPhysics(),
                                  itemCount:
                                      weekWeather.length,
                                  itemBuilder: (context, i) {
                                    final day =
                                        weekWeather[i];
                                    return Container(
                                      margin: const EdgeInsets
                                          .only(bottom: 10),
                                      padding:
                                          const EdgeInsets
                                              .all(12),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors.white
                                            .withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          12,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.network(
                                            "https://openweathermap.org/img/wn/${day.icon}@2x.png",
                                            width: 50,
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  "${day.weekday}",
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors
                                                            .white,
                                                    fontSize:
                                                        14,
                                                    fontWeight:
                                                        FontWeight
                                                            .w500,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  "${day.maxTemp}° / ${day.minTemp}°",
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors
                                                            .white70,
                                                    fontSize:
                                                        13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            "${day.temp}°",
                                            style:
                                                const TextStyle(
                                              color: Colors
                                                  .white,
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }

  /// Get weather background asset based on weather type
  String _getWeatherBackgroundAsset(String weatherType) {
    switch (weatherType.toLowerCase()) {
      case 'clear':
        return 'assets/Clear.png';
      case 'clouds':
        return 'assets/Clouds.png';
      case 'rain':
      case 'drizzle':
        return 'assets/Rain.png';
      case 'snow':
        return 'assets/Snow.png';
      case 'thunderstorm':
        return 'assets/Thunderstorm.png';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return 'assets/Mist.png';
      default:
        return 'assets/Clear.png';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Выход'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthPresenter>().logout();
                widget.onLogout();
              },
              child: const Text(
                'Выход',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
