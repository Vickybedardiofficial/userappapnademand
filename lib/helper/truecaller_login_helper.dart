import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:apna_demand/features/auth/controllers/auth_controller.dart';
import 'package:apna_demand/features/auth/domain/models/social_log_in_body.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

class TruecallerLoginHelper {
  /// Initialize this in your SignInScreen's initState()
  static void initTruecallerAutoDetect() {
    if (!GetPlatform.isAndroid) return;

    // Step 1: Initialize SDK with the new v1.2.0 OAuth API
    // TcSdkOptions.OPTION_VERIFY_ONLY_TC_USERS = verify only users with Truecaller app
    TcSdk.initializeSDK(sdkOption: TcSdkOptions.OPTION_VERIFY_ONLY_TC_USERS);

    // Step 2: Check if the OAuth flow is usable on this device
    TcSdk.isOAuthFlowUsable.then((isUsable) {
      if (isUsable) {
        // Step 3: Set up required OAuth parameters before invoking consent screen
        final String oAuthState = DateTime.now().millisecondsSinceEpoch.toString();
        TcSdk.setOAuthState(oAuthState);
        TcSdk.setOAuthScopes(['profile', 'phone', 'openid']);

        // Generate code verifier & challenge (PKCE)
        TcSdk.generateRandomCodeVerifier.then((codeVerifier) {
          TcSdk.generateCodeChallenge(codeVerifier).then((codeChallenge) {
            if (codeChallenge != null) {
              TcSdk.setCodeChallenge(codeChallenge);
              // Step 4: Show the Truecaller consent / authorization screen
              TcSdk.getAuthorizationCode;
            } else {
              debugPrint('Truecaller: Code challenge is null, device not supported');
            }
          });
        });
      } else {
        debugPrint('Truecaller: OAuth flow not usable on this device');
      }
    });

    // Step 5: Listen for the result of getAuthorizationCode
    TcSdk.streamCallbackData.listen((tcSdkCallback) {
      switch (tcSdkCallback.result) {
        case TcSdkCallbackResult.success:
          // Success: we received an OAuth authorization code.
          // Pass it to backend as the token (mirrors Next.js Truecaller flow).
          final String authCode = tcSdkCallback.tcOAuthData?.authorizationCode ?? '';
          if (authCode.isNotEmpty) {
            _processTruecallerAuth(authCode);
          }
          break;

        case TcSdkCallbackResult.failure:
          // User dismissed or an error occurred — fall back to manual login.
          debugPrint('Truecaller: failure – code: ${tcSdkCallback.error?.code}, '
              'msg: ${tcSdkCallback.error?.message}');
          break;

        case TcSdkCallbackResult.verification:
          // User does not have Truecaller app; manual verification required.
          debugPrint('Truecaller: manual verification required');
          break;

        default:
          break;
      }
    }, onError: (error) {
      debugPrint('Truecaller Error: $error');
    });
  }

  /// Sends the Truecaller OAuth authorization code to the backend
  /// using the same social-login path as the Next.js frontend.
  static void _processTruecallerAuth(String authorizationCode) {
    SocialLogInBody truecallerPayload = SocialLogInBody(
      email: null,
      token: authorizationCode,
      uniqueId: 'tc_oauth_$authorizationCode',
      medium: 'truecaller',
      phone: null,
    );

    Get.find<AuthController>().loginWithSocialMedia(truecallerPayload);
  }
}
