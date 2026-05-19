import 'dart:async';
import 'dart:io';
import 'package:apna_demand/helper/truecaller_login_helper.dart';
import 'package:apna_demand/features/auth/controllers/auth_controller.dart';
import 'package:apna_demand/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:apna_demand/helper/responsive_helper.dart';
import 'package:apna_demand/helper/route_helper.dart';
import 'package:apna_demand/util/dimensions.dart';
import 'package:apna_demand/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromNotification;
  final bool fromResetPassword;
  final bool? fromRideDialog;
  const SignInScreen({super.key, required this.exitFromApp, required this.backFromThis, this.fromNotification = false, this.fromResetPassword = false, this.fromRideDialog});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();
    TruecallerLoginHelper.initTruecallerAutoDetect();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromNotification || widget.fromResetPassword) {
          Navigator.pushNamed(context, RouteHelper.getInitialRoute());
        } else if(widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else {
          if(Get.find<AuthController>().isOtpViewEnable){
            Get.find<AuthController>().enableOtpView(enable: false);
          }else{
            // Get.back();
          }
        }
      },
      child: Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
        appBar: (ResponsiveHelper.isDesktop(context) ? null : !widget.exitFromApp ? AppBar(leading: IconButton(
            onPressed: () {
              if(widget.fromNotification || widget.fromResetPassword) {
                Navigator.pushNamed(context, RouteHelper.getInitialRoute());
              }else if(Get.find<AuthController>().isOtpViewEnable){
                Get.find<AuthController>().enableOtpView(enable: false);
              }else{
                Get.back(result: false);
              }
            },
            icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
          elevation: 0, backgroundColor: Theme.of(context).cardColor, actions: const [SizedBox()],
        ) : null),
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,

        body: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: context.width > 700 ? 500 : context.width,
              padding: context.width > 700 ? const EdgeInsets.all(50) : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
              margin: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
              decoration: context.width > 700 ? BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: ResponsiveHelper.isDesktop(context) ? null : const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
              ) : null,
              child: SingleChildScrollView(
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                  ResponsiveHelper.isDesktop(context) ? Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.clear),
                    ),
                  ) : const SizedBox(),

                  // Hero Image from HTML Template
                  Container(
                    height: 280,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800&auto=format&fit=crop&q=80'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                            ),
                          ),
                        ),
                        // Badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Text('NEW LAUNCH', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ),
                        ),
                        // Text
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.2, fontFamily: 'Inter'),
                                  children: [
                                    TextSpan(text: 'Crafted by our '),
                                    TextSpan(text: 'chefs', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF86efac))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Icon(Icons.access_time_filled, color: Colors.white70, size: 14),
                                  SizedBox(width: 6),
                                  Text('10 min delivery guaranteed', style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Inter')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SignInView(exitFromApp: widget.exitFromApp, backFromThis: widget.backFromThis, fromResetPassword: widget.fromResetPassword, isOtpViewEnable: (v){},),

                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
