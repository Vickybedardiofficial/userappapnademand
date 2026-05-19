import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apna_demand/helper/responsive_helper.dart';
import 'package:apna_demand/helper/route_helper.dart';
import 'package:apna_demand/util/dimensions.dart';
import 'package:apna_demand/util/styles.dart';

void showCartSnackBar() {
  final BuildContext? context = Get.context;
  if(context == null) {
    return;
  }

  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  if(messenger == null) {
    return;
  }

  messenger.showSnackBar(SnackBar(
    dismissDirection: DismissDirection.horizontal,
    margin: EdgeInsets.only(
      right: ResponsiveHelper.isDesktop(context) ? MediaQuery.sizeOf(context).width * 0.7 : Dimensions.paddingSizeSmall,
      top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall,
    ),
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
    content: Text('item_added_to_cart'.tr, style: robotoMedium.copyWith(color: Colors.white)),
    action: SnackBarAction(label: 'view_cart'.tr, onPressed: () => Get.toNamed(RouteHelper.getCartRoute()), textColor: Colors.white),
  ));

  Future.delayed(const Duration(seconds: 3), () {
    messenger.hideCurrentSnackBar();
  });
}
