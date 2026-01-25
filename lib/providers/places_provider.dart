import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesNotifier extends StateNotifier<List<Place>> {
  PlacesNotifier()
    : super([
        const Place(id: '1', tilte: 'Office'),
        const Place(id: '2', tilte: 'Gym'),
      ]);

  void addNewPlace(Place place) {
    state = [...state, place];
  }
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((
  ref,
) {
  return PlacesNotifier();
});
