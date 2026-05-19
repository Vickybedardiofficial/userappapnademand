import 'package:apna_demand/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomBottomSheet({required Widget child, double? height}) {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final double logicalHeight = view.physicalSize.height / view.devicePixelRatio;
  Get.bottomSheet(
    ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height ?? logicalHeight * 0.8),
      child: child,
    ),
    isScrollControlled: true, useRootNavigator: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
    ),
  );
}
