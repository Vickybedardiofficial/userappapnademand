import 'package:apna_demand/features/search/controllers/search_controller.dart' as search;
import 'package:apna_demand/helper/responsive_helper.dart';
import 'package:apna_demand/util/dimensions.dart';
import 'package:apna_demand/common/widgets/footer_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apna_demand/common/widgets/item_view.dart';
import 'package:apna_demand/common/widgets/web_item_view.dart';

class ItemViewWidget extends StatelessWidget {
  final bool isItem;
  const ItemViewWidget({super.key, required this.isItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<search.SearchController>(builder: (searchController) {
        return SingleChildScrollView(
          child: FooterView(
            child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: ResponsiveHelper.isDesktop(context) ? WebItemsView(
                  isStore: isItem, items: searchController.searchItemList, stores: searchController.searchStoreList,
                ) : ItemsView(
                  isStore: isItem, items: searchController.searchItemList, stores: searchController.searchStoreList,
                ),
            ),
          ),
        );
      }),
    );
  }
}
