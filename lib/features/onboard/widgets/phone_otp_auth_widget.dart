import 'dart:async';
import 'package:apna_demand/common/widgets/custom_snackbar.dart';
import 'package:apna_demand/features/auth/controllers/auth_controller.dart';
import 'package:apna_demand/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:apna_demand/features/location/controllers/location_controller.dart';
import 'package:apna_demand/features/splash/controllers/splash_controller.dart';
import 'package:apna_demand/helper/route_helper.dart';
import 'package:apna_demand/util/dimensions.dart';
import 'package:apna_demand/util/images.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneOtpAuthWidget extends StatefulWidget {
  const PhoneOtpAuthWidget({super.key});

  @override
  State<PhoneOtpAuthWidget> createState() => _PhoneOtpAuthWidgetState();
}

class _PhoneOtpAuthWidgetState extends State<PhoneOtpAuthWidget> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _seconds = 30;
  bool _isOtpStep = false;
  String _countryDialCode = '+91';
  String _sentTo = '';

  @override
  void initState() {
    super.initState();
    _countryDialCode =
        CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel?.country ?? "IN",
        ).dialCode ??
        '+91';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  String _phoneWithCountryCode() {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return '$_countryDialCode$digits';
  }

  Future<void> _sendOtp() async {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) {
      showCustomSnackBar('Please enter valid phone number');
      return;
    }

    final phone = _phoneWithCountryCode();
    final response = await Get.find<AuthController>().sendOtp(
      emailOrPhone: phone,
    );
    if (response.isSuccess) {
      setState(() {
        _sentTo = phone;
        _isOtpStep = true;
      });
      _startTimer();
      _otpControllers.first.clear();
      for (final c in _otpControllers) {
        c.clear();
      }
      _otpFocusNodes.first.requestFocus();
    } else {
      showCustomSnackBar(response.message ?? 'OTP send failed');
    }
  }

  String _otpValue() => _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpValue().length != 6) {
      showCustomSnackBar('Please enter 6 digit OTP');
      return;
    }
    final response = await Get.find<AuthController>().verifyOtp(
      emailOrPhone: _sentTo,
      otp: _otpValue(),
    );
    if (response.isSuccess) {
      if (response.authResponseModel != null &&
          response.authResponseModel!.isPersonalInfo != true) {
        await Get.toNamed(
          RouteHelper.getNewUserSetupScreen(
            name: '',
            loginType: CentralizeLoginType.otp.name,
            phone: _sentTo,
            email: '',
            backFromThis: false,
          ),
        );
        return;
      }
      await Get.find<LocationController>().navigateToLocationScreen(
        RouteHelper.signIn,
        offNamed: true,
      );
    } else {
      showCustomSnackBar(response.message ?? 'OTP verify failed');
    }
  }

  void _handleOtpChanged(int index, String value) {
    final digit = value.replaceAll(RegExp(r'[^0-9]'), '');
    _otpControllers[index].text = digit.isNotEmpty
        ? digit[digit.length - 1]
        : '';
    _otpControllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: _otpControllers[index].text.length),
    );
    if (digit.isNotEmpty && index < _otpFocusNodes.length - 1) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (digit.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Widget _loginStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue with your number',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          'Existing user login and new user signup both happen in this same step',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                _countryDialCode,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: 'Enter mobile number',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Row(
          children: [
            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Or continue with',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => showCustomSnackBar(
                  'Google login already available in Sign In flow',
                ),
                icon: Image.asset(Images.google, width: 18, height: 18),
                label: const Text('Google'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => showCustomSnackBar(
                  'Apple login already available in Sign In flow',
                ),
                icon: Icon(
                  Icons.apple,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                label: const Text('Apple'),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        SizedBox(
          width: double.infinity,
          child: GetBuilder<AuthController>(
            builder: (authController) {
              return ElevatedButton(
                onPressed: authController.isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: authController.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _otpStep() {
    final bool canVerify = _otpValue().length == 6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _isOtpStep = false),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back'),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          'Verify OTP',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          'Code sent to $_sentTo',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_otpControllers.length, (index) {
            return SizedBox(
              width: 44,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(counterText: ''),
                onChanged: (value) => _handleOtpChanged(index, value),
              ),
            );
          }),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        SizedBox(
          width: double.infinity,
          child: GetBuilder<AuthController>(
            builder: (authController) {
              return ElevatedButton(
                onPressed: (canVerify && !authController.isLoading)
                    ? _verifyOtp
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: authController.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              );
            },
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _seconds > 0
                  ? 'Resend in 00:${_seconds.toString().padLeft(2, '0')}'
                  : 'OTP not received?',
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
            TextButton(
              onPressed: _seconds > 0 ? null : _sendOtp,
              child: const Text('Resend'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _isOtpStep ? _otpStep() : _loginStep(),
    );
  }
}
