import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/presenters/auth_presenter.dart';
import 'package:weather_app/presenters/notification_presenter.dart';
import 'package:weather_app/services/fcm_service.dart';
import 'package:weather_app/services/token_service.dart';
import 'package:weather_app/theme.dart';
import 'package:weather_app/views/login_view.dart';
import 'package:weather_app/views/register_view.dart';
import 'package:weather_app/views/weather_view.dart';
import 'package:weather_app/views/notification_details_view.dart';
import 'package:weather_app/models/notification_payload.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  late PageController _pageController;
  late FCMService _fcmService;
  late TokenService _tokenService;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  NotificationPayload? _pendingNotification;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fcmService = FCMService();
    _tokenService = TokenService();
    
    // Установить callbacks для FCM
    _fcmService.setOnNotificationOpened(_handleNotificationOpened);
    _fcmService.setOnDeepLinkReceived(_handleDeepLink);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fcmService.dispose();
    super.dispose();
  }

  /// Обработчик открытия уведомления
  void _handleNotificationOpened(NotificationPayload payload) {
    print('[WeatherApp] Уведомление открыто: ${payload.cityRu}');
    
    _pendingNotification = payload;
    _navigateToNotificationDetails(payload);
  }

  /// Обработчик deep link
  void _handleDeepLink(String deepLinkType, Map<String, dynamic> params) {
    print('[WeatherApp] Deep link: $deepLinkType, params: $params');
    
    if (deepLinkType == 'notification_details' && params.containsKey('id')) {
      // Создаём payload из параметров
      final payload = NotificationPayload(
        id: params['id'],
        city: params['city'] ?? 'Unknown',
        cityRu: params['city_ru'] ?? 'Неизвестно',
        temp: double.tryParse(params['temp']?.toString() ?? '0') ?? 0.0,
        description: params['description'] ?? '',
        humidity: 0.0,
        windSpeed: 0.0,
      );
      
      _pendingNotification = payload;
      _navigateToNotificationDetails(payload);
    }
  }

  /// Навигация к деталям уведомления
  void _navigateToNotificationDetails(NotificationPayload payload) {
    // Если приложение уже загружено, используем navigator
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailsView(
          notification: payload,
          onClose: () {
            _pendingNotification = null;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: theme,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      home: Consumer2<AuthPresenter, NotificationPresenter>(
        builder: (context, authPresenter, notificationPresenter, _) {
          // Stream builder for real-time auth state changes
          return StreamBuilder(
            stream: authPresenter.authStateChanges,
            builder: (context, snapshot) {
              // If user is authenticated, show weather view
              if (snapshot.hasData && snapshot.data != null) {
                final uid = snapshot.data!.uid;
                
                // Инициализировать FCM и Token для авторизованного пользователя
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _initializeFCMForUser(uid);
                });
                
                // Установить uid для notification presenter
                notificationPresenter.setCurrentUser(uid);
                
                return WeatherView(
                  onLogout: () {
                    _pageController.jumpToPage(0);
                    _cleanupFCM();
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

  /// Инициализировать FCM для авторизованного пользователя
  Future<void> _initializeFCMForUser(String uid) async {
    try {
      // Инициализировать FCM
      await _fcmService.init();
      
      // Инициализировать Token service и сохранить токен
      await _tokenService.init();
      await _tokenService.saveCurrentUserToken(uid);
      
      print('[WeatherApp] FCM инициализирован для пользователя $uid');
    } catch (e) {
      print('[WeatherApp] Ошибка при инициализации FCM: $e');
    }
  }

  /// Очистка FCM при logout
  Future<void> _cleanupFCM() async {
    try {
      final authPresenter = context.read<AuthPresenter>();
      final uid = authPresenter.currentUser?.uid;
      
      if (uid != null) {
        await _tokenService.deleteCurrentUserToken(uid);
      }
      
      await _fcmService.dispose();
      _pendingNotification = null;
      
      print('[WeatherApp] FCM очищен при logout');
    } catch (e) {
      print('[WeatherApp] Ошибка при очистке FCM: $e');
    }
  }
}
