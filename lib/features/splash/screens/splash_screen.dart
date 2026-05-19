import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:apna_demand/features/auth/controllers/auth_controller.dart';
import 'package:apna_demand/features/cart/controllers/cart_controller.dart';
import 'package:apna_demand/features/splash/controllers/splash_controller.dart';
import 'package:apna_demand/features/notification/domain/models/notification_body_model.dart';
import 'package:apna_demand/helper/address_helper.dart';
import 'package:apna_demand/helper/auth_helper.dart';
import 'package:apna_demand/util/dimensions.dart';
import 'package:apna_demand/util/images.dart';
import 'package:apna_demand/common/widgets/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  final String? deeplinkUrl;
  const SplashScreen({
    super.key,
    required this.body,
    required this.deeplinkUrl,
  });

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (!mounted) {
        return;
      }
      bool isConnected =
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if (!firstTime) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
            context,
          );
          if (messenger == null) {
            firstTime = false;
            return;
          }
          if (isConnected) {
            messenger.hideCurrentSnackBar();
          }
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: isConnected ? Colors.green : Colors.red,
              duration: Duration(seconds: isConnected ? 3 : 6000),
              content: Text(
                isConnected ? 'connected'.tr : 'no_connection'.tr,
                textAlign: TextAlign.center,
              ),
            ),
          );
          if (isConnected) {
            print(
              '=========here coming-----1-->> ${Get.find<SplashController>().deeplinkRoute}',
            );
            if (Get.find<SplashController>().deeplinkRoute == null) {
              Get.find<SplashController>().getConfigData(
                notificationBody: widget.body,
              );
            }
          }
        });
      }

      firstTime = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Get.find<SplashController>().initSharedData();
      if ((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) &&
          Get.find<SplashController>().cacheModule != null) {
        Get.find<CartController>().getCartDataOnline();
      }
      // _route();
      print(
        '=========here coming-----2-->> ${Get.find<SplashController>().deeplinkRoute == null}',
      );
      if (Get.find<SplashController>().deeplinkRoute == null) {
        Get.find<SplashController>().getConfigData(
          notificationBody: widget.body,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged?.cancel();
  }

  // void _route() {
  //   Get.find<SplashController>().getConfigData().then((isSuccess) {
  //     if(isSuccess) {
  //       Timer(const Duration(seconds: 1), () async {
  //         double? minimumVersion = _getMinimumVersion();
  //         bool isMaintenanceMode = Get.find<SplashController>().configModel!.maintenanceMode!;
  //         bool needsUpdate = AppConstants.appVersion < minimumVersion!;
  //
  //         if(needsUpdate || isMaintenanceMode) {
  //           Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
  //         }else {
  //           if(widget.body != null) {
  //             _forNotificationRouteProcess(widget.body);
  //           }else {
  //             _handleUserRouting();
  //           }
  //         }
  //       });
  //     }
  //   });
  // }
  //
  // double? _getMinimumVersion() {
  //   if (GetPlatform.isAndroid) {
  //     return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
  //   } else if (GetPlatform.isIOS) {
  //     return Get.find<SplashController>().configModel!.appMinimumVersionIos;
  //   }
  //   return 0;
  // }
  //
  // void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
  //   final notificationType = notificationBody?.notificationType;
  //
  //   final Map<NotificationType, Function> notificationActions = {
  //     NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(widget.body!.orderId, fromNotification: true)),
  //     NotificationType.block: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
  //     NotificationType.unblock: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
  //     NotificationType.message: () =>  Get.toNamed(RouteHelper.getChatRoute(notificationBody: widget.body, conversationID: widget.body!.conversationId, fromNotification: true)),
  //     NotificationType.otp: () => null,
  //     NotificationType.add_fund: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
  //     NotificationType.referral_earn: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
  //     NotificationType.cashback: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
  //     NotificationType.loyalty_point: () => Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true)),
  //     NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
  //   };
  //
  //   notificationActions[notificationType]?.call();
  // }
  //
  // Future<void> _forLoggedInUserRouteProcess() async {
  //   Get.find<AuthController>().updateToken();
  //   if (AddressHelper.getUserAddressFromSharedPref() != null) {
  //     if(Get.find<SplashController>().module != null) {
  //       await Get.find<FavouriteController>().getFavouriteList();
  //     }
  //     Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  //   } else {
  //     Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
  //   }
  // }
  //
  // void _newlyRegisteredRouteProcess() {
  //   if(AppConstants.languages.length > 1) {
  //     Get.offNamed(RouteHelper.getLanguageRoute('splash'));
  //   }else {
  //     Get.offNamed(RouteHelper.getOnBoardingRoute());
  //   }
  // }
  //
  // void _forGuestUserRouteProcess() {
  //   if (AddressHelper.getUserAddressFromSharedPref() != null) {
  //     Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  //   } else {
  //     Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
  //   }
  // }
  //
  // Future<void> _handleUserRouting() async {
  //   if (AuthHelper.isLoggedIn()) {
  //     _forLoggedInUserRouteProcess();
  //   } else if (Get.find<SplashController>().showIntro() == true) {
  //     _newlyRegisteredRouteProcess();
  //   } else if (AuthHelper.isGuestLoggedIn()) {
  //     _forGuestUserRouteProcess();
  //   } else {
  //     await Get.find<AuthController>().guestLogin();
  //     _forGuestUserRouteProcess();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>().initSharedData();
    if (AddressHelper.getUserAddressFromSharedPref() != null &&
        AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(
        builder: (splashController) {
          return Center(
            child: splashController.hasConnection
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(Images.logo, width: 200),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],
                  )
                : NoInternetScreen(
                    child: SplashScreen(
                      body: widget.body,
                      deeplinkUrl: widget.deeplinkUrl,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
