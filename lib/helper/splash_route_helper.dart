import 'package:get/get.dart';
import 'package:apna_demand/features/auth/controllers/auth_controller.dart';
import 'package:apna_demand/features/favourite/controllers/favourite_controller.dart';
import 'package:apna_demand/features/location/controllers/location_controller.dart';
import 'package:apna_demand/features/notification/domain/models/notification_body_model.dart';
import 'package:apna_demand/features/splash/controllers/splash_controller.dart';
import 'package:apna_demand/helper/address_helper.dart';
import 'package:apna_demand/helper/auth_helper.dart';
import 'package:apna_demand/helper/notification_helper.dart';
import 'package:apna_demand/helper/route_helper.dart';
import 'package:apna_demand/util/app_constants.dart';

// class SplashRouteHelper{

  void route({NotificationBodyModel? body}) {
    double? minimumVersion = _getMinimumVersion();
    bool isMaintenanceMode = Get.find<SplashController>().configModel!.maintenanceMode!;
    bool needsUpdate = AppConstants.appVersion < minimumVersion!;

    if(needsUpdate || isMaintenanceMode) {
      Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
    }else if(!GetPlatform.isWeb){
      if(body != null) {
        _forNotificationRouteProcess(body);
      }else {
        _handleUserRouting();
      }
    }
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }
    return 0;
  }

  void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
    final notificationType = notificationBody?.notificationType;

    final Map<NotificationType, Function> notificationActions = {
      NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationBody!.orderId, fromNotification: true)),
      NotificationType.block: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
      NotificationType.unblock: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
      NotificationType.message: () =>  Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationID: notificationBody!.conversationId, fromNotification: true)),
      NotificationType.otp: () => null,
      NotificationType.add_fund: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
      NotificationType.referral_earn: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
      NotificationType.cashback: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
      NotificationType.loyalty_point: () => Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true)),
      NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
      NotificationType.ride_request: () async {
        if(notificationBody != null) {
          // Convert NotificationBodyModel to Map for notificationRouteCheck
          Map<String, dynamic> notificationData = {
            'type': 'ride_request',
            'action': notificationBody.action,
            'ride_request_id': notificationBody.rideRequestId,
            'next_level': notificationBody.nextLevel,
            'reward_amount': notificationBody.rewardAmount,
            'reward_type': notificationBody.rewardType,
          };
          await NotificationHelper.rideNotificationRouteCheck(notificationData, formSplash: true);
        }
      },
    };

    notificationActions[notificationType]?.call();
  }

  Future<void> _forLoggedInUserRouteProcess() async {
    Get.find<AuthController>().updateToken();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      if(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() != AppConstants.ride) {
        await Get.find<FavouriteController>().getFavouriteList();
      }
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  void _newlyRegisteredRouteProcess() {
    if(AppConstants.languages.length > 1) {
      Get.offNamed(RouteHelper.getLanguageRoute('splash'));
    }else {
      // Unified the flow, routing directly to the new visual wrapper of SignInScreen
      Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
    }
  }

  void _forGuestUserRouteProcess() {
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  Future<void> _handleUserRouting() async {
    if (AuthHelper.isLoggedIn()) {
      _forLoggedInUserRouteProcess();
    } else if (Get.find<SplashController>().showIntro() == true) {
      _newlyRegisteredRouteProcess();
    } else if (AuthHelper.isGuestLoggedIn()) {
      _forGuestUserRouteProcess();
    } else {
      await Get.find<AuthController>().guestLogin();
      _forGuestUserRouteProcess();
    }
  }
// }
