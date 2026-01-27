import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  void addNewPlace(String tilte, File image, PlaceLocation location) {
    final newPlace = Place(tilte: tilte, image: image, location: location);
    state = [...state, newPlace];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>((
      ref,
    ) {
      return UserPlacesNotifier();
    });
