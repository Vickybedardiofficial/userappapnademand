import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveHelper {

  static double _fallbackLogicalWidth() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return view.physicalSize.width / view.devicePixelRatio;
  }

  static double _resolveWidth(BuildContext? context) {
    // Keep this context-independent to avoid inherited widget dependencies
    // from stale/global contexts (e.g. Get.context in async flows).
    return _fallbackLogicalWidth();
  }

  static bool isMobilePhone() {
    if (!kIsWeb) {
      return true;
    }else {
      return false;
    }
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isMobile(BuildContext? context) {
    final size = _resolveWidth(context);
    if (size < 650 || !kIsWeb) {
      return true;
    } else {
      return false;
    }
  }

  static bool isTab(BuildContext? context) {
    final size = _resolveWidth(context);
    if (size < 1300 && size >= 650) {
      return true;
    } else {
      return false;
    }
  }

  static bool isDesktop(BuildContext? context) {
    final size = _resolveWidth(context);
    if (size >= 1300) {
      return true;
    } else {
      return false;
    }
  }
}
