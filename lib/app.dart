import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/presenters/auth_presenter.dart';
import 'package:weather_app/theme.dart';
import 'package:weather_app/views/login_view.dart';
import 'package:weather_app/views/register_view.dart';
import 'package:weather_app/views/weather_view.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthPresenter>(
        builder: (context, authPresenter, _) {
          // Stream builder for real-time auth state changes
          return StreamBuilder(
            stream: authPresenter.authStateChanges,
            builder: (context, snapshot) {
              // If user is authenticated, show weather view
              if (snapshot.hasData && snapshot.data != null) {
                return WeatherView(
                  onLogout: () {
                    _pageController.jumpToPage(0);
                  },
                );
              }

              // If user is not authenticated, show auth pages
              return PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Login page
                  LoginView(
                    onLoginSuccess: () {
                      // Navigation will be handled by StreamBuilder
                    },
                    onNavigateToRegister: () {
                      _pageController.nextPage(
                        duration:
                            const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  // Register page
                  RegisterView(
                    onRegisterSuccess: () {
                      // Navigation will be handled by StreamBuilder
                    },
                    onNavigateToLogin: () {
                      _pageController.previousPage(
                        duration:
                            const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
