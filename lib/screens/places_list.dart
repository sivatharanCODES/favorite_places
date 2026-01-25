import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/providers/places_provider.dart';
import 'package:favorite_places/screens/place_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesScreenList extends ConsumerWidget {
  const PlacesScreenList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Place> allPlaces = ref.watch(placesProvider);
    Widget content = Center(
      child: Container(
        padding: const EdgeInsets.only(bottom: 50),
        child: Text(
          'No places added yet',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );

    if (allPlaces.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            key: ValueKey(allPlaces[index].id),
            title: Text(
              allPlaces[index].tilte,
            ),
            onTap: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => PlaceDetailsScreen(
                    place: allPlaces[index],
                  ),
                ),
              ),
            },
          );
        },
        itemCount: allPlaces.length,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add,
              ),
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}
