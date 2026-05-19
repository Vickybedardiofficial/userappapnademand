import 'dart:async';
import 'dart:ui';
import 'package:app_links/app_links.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:apna_demand/features/auth/controllers/auth_controller.dart';
import 'package:apna_demand/features/cart/controllers/cart_controller.dart';
import 'package:apna_demand/features/language/controllers/language_controller.dart';
import 'package:apna_demand/features/splash/controllers/splash_controller.dart';
import 'package:apna_demand/common/controllers/theme_controller.dart';
import 'package:apna_demand/features/notification/domain/models/notification_body_model.dart';
import 'package:apna_demand/helper/address_helper.dart';
import 'package:apna_demand/helper/auth_helper.dart';
import 'package:apna_demand/helper/link_converter_helper.dart';
import 'package:apna_demand/helper/notification_helper.dart';
import 'package:apna_demand/helper/responsive_helper.dart';
import 'package:apna_demand/helper/route_helper.dart';
import 'package:apna_demand/theme/dark_theme.dart';
import 'package:apna_demand/theme/light_theme.dart';
import 'package:apna_demand/util/app_constants.dart';
import 'package:apna_demand/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:apna_demand/features/home/widgets/cookies_view.dart';
import 'helper/get_di.dart' as di;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_web_plugins/url_strategy.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }
  /*///Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };


  ///Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };*/

  if (GetPlatform.isWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyByJRiuHB7LJo6MvvRBVSjWjw7H9gqB9vw",
        authDomain: "apnademand-cb47f.firebaseapp.com",
        projectId: "apnademand-cb47f",
        storageBucket: "apnademand-cb47f.firebasestorage.app",
        messagingSenderId: "351307071676",
        appId: "1:351307071676:web:fae3817d9d3c8aed1390b9",
        measurementId: "G-DLQMC0RNS6",
      ),
    );
  } else if (GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCT3KzaiENFqm_B5UvimJ2P1_wyYgBsLhQ",
        appId: "1:351307071676:android:3af4637384924cad1390b9",
        messagingSenderId: "351307071676",
        projectId: "apnademand-cb47f",
        storageBucket: "apnademand-cb47f.firebasestorage.app",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "380903914182154",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

  // Web initialization moved to MyApp.initState() to ensure proper widget lifecycle

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  String? deeplinkRoute;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();

    if (!GetPlatform.isWeb) {
      _initAppLinks();
    }

    _route();

    _initialRoute = GetPlatform.isWeb
        ? RouteHelper.getInitialRoute()
        : RouteHelper.getSplashRoute(widget.body, deeplinkRoute);

    // Web platform initialization - delayed to prevent build phase conflicts
    if (kIsWeb) {
      // Add 2 frame delay to ensure widget tree is fully stable
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          Get.find<SplashController>().initSharedData();
          if (AddressHelper.getUserAddressFromSharedPref() != null &&
              AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
            Get.find<AuthController>().clearSharedAddress();
          }
          if (!AuthHelper.isLoggedIn() && !AuthHelper.isGuestLoggedIn()) {
            await Get.find<AuthController>().guestLogin();
          }
          await Get.find<SplashController>().getConfigData(
            loadLandingData:
                (AddressHelper.getUserAddressFromSharedPref() == null),
            fromMainFunction: true,
          );

          if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
              Get.find<SplashController>().cacheModule != null) {
            Get.find<CartController>().getCartDataOnline();
          }
        });
      });
    }
  }

  void _initAppLinks() async {
    _appLinks = AppLinks();

    // Listen for any subsequent incoming links
    _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          if (kDebugMode) {
            print(
              '=======Received URI: $uri and previous deeplinkRoute: ${Get.find<SplashController>().deeplinkRoute}',
            );
          }
          LinkConverter.convertDeepLink(uri);
        }
      },
      onError: (err) {
        if (kDebugMode) {
          print('catch Error in initAppLinksStream: $err');
        }
      },
    );
  }

  void _route() async {
    // Config data fetching logic moved to main() for seamless web initialize
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetBuilder<SplashController>(
              builder: (splashController) {
                return GetMaterialApp(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: Get.key,
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                    },
                  ),
                  theme: themeController.darkTheme ? dark() : light(),
                  locale: localizeController.locale,
                  translations: Messages(languages: widget.languages),
                  fallbackLocale: Locale(
                    AppConstants.languages[0].languageCode!,
                    AppConstants.languages[0].countryCode,
                  ),
                  initialRoute: _initialRoute,
                  getPages: RouteHelper.routes,
                  defaultTransition: GetPlatform.isWeb
                      ? Transition.fadeIn
                      : Transition.topLevel,
                  transitionDuration: const Duration(milliseconds: 700),
                  builder: (BuildContext context, widget) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(1)),
                      child: Material(
                        child: SafeArea(
                          top: false,
                          bottom: GetPlatform.isAndroid,
                          child: Stack(
                            children: [
                              widget!,

                              GetBuilder<SplashController>(
                                builder: (splashController) {
                                  final String cookieKey =
                                      splashController
                                          .configModel
                                          ?.cookiesText ??
                                      'cookies_default';
                                  if (!splashController.savedCookiesData &&
                                      !splashController.getAcceptCookiesStatus(
                                        cookieKey,
                                      )) {
                                    return ResponsiveHelper.isWeb()
                                        ? const Align(
                                            alignment: Alignment.bottomCenter,
                                            child: CookiesView(),
                                          )
                                        : const SizedBox();
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
