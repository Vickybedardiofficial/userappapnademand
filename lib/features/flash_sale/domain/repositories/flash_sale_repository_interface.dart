import 'package:apna_demand/common/enums/data_source_enum.dart';
import 'package:apna_demand/interfaces/repository_interface.dart';

abstract class FlashSaleRepositoryInterface<T> implements RepositoryInterface {
  Future<dynamic> getFlashSale({required DataSourceEnum source});
  Future<dynamic> getFlashSaleWithId(int id, int offset);
}
