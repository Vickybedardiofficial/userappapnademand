import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:apna_demand/common/widgets/custom_app_bar.dart';
import 'package:apna_demand/common/widgets/footer_view.dart';
import 'package:apna_demand/common/widgets/item_view.dart';
import 'package:apna_demand/common/widgets/menu_drawer.dart';
import 'package:apna_demand/common/widgets/paginated_list_view.dart';
import 'package:apna_demand/common/widgets/web_page_title_widget.dart';
import 'package:apna_demand/features/store/controllers/store_controller.dart';
import 'package:apna_demand/helper/responsive_helper.dart';
import 'package:apna_demand/util/dimensions.dart';

class AllStoreWebViewWidget extends StatefulWidget {
  const AllStoreWebViewWidget({super.key});

  @override
  State<AllStoreWebViewWidget> createState() => _AllStoreWebViewWidgetState();
}

class _AllStoreWebViewWidgetState extends State<AllStoreWebViewWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      Get.find<StoreController>().resetStoreData();
      Get.find<StoreController>().getStoreList(1, true);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:  'all_stores'.tr,
      ),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: CustomScrollView(
        slivers: [
          // const AllStoreFilterWidget(),
          SliverToBoxAdapter(
            child: WebScreenTitleWidget(title: 'all_stores'.tr),
          ),


          SliverToBoxAdapter(
            child: GetBuilder<StoreController>(builder: (storeController) {
              return FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: PaginatedListView(
                    scrollController: _scrollController,
                    totalSize: storeController.storeModel?.totalSize,
                    offset: storeController.storeModel?.offset,
                    onPaginate: (int? offset) async {
                      debugPrint("--------------->");
                      await storeController.getStoreList(offset!, false);
                    },
                    gridColumns: 3,
                    itemView: ItemsView(
                      isStore: true, items: null,
                      stores: storeController.storeModel?.stores,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                        vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
