import 'package:apna_demand/api/api_client.dart';
import 'package:apna_demand/features/auth/domain/models/delivery_man_body.dart';
import 'package:apna_demand/interfaces/repository_interface.dart';

abstract class DeliverymanRegistrationRepositoryInterface extends RepositoryInterface{
  @override
  Future getList({int? offset, int? zoneId, bool isZone = true, bool isVehicle = false});
  Future<bool> registerDeliveryMan(DeliveryManBody deliveryManBody, List<MultipartBody> multiParts);
}
