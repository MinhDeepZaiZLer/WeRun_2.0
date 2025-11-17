import 'package:injectable/injectable.dart';
import '../entities/suggested_route.dart';
import '../repositories/ai_repository.dart';

@lazySingleton // <-- Đánh dấu cho DI
class GetSuggestedRouteUsecase {
  final AiRepository _aiRepository;

  GetSuggestedRouteUsecase(this._aiRepository);

  Future<SuggestedRoute> call({
    required double lat, 
    required double lng, 
    required double distanceKm
  }) {
    return _aiRepository.getSuggestedRoute(
      lat: lat,
      lng: lng,
      distanceKm: distanceKm,
    );
  }
}