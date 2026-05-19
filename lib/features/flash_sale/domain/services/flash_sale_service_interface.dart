import 'package:apna_demand/common/enums/data_source_enum.dart';
import 'package:apna_demand/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:apna_demand/features/flash_sale/domain/models/product_flash_sale.dart';

abstract class FlashSaleServiceInterface{
  Future<FlashSaleModel?> getFlashSale(DataSourceEnum source);
  Future<ProductFlashSale?> getFlashSaleWithId(int id, int offset);
}
