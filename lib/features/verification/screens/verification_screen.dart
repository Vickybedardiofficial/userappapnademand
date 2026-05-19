import 'dart:async';
import 'package:apna_demand/common/models/response_model.dart';
import 'package:apna_demand/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:apna_demand/features/auth/screens/new_user_setup_screen.dart';
import 'package:apna_demand/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:apna_demand/features/location/controllers/location_controller.dart';
import 'package:apna_demand/features/profile/controllers/profile_controller.dart';
import 'package:apna_demand/features/profile/domain/models/update_user_model.dart';
import 'package:apna_demand/features/auth/controllers/auth_controller.dart';
import 'package:apna_demand/features/verification/controllers/verification_controller.dart';
import 'package:apna_demand/features/verification/domein/enum/verification_type_enum.dart';
import 'package:apna_demand/features/verification/domein/models/verification_data_model.dart';
import 'package:apna_demand/features/verification/screens/new_pass_screen.dart';
import 'package:apna_demand/helper/auth_helper.dart';
import 'package:apna_demand/helper/responsive_helper.dart';
import 'package:apna_demand/helper/route_helper.dart';
import 'package:apna_demand/util/dimensions.dart';
import 'package:apna_demand/util/styles.dart';
import 'package:apna_demand/common/widgets/custom_button.dart';
import 'package:apna_demand/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  final String? number;
  final String? email;
  final bool fromSignUp;
  final String? token;
  final String? password;
  final String loginType;
  final String? firebaseSession;
  final bool fromForgetPassword;
  final UpdateUserModel? userModel;
  final bool backFromThis;
  const VerificationScreen({super.key, required this.number, required this.password, required this.fromSignUp,
    required this.token, this.email, required this.loginType, this.firebaseSession, required this.fromForgetPassword,
    this.userModel, this.backFromThis = false});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _number;
  String? _email;
  Timer? _timer;
  int _seconds = 0;
  final ScrollController _scrollController = ScrollController();
  late StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();

    Get.find<VerificationController>().updateVerificationCode('', canUpdate: false);
    if(widget.number != null && widget.number!.isNotEmpty) {
      _number = widget.number!.startsWith('+') ? widget.number : '+${widget.number!.substring(1, widget.number!.length)}';
    }
    _email = widget.email;
    _startTimer();

    errorController = StreamController<ErrorAnimationType>();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
    errorController.close();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    double borderWidth = 0.7;
    return Scaffold(
      appBar: isDesktop ? null : null, // AppBar removed for custom back button
      backgroundColor: isDesktop ? Colors.transparent : Theme.of(context).cardColor,
      body: SafeArea(child: Center(child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Center(child: Container(
          width: context.width > 700 ? 500 : context.width,
          padding: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
          decoration: context.width > 700 ? BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ) : null,
          child: GetBuilder<VerificationController>(builder: (verificationController) {
            return Column(children: [

              // Custom Back Button for Mobile if not Desktop
              !isDesktop ? Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 44, width: 44,
                    decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge!.color, size: 18),
                  ),
                ),
              ) : const SizedBox(),
              const SizedBox(height: 24),

              // Security Badge
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                   decoration: BoxDecoration(
                     color: const Color(0xFFf0fdf4),
                     border: Border.all(color: const Color(0xFFbbf7d0)),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Row(mainAxisSize: MainAxisSize.min, children: [
                     const Icon(Icons.security, color: Color(0xFF16a34a), size: 14),
                     const SizedBox(width: 6),
                     Text('BANK-GRADE SECURITY', style: robotoBold.copyWith(fontSize: 11, color: const Color(0xFF15803d), letterSpacing: 0.5)),
                   ]),
                ),
              ),
              const SizedBox(height: 24),

              // Title and Subtitle
              Align(
                alignment: Alignment.centerLeft,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Verify OTP', style: robotoBold.copyWith(fontSize: 32, color: Theme.of(context).textTheme.bodyLarge!.color)),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: robotoRegular.copyWith(fontSize: 15, color: Theme.of(context).disabledColor),
                      children: [
                        const TextSpan(text: 'Code sent to '),
                        TextSpan(text: '${(_email != null && _email!.isNotEmpty) ? _email : _number}', style: robotoBold.copyWith(color: const Color(0xFF16a34a))),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.width > 850 ? 50 : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
                child: PinCodeTextField(
                  length: 6,
                  appContext: context,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.slide,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    fieldHeight: 64,
                    fieldWidth: 56,
                    borderWidth: 2,
                    borderRadius: BorderRadius.circular(16),
                    selectedColor: const Color(0xFF22c55e),
                    selectedFillColor: Colors.white,
                    inactiveFillColor: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                    inactiveColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                    activeColor: hasError ? Colors.orange : const Color(0xFF22c55e),
                    activeFillColor: const Color(0xFFf0fdf4), // light green when filled
                    inactiveBorderWidth: 2,
                    selectedBorderWidth: 2,
                    disabledBorderWidth: borderWidth,
                    errorBorderWidth: 2,
                    activeBorderWidth: 2,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  onChanged: verificationController.updateVerificationCode,
                  beforeTextPaste: (text) => true,
                  errorAnimationController: errorController, // Optional: Custom error animation
                  errorTextSpace: 20, // Space for error text
                  errorTextMargin: const EdgeInsets.only(top: 10),
                ),
              ),
              // const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                hasError ? errorMessage : "",
                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              GetBuilder<ProfileController>(builder: (profileController) {
                return CustomButton(
                  radius: 16,
                  height: 54,
                  isBold: true,
                  fontSize: 16,
                  buttonText: 'Continue',
                  isLoading: verificationController.isLoading || profileController.isLoading,
                  onPressed: verificationController.verificationCode.length < 6 ? null : () {
                    if(widget.firebaseSession != null && widget.userModel == null) {
                      verificationController.verifyFirebaseOtp(
                        phoneNumber: _number!, session: widget.firebaseSession!, loginType: widget.loginType,
                        otp: verificationController.verificationCode, token: widget.token, isForgetPassPage: widget.fromForgetPassword,
                        isSignUpPage: widget.loginType == CentralizeLoginType.otp.name ? false : true,
                      ).then((value) {
                        if(value.isSuccess) {
                          _handleVerifyResponse(value, _number, _email);
                        }else {
                          showCustomSnackBar(value.message);
                        }
                      });
                    } else if(widget.userModel != null) {
                      widget.userModel!.otp = verificationController.verificationCode;
                      Get.find<ProfileController>().updateUserInfo(widget.userModel!, Get.find<AuthController>().getUserToken(), fromButton: true);
                    }
                    else if(widget.fromSignUp) {
                      verificationController.verifyPhone(data: VerificationDataModel(
                        phone: _number, email: _email, verificationType: _number != null
                          ? VerificationTypeEnum.phone.name : VerificationTypeEnum.email.name,
                        otp: verificationController.verificationCode, loginType: widget.loginType,
                        guestId: AuthHelper.getGuestId(),
                      )).then((value) {
                        if(value.isSuccess) {
                          _handleVerifyResponse(value, _number, _email);
                        } else {
                          showCustomSnackBar(value.message);
                        }
                      });
                    } else {
                      verificationController.verifyToken(phone: _number, email: _email).then((value) {
                        if(value.isSuccess) {
                          if(ResponsiveHelper.isDesktop(context)){
                            Get.back();
                            Get.dialog(Center(child: NewPassScreen(resetToken: verificationController.verificationCode, number : _number, email: _email, fromPasswordChange: false, fromDialog: true )));
                          }else{
                            Get.toNamed(RouteHelper.getResetPasswordRoute(phone: _number, email: _email, token: verificationController.verificationCode, page: 'reset-password'));
                          }
                        }else {
                          errorController.add(ErrorAnimationType.shake);
                          errorMessage = value.message??'';
                          setState(() {
                            hasError = true;
                          });
                          showCustomSnackBar(value.message);
                        }
                      });
                    }
                  },
                );
              }),
              const SizedBox(height: 24),

              // Divider for Timer
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                 Text('Resend in ', style: robotoRegular.copyWith(fontSize: 14, color: Theme.of(context).disabledColor)),
                 Text(
                   '00:${_seconds.toString().padLeft(2, '0')}',
                   style: robotoBold.copyWith(fontSize: 18, color: const Color(0xFF16a34a)),
                 ),
              ]),
              const SizedBox(height: 16),
              
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                InkWell(
                  onTap: _seconds < 1 ? () async {
                    if(widget.firebaseSession != null) {
                      await Get.find<AuthController>().firebaseVerifyPhoneNumber(_number!, widget.token, widget.loginType, fromSignUp: widget.fromSignUp, canRoute: false);
                      _startTimer();
                    } else {
                      _resendOtp();
                    }
                  } : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(14)
                    ),
                    child: Row(children: [
                       const Icon(Icons.message, color: Color(0xFF16a34a), size: 14),
                       const SizedBox(width: 8),
                       Text('SMS', style: robotoMedium.copyWith(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge!.color))
                    ]),
                  )
                ),
              ]),
              const SizedBox(height: 32),

              // Auto detect panel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFeff6ff),
                  border: Border.all(color: const Color(0xFFdbeafe)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    height: 48, width: 48,
                    decoration: BoxDecoration(color: const Color(0xFFdbeafe), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.mobile_friendly, color: Color(0xFF2563eb)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Auto-detecting OTP', style: robotoBold.copyWith(fontSize: 14, color: const Color(0xFF1e40af))),
                      const SizedBox(height: 4),
                      Text('Reading SMS securely...', style: robotoRegular.copyWith(fontSize: 12, color: const Color(0xFF3b82f6))),
                      const SizedBox(height: 12),
                      Container(
                        height: 4, width: double.infinity,
                        decoration: BoxDecoration(color: const Color(0xFFbfdbfe), borderRadius: BorderRadius.circular(10)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.5, // 50% width simulation
                          child: Container(decoration: BoxDecoration(color: const Color(0xFF3b82f6), borderRadius: BorderRadius.circular(10))),
                        )
                      )
                    ])
                  )
                ])
              ),

            ]);
          }),
        )),
      ))),
    );
  }

  void _handleVerifyResponse(ResponseModel response, String? number, String? email) {
    if(response.authResponseModel != null && response.authResponseModel!.isExistUser != null) {
      if(ResponsiveHelper.isDesktop(context)) {
        Get.back();
        Get.dialog(Center(
          child: ExistingUserBottomSheet(
            userModel: response.authResponseModel!.isExistUser!, number: _number, email: _email,
            loginType: widget.loginType, otp: Get.find<VerificationController>().verificationCode,
            backFromThis: widget.backFromThis,
          ),
        ));
      } else {
        Get.bottomSheet(ExistingUserBottomSheet(
          userModel: response.authResponseModel!.isExistUser!, number: _number, email: _email,
          loginType: widget.loginType, otp: Get.find<VerificationController>().verificationCode,
          backFromThis: widget.backFromThis,
        ));
      }
    } else if(response.authResponseModel != null && !response.authResponseModel!.isPersonalInfo!) {
      if(ResponsiveHelper.isDesktop(context)) {
        Get.back();
        Get.dialog(NewUserSetupScreen(name: '', loginType: widget.loginType, phone: number, email: email, backFromThis: widget.backFromThis));
      } else {
        Get.toNamed(RouteHelper.getNewUserSetupScreen(name: '', loginType: widget.loginType, phone: number, email: email, backFromThis: widget.backFromThis));
      }
    } else {

      if(widget.fromForgetPassword) {
        Get.toNamed(RouteHelper.getResetPasswordRoute(phone: _number, email: _email, token: Get.find<VerificationController>().verificationCode, page: 'reset-password'));
      } else {
        if(widget.backFromThis) {
          Get.find<LocationController>().syncZoneData();
          Get.back();
          Get.back();
        } else {
          Get.find<LocationController>().navigateToLocationScreen('verification', offNamed: true);
        }
      }
    }
  }

  void _resendOtp() {
    if(widget.userModel != null) {
      Get.find<ProfileController>().updateUserInfo(widget.userModel!, Get.find<AuthController>().getUserToken(), fromVerification: true);
    } else if(widget.fromSignUp) {
      if(widget.loginType == CentralizeLoginType.otp.name) {
        Get.find<AuthController>().otpLogin(phone: _number!, otp: '', loginType: widget.loginType, verified: '').then((response) {
          if (response.isSuccess) {
            _startTimer();
            showCustomSnackBar('resend_code_successful'.tr, isError: false);
          } else {
            showCustomSnackBar(response.message);
          }
        });
      } else {
        Get.find<AuthController>().login(
          emailOrPhone: _number != null ? _number! : _email ?? '', password: widget.password!, loginType: widget.loginType,
          fieldType: _number != null ? VerificationTypeEnum.phone.name : VerificationTypeEnum.email.name,
        ).then((value) {
          if (value.isSuccess) {
            _startTimer();
            showCustomSnackBar('resend_code_successful'.tr, isError: false);
          } else {
            showCustomSnackBar(value.message);
          }
        });
      }
    } else {
      Get.find<VerificationController>().forgetPassword(phone: _number, email: _email).then((value) {
        if (value.isSuccess) {
          _startTimer();
          showCustomSnackBar('resend_code_successful'.tr, isError: false);
        } else {
          showCustomSnackBar(value.message);
        }
      });
    }
  }
}
