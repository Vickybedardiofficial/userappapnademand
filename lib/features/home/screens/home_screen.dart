import 'package:apna_demand/features/banner/controllers/banner_controller.dart';
import 'package:apna_demand/features/brands/controllers/brands_controller.dart';
import 'package:apna_demand/features/home/controllers/advertisement_controller.dart';
import 'package:apna_demand/features/home/controllers/home_controller.dart';
import 'package:apna_demand/features/home/widgets/all_store_filter_widget.dart';
import 'package:apna_demand/features/home/widgets/cashback_logo_widget.dart';
import 'package:apna_demand/features/home/widgets/cashback_dialog_widget.dart';
import 'package:apna_demand/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:apna_demand/features/item/controllers/campaign_controller.dart';
import 'package:apna_demand/features/category/controllers/category_controller.dart';
import 'package:apna_demand/features/coupon/controllers/coupon_controller.dart';
import 'package:apna_demand/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:apna_demand/features/location/controllers/location_controller.dart';
import 'package:apna_demand/features/notification/controllers/notification_controller.dart';
import 'package:apna_demand/features/item/controllers/item_controller.dart';
import 'package:apna_demand/features/ride_share_module/ride_home/controllers/ride_home_controller.dart';
import 'package:apna_demand/features/ride_share_module/ride_home/screens/biding_list_screen.dart';
import 'package:apna_demand/features/ride_share_module/ride_home/screens/ride_home_screen.dart';
import 'package:apna_demand/features/ride_share_module/ride_order/controllers/ride_controller.dart';
import 'package:apna_demand/features/ride_share_module/safety_alert/controllers/safety_alert_controller.dart';
import 'package:apna_demand/features/ride_share_module/trip/controllers/trip_controller.dart';
import 'package:apna_demand/features/store/controllers/store_controller.dart';
import 'package:apna_demand/features/splash/controllers/splash_controller.dart';
import 'package:apna_demand/features/profile/controllers/profile_controller.dart';
import 'package:apna_demand/features/address/controllers/address_controller.dart';
import 'package:apna_demand/features/home/screens/modules/food_home_screen.dart';
import 'package:apna_demand/features/home/screens/modules/grocery_home_screen.dart';
import 'package:apna_demand/features/home/screens/modules/pharmacy_home_screen.dart';
import 'package:apna_demand/features/home/screens/modules/shop_home_screen.dart';
import 'package:apna_demand/features/parcel/controllers/parcel_controller.dart';
import 'package:apna_demand/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:apna_demand/features/rental_module/home/screens/taxi_home_screen.dart';
import 'package:apna_demand/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:apna_demand/helper/address_helper.dart';
import 'package:apna_demand/helper/auth_helper.dart';
import 'package:apna_demand/helper/responsive_helper.dart';
import 'package:apna_demand/helper/route_helper.dart';
import 'package:apna_demand/util/app_constants.dart';
import 'package:apna_demand/util/dimensions.dart';
import 'package:apna_demand/util/images.dart';
import 'package:apna_demand/util/styles.dart';
import 'package:apna_demand/common/widgets/item_view.dart';
import 'package:apna_demand/common/widgets/menu_drawer.dart';
import 'package:apna_demand/common/widgets/paginated_list_view.dart';
import 'package:apna_demand/common/widgets/web_menu_bar.dart';
import 'package:apna_demand/features/home/screens/web_new_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apna_demand/features/home/widgets/module_view.dart';
import 'package:apna_demand/features/parcel/screens/parcel_category_screen.dart';
import 'package:apna_demand/common/widgets/custom_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
    debugPrint('===== Home Screen Load Data =====');
    Get.find<LocationController>().syncZoneData();
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: fromModule);

    if(Get.find<SplashController>().module != null
        && Get.find<SplashController>().module!.moduleType.toString() != AppConstants.ride
        && !Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!
        && !Get.find<SplashController>().configModel!.moduleConfig!.module!.isTaxi!) {

      // CRITICAL DATA - Load Immediately for UI
      Get.find<BannerController>().getBannerList(reload);
      Get.find<CategoryController>().getCategoryList(reload);

      // HIGH PRIORITY DATA - Delay slightly to allow UI painting (Smooth Load)
      Future.delayed(const Duration(milliseconds: 300), () {
        if(AuthHelper.isLoggedIn()) {
          Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule);
        }
        Get.find<StoreController>().getRecommendedStoreList();
        Get.find<BannerController>().getPromotionalBannerList(reload);
        Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
        Get.find<CampaignController>().getBasicCampaignList(reload);
        
        if(Get.find<SplashController>().module?.moduleType.toString() == AppConstants.grocery) {
          Get.find<FlashSaleController>().getFlashSale(reload, false);
        }
        if(Get.find<SplashController>().module?.moduleType.toString() == AppConstants.ecommerce) {
          Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
          Get.find<FlashSaleController>().getFlashSale(reload, false);
          Get.find<BrandsController>().getBrandList();
        }
      });

      // LAZY DATA (Bottom page content) - Delay extensively to avoid Jank
      Future.delayed(const Duration(milliseconds: 600), () {
        Get.find<ItemController>().getDiscountedItemList(offset: '1', firstTimeCategoryLoad: true);
        Get.find<ItemController>().getPopularItemList(offset: '1', firstTimeCategoryLoad: true);
        Get.find<ItemController>().getReviewedItemList(offset: '1', firstTimeCategoryLoad: true);
        Get.find<CampaignController>().getItemCampaignList(reload);
        Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
        Get.find<StoreController>().getTopOfferStoreList(reload, false);
        Get.find<ItemController>().getRecommendedItemList(reload, 'all', false);
        Get.find<StoreController>().getStoreList(1, reload);
        Get.find<AdvertisementController>().getAdvertisementList();
      });
    }
    if(AuthHelper.isLoggedIn()) {
      await Get.find<ProfileController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      if(!Get.find<SplashController>().configModel!.moduleConfig!.module!.isRide!) {
        Get.find<CouponController>().getCouponList();
      }
    }
    Get.find<SplashController>().getModules();
    if(Get.find<SplashController>().module == null && Get.find<SplashController>().configModel!.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      if(AuthHelper.isLoggedIn()) {
        Get.find<AddressController>().getAddressList();
      }
    }
    if(Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!) {
      Get.find<ParcelController>().getParcelCategoryList();
    }
    if(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy) {
      Get.find<ItemController>().getBasicMedicine(reload, false);
      Get.find<StoreController>().getFeaturedStoreList();
      await Get.find<ItemController>().getCommonConditions(false);
      if(Get.find<ItemController>().commonConditions!.isNotEmpty) {
        Get.find<ItemController>().getConditionsWiseItem(Get.find<ItemController>().commonConditions![0].id!, false);
      }
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool searchBgShow = false;
  final GlobalKey _headerKey = GlobalKey();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();

    // PusherHelper.initializePusher();

    HomeScreen.loadData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();

      if((Get.find<ProfileController>().userInfoModel?.isValidForDiscount??false) && Get.find<SplashController>().showReferBottomSheet) {
        _showReferBottomSheet();
      }
    });

    if(!ResponsiveHelper.isWeb()) {
      Get.find<LocationController>().getZone(
        AddressHelper.getUserAddressFromSharedPref()?.latitude??'',
        AddressHelper.getUserAddressFromSharedPref()?.longitude??'', false, updateInAddress: true,
      );
    }

    _scrollController.addListener(() {
      if (!_isScrolling && _scrollController.position.isScrollingNotifier.value) {
        Future.delayed(const Duration(milliseconds: 100), () => Get.find<HomeController>().changeFavVisibility(value: false));
        _isScrolling = true;
      }
      _scrollController.position.isScrollingNotifier.addListener(() {
        if (!_scrollController.position.isScrollingNotifier.value && _isScrolling) {
          Future.delayed(const Duration(milliseconds: 2000), () => Get.find<HomeController>().changeFavVisibility(value: true));
          _isScrolling = false;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context) ? Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
        insetPadding: const EdgeInsets.all(22),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: const ReferBottomSheetWidget(),
      ),
      useSafeArea: false,
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const ReferBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  Future<void> loadTaxiApis() async{
   await Get.find<TaxiHomeController>().getTaxiBannerList(true);
   await Get.find<TaxiHomeController>().getTopRatedCarList(1, true);
    if (AuthHelper.isLoggedIn()) {
      await Get.find<AddressController>().getAddressList();
      await Get.find<TaxiHomeController>().getTaxiCouponList(true);
      await Get.find<TaxiCartController>().getCarCartList();
    }
  }

  Future<void> loadRideApis() async{
    Get.find<RideHomeController>().getBannerList();
    Get.find<RideHomeController>().getCategoryList();
    Get.find<RideController>().getNearestDriverList(
      AddressHelper.getUserAddressFromSharedPref()!.latitude!.toString(),
      AddressHelper.getUserAddressFromSharedPref()!.longitude!.toString(),
    );
    if (AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
      Get.find<RideHomeController>().getOfferList(1);
      Get.find<RideHomeController>().getCouponList(1, isUpdate: false);
      Get.find<TripController>().getRideCancellationReasonList();

      await Get.find<RideController>().getCurrentRide();
      if(Get.find<RideController>().rideDetails != null){
        Get.find<RideController>().getBiddingList(Get.find<RideController>().rideDetails!.id!, 1);

        if(Get.find<RideController>().rideDetails?.currentStatus == 'ongoing'){
          if(Get.find<RideController>().rideDetails?.customerSafetyAlert != null){
            Get.find<SafetyAlertController>().updateSafetyAlertState(SafetyAlertState.afterSendAlert);
          }else{
            Get.find<RideController>().remainingDistance(Get.find<RideController>().rideDetails!.id!);
            Get.find<SafetyAlertController>().checkDriverNeedSafety();
          }
        }
      }else{
        Get.find<RideController>().clearBiddingList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GetBuilder<SplashController>(builder: (splashController) {
      return GetBuilder<HomeController>(builder: (homeController) {
        if (splashController.module == null && splashController.moduleList != null && splashController.moduleList!.isNotEmpty) {
          int shopIndex = splashController.moduleList!.indexWhere((m) => m.moduleType == AppConstants.ecommerce || m.slug == 'shop' || m.slug == 'ecommerce');
          if (shopIndex != -1) {
            Future.microtask(() => splashController.switchModule(shopIndex, true));
          }
        }
        
        bool showMobileModule = !ResponsiveHelper.isDesktop(context) && splashController.module == null && splashController.configModel!.module == null;
        bool isParcel = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.parcel;
        bool isPharmacy = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.pharmacy;
        bool isFood = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.food;
        bool isShop = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.ecommerce;
        bool isGrocery = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.grocery;
        bool isTaxi = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.taxi;
        bool isRide = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.ride;

        return Scaffold(
          appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: isParcel ? const ParcelCategoryScreen() : SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                splashController.setRefreshing(true);
                if (Get.find<SplashController>().module != null && !isTaxi && !isRide) {
                  await Get.find<LocationController>().syncZoneData();
                  await Get.find<BannerController>().getBannerList(true);
                  if (isGrocery) {
                    await Get.find<FlashSaleController>().getFlashSale(true, true);
                  }
                  await Get.find<BannerController>().getPromotionalBannerList(true);
                  await Get.find<ItemController>().getDiscountedItemList(offset: '1');
                  await Get.find<CategoryController>().getCategoryList(true);
                  await Get.find<StoreController>().getPopularStoreList(true, 'all', false);
                  await Get.find<CampaignController>().getItemCampaignList(true);
                  Get.find<CampaignController>().getBasicCampaignList(true);
                  await Get.find<ItemController>().getPopularItemList(offset: '1');
                  await Get.find<StoreController>().getLatestStoreList(true, 'all', false);
                  await Get.find<StoreController>().getTopOfferStoreList(true, false);
                  await Get.find<ItemController>().getReviewedItemList(offset: '1');
                  await Get.find<StoreController>().getStoreList(1, true);
                  Get.find<AdvertisementController>().getAdvertisementList();
                  if (AuthHelper.isLoggedIn()) {
                    await Get.find<ProfileController>().getUserInfo();
                    await Get.find<NotificationController>().getNotificationList(true);
                    Get.find<CouponController>().getCouponList();
                  }
                  if (isPharmacy) {
                    Get.find<ItemController>().getBasicMedicine(true, true);
                    Get.find<ItemController>().getCommonConditions(true);
                  }
                  if (isShop) {
                    await Get.find<FlashSaleController>().getFlashSale(true, true);
                    Get.find<ItemController>().getFeaturedCategoriesItemList(true, true);
                    Get.find<BrandsController>().getBrandList();
                  }
                } else if(isTaxi) {
                  await loadTaxiApis();
                }else if(isRide) {
                  await loadRideApis();
                } else {
                  await Get.find<BannerController>().getFeaturedBanner();
                  await Get.find<SplashController>().getModules();
                  if (AuthHelper.isLoggedIn()) {
                    await Get.find<AddressController>().getAddressList();
                  }
                  await Get.find<StoreController>().getFeaturedStoreList();
                }
                splashController.setRefreshing(false);
              },
              child: ResponsiveHelper.isDesktop(context) ? WebNewHomeScreen(
                scrollController: _scrollController,
              ) : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [

                  /// Module specific Header / Back button / Location
                  SliverToBoxAdapter(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        
                        /// Smart Horizontal Module Switcher (Hides selected module)
                        GetBuilder<SplashController>(builder: (splashController) {
                          final unselectedModules = splashController.moduleList?.where(
                            (module) => module.id != splashController.module?.id
                          ).toList() ?? [];

                          return (unselectedModules.isNotEmpty && !ResponsiveHelper.isDesktop(context)) ? Container(
                            height: 75, width: Dimensions.webMaxWidth,
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: unselectedModules.length,
                              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final module = unselectedModules[index];

                                return Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  child: InkWell(
                                    onTap: () {
                                      final originalIndex = splashController.moduleList!.indexWhere((m) => m.id == module.id);
                                      if (originalIndex != -1) {
                                        splashController.switchModule(originalIndex, true);
                                      }
                                    },
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    child: Container(
                                      width: 75,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1),
                                      ),
                                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        CustomImage(
                                          image: '${module.iconFullUrl}',
                                          height: 28, width: 28,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          module.moduleName!,
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: robotoMedium.copyWith(
                                            fontSize: 9,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ) : const SizedBox();
                        }),

                        Container(
                          width: Dimensions.webMaxWidth,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          color: Theme.of(context).colorScheme.surface,
                          child: Row(children: [
                            (splashController.module != null && splashController.configModel!.module == null && splashController.moduleList != null && splashController.moduleList!.length != 1) ? InkWell(
                              onTap: () {
                                splashController.removeModule();
                                Get.find<StoreController>().resetStoreData();
                              },
                              child: Icon(Icons.arrow_back_rounded, color: _getModuleColor(splashController)),
                            ) : const SizedBox(),
                            SizedBox(width: (splashController.module != null && splashController.configModel!.module == null && splashController.moduleList != null && splashController.moduleList!.length != 1) ? Dimensions.paddingSizeSmall : 0),
    
                            Expanded(child: GetBuilder<LocationController>(builder: (locationController) {
                                return AddressHelper.getUserAddressFromSharedPref() != null ? InkWell(
                                  onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
 
                                    Row(children: [
                                      Icon(Icons.location_on_rounded, size: 16, color: _getModuleColor(splashController)),
                                      const SizedBox(width: 4),
                                      Text(
                                        AuthHelper.isLoggedIn() ? AddressHelper.getUserAddressFromSharedPref()?.addressType?.tr ?? '' : 'my_location'.tr,
                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      ),

                                      const SizedBox(width: 10), // Space between Home and Delivery time

                                      GetBuilder<StoreController>(builder: (storeController) {
                                        String? deliveryTime;
                                        if(storeController.popularStoreList != null && storeController.popularStoreList!.isNotEmpty) {
                                          deliveryTime = storeController.popularStoreList![0].deliveryTime;
                                        }
                                        return deliveryTime != null ? Row(children: [
                                          Icon(Icons.flash_on, size: 12, color: _getModuleColor(splashController)),
                                          const SizedBox(width: 2),
                                          Text(
                                            '$deliveryTime ${'min'.tr}',
                                            style: robotoBold.copyWith(color: _getModuleColor(splashController), fontSize: 10),
                                          ),
                                        ]) : const SizedBox();
                                      }),
                                    ]),
                                    Row(children: [
                                      Flexible(child: Text(
                                        AddressHelper.getUserAddressFromSharedPref()!.address!,
                                        style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      )),
                                      Icon(Icons.expand_more, color: Theme.of(context).disabledColor, size: 16),
                                    ]),
                                  ]),
                                ) : InkWell(
                                  onTap: () => locationController.navigateToLocationScreen('home'),
                                  child: Text('select_your_location'.tr, style: robotoMedium.copyWith(color: _getModuleColor(splashController))),
                                );
                              })),
    
                            GetBuilder<NotificationController>(builder: (notificationController) {
                              return InkWell(
                                onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                                child: Stack(children: [
                                  Icon(Icons.notifications_outlined, size: 28, color: Theme.of(context).textTheme.bodyLarge!.color),
                                  if(notificationController.hasNotification) Positioned(top: 2, right: 2, child: Container(
                                    height: 8, width: 8, decoration: BoxDecoration(color: _getModuleColor(splashController), shape: BoxShape.circle, border: Border.all(width: 1, color: Theme.of(context).cardColor)),
                                  )),
                                ]),
                              );
                            }),
                          ]),
                        ),
                      ]),
                  ),

                  /// Search Button (Sticky)
                  !showMobileModule && !isTaxi && !isRide ? SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverDelegate(
                      height: 65,
                      callback: (val) {
                        setState(() {
                          searchBgShow = val;
                        });
                      },
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                              boxShadow: searchBgShow ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
                            ),
                            child: Row(children: [
                              Icon(Icons.search_rounded, color: _getModuleColor(splashController)),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(child: Text(
                                _getSearchPlaceholder(splashController),
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                              )),
                              Icon(Icons.mic_rounded, size: 22, color: Theme.of(context).disabledColor),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ) : const SliverToBoxAdapter(),

                  SliverToBoxAdapter(
                    child: Center(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: !showMobileModule ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        isGrocery ? const GroceryHomeScreen()
                            : isPharmacy ? const PharmacyHomeScreen()
                            : isFood ? const FoodHomeScreen()
                            : isShop ? const ShopHomeScreen()
                            : isTaxi ? const TaxiHomeScreen()
                            : isRide ? const RideHomeScreen()
                            : const SizedBox(),

                      ]) : ModuleView(splashController: splashController),
                    )),
                  ),

                  !showMobileModule && !isTaxi && !isRide ? SliverPersistentHeader(
                    key: _headerKey,
                    pinned: true,
                    delegate: SliverDelegate(
                      height: 85,
                      callback: (val) {
                        searchBgShow = val;
                      },
                      child: const AllStoreFilterWidget(),
                    ),
                  ) : const SliverToBoxAdapter(),

                  SliverToBoxAdapter(child: !showMobileModule && !isTaxi && !isRide ? Center(child: GetBuilder<StoreController>(builder: (storeController) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 0 : 100),
                      child: PaginatedListView(
                        scrollController: _scrollController,
                        totalSize: storeController.storeModel?.totalSize,
                        offset: storeController.storeModel?.offset,
                        onPaginate: (int? offset) async => await storeController.getStoreList(offset!, false),
                        gridColumns: ResponsiveHelper.isDesktop(context) ? 3 : 1, // Desktop has 3 columns for stores, mobile 1
                        itemView: ItemsView(
                          isStore: true,
                          items: null,
                          isFoodOrGrocery: (isFood || isGrocery),
                          stores: storeController.storeModel?.stores,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                            vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
                          ),
                        ),
                      ),
                    );
                  }),) : const SizedBox()),

                ],
              ),
            ),
          ),

          floatingActionButton: isRide ?  GetBuilder<RideController>(
              builder: (rideController) {
                return rideController.biddingList.isNotEmpty && homeController.showFavButton ? Padding(
                  padding: EdgeInsets.only(bottom: Get.height * 0.08),
                  child: InkWell(
                    onTap: (){
                      Get.to(()=> BidingListScreen(tripId: rideController.rideDetails!.id!));
                    },
                    child: Image.asset(Images.biddingIcon,height: 60,width: 60),
                  ),
                ) : const SizedBox();
              }
          ) : AuthHelper.isLoggedIn() && homeController.cashBackOfferList != null && homeController.cashBackOfferList!.isNotEmpty ?
          homeController.showFavButton ? Padding(
            padding: EdgeInsets.only(bottom: 50.0, right: ResponsiveHelper.isDesktop(context) ? 50 : 0),
            child: InkWell(
              onTap: () => Get.dialog(const CashBackDialogWidget()),
              child: const CashBackLogoWidget(),
            ),
          ) : null : null,

        );
      });
    }));
  }

  Color _getModuleColor(SplashController splashController) {
    if (splashController.module == null) return const Color(0xFFFB641B);
    String type = splashController.module!.moduleType.toString();
    switch (type) {
      case AppConstants.food: return const Color(0xFFFF9800);
      case AppConstants.grocery: return const Color(0xFF4CAF50);
      case AppConstants.pharmacy: return const Color(0xFFF44336);
      case AppConstants.ride:
      case AppConstants.taxi: return const Color(0xFF2196F3);
      case AppConstants.parcel: return const Color(0xFF9C27B0);
      default: return const Color(0xFFFB641B);
    }
  }

  String _getSearchPlaceholder(SplashController splashController) {
    if (splashController.module == null) return "Search for food, grocery, medicines...";
    String type = splashController.module!.moduleType.toString();
    switch (type) {
      case AppConstants.food: return "Search food, restaurants or cuisines...";
      case AppConstants.grocery: return "Search grocery items or stores...";
      case AppConstants.pharmacy: return "Search medicines or health products...";
      case AppConstants.ride:
      case AppConstants.taxi: return "Where do you want to go?";
      case AppConstants.parcel: return "Track or send a parcel...";
      default: return "Search for products or stores...";
    }
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  Function(bool isPinned)? callback;
  bool isPinned = false;

  SliverDelegate({required this.child, this.height = 50, this.callback});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    isPinned = shrinkOffset >= maxExtent;
    if(callback != null) {
      callback!(isPinned);
    }
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
