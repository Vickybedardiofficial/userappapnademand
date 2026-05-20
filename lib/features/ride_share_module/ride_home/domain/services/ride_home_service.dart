import '../repositories/ride_home_repository_interface.dart';
import 'ride_home_service_interface.dart';

class RideHomeService implements RideHomeServiceInterface {
  final RideHomeRepositoryInterface rideHomeRepositoryInterface;
  RideHomeService({required this.rideHomeRepositoryInterface});

}
  
