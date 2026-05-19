import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apna_demand/common/widgets/custom_button.dart';
import 'package:apna_demand/common/widgets/custom_text_field.dart';
import 'package:apna_demand/features/auth/controllers/auth_controller.dart';
import 'package:apna_demand/features/auth/widgets/social_login_widget.dart';
import 'package:apna_demand/features/language/controllers/language_controller.dart';
import 'package:apna_demand/helper/responsive_helper.dart';
import 'package:apna_demand/helper/validate_check.dart';
import 'package:apna_demand/util/dimensions.dart';
import 'package:apna_demand/util/styles.dart';

class OtpLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final bool socialEnable;
  final bool backFromThis;
  const OtpLoginWidget({super.key, required this.phoneController, required this.phoneFocus, required this.onCountryChanged, required this.countryDialCode,
    required this.onClickLoginButton, this.socialEnable = false, required this.backFromThis});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : 16, vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          
          Text('Log in with your number', style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).textTheme.bodyLarge!.color)),
          const SizedBox(height: 6),
          Text('We\'ll send a secure verification code', style: robotoRegular.copyWith(fontSize: 14, color: Theme.of(context).disabledColor)),
          const SizedBox(height: 28),

          CustomTextField(
            hintText: 'Enter 10-digit number',
            controller: phoneController,
            focusNode: phoneFocus,
            inputAction: TextInputAction.done,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: onCountryChanged,
            countryDialCode: countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(child: Container(height: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR CONTINUE WITH', style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).disabledColor, letterSpacing: 0.5)),
              ),
              Expanded(child: Container(height: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.2))),
            ],
          ),
          const SizedBox(height: 24),

          socialEnable ? SocialLoginWidget(onlySocialLogin: false, backFromThis: backFromThis, showWelcomeText: false) : const SizedBox(),

          const SizedBox(height: 24),

          CustomButton(
            buttonText: 'Continue', // HTML uses Continue instead of Login
            radius: 16,
            height: 54,
            isBold: true,
            isLoading: authController.isLoading,
            onPressed: onClickLoginButton,
            fontSize: 16,
            icon: Icons.arrow_forward,
          ),
          
          const SizedBox(height: 24),
          
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).disabledColor, height: 1.6),
                children: [
                  const TextSpan(text: 'By continuing, you agree to our\n'),
                  TextSpan(text: 'Terms of Service', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  const TextSpan(text: ' & '),
                  TextSpan(text: 'Privacy Policy', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),

        ]),
      );
    });
  }
}
