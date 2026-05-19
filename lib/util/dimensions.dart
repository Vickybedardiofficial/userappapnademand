import 'package:flutter/widgets.dart';

class Dimensions {
  static bool get _isWideLayout {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final double logicalWidth = view.physicalSize.width / view.devicePixelRatio;
    return logicalWidth >= 1300;
  }

  static double get fontSizeOverSmall => _isWideLayout ? 10 : 8;
  static double get fontSizeExtraSmall => _isWideLayout ? 12 : 10;
  static double get fontSizeSmall => _isWideLayout ? 14 : 12;
  static double get fontSizeDefault => _isWideLayout ? 16 : 14;
  static double get fontSizeLarge => _isWideLayout ? 18 : 16;
  static double get fontSizeExtraLarge => _isWideLayout ? 20 : 18;
  static double get fontSizeOverLarge => _isWideLayout ? 26 : 24;

  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeSmall = 10.0;
  static const double paddingSizeDefault = 15.0;
  static const double paddingSizeLarge = 20.0;
  static const double paddingSizeExtraLarge = 25.0;
  static const double paddingSizeExtremeLarge = 30.0;
  static const double paddingSizeExtraOverLarge = 35.0;

  static const double radiusSmall = 5.0;
  static const double radiusMedium = 8.0;
  static const double radiusDefault = 10.0;
  static const double radiusLarge = 15.0;
  static const double radiusExtraLarge = 20.0;

  static const double webMaxWidth = 1170;
  static const int messageInputLength = 1000;

  static const double pickMapIconSize = 100.0;
}
