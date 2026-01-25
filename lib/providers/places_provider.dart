import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final placesProvider = Provider((ref) {
//   return dummyPlaces;
// });

class PlacesNotifier extends StateNotifier<List<Place>> {
  PlacesNotifier()
    : super([
        const Place(id: '1', tilte: 'Office'),
        const Place(id: '2', tilte: 'Gym'),
      ]);
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((
  ref,
) {
  return PlacesNotifier();
});
