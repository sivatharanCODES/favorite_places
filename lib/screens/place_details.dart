import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Container(
        padding: const EdgeInsets.only(bottom: 50),
        child: Text(
          'No details found',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(place.tilte),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: content,
    );
  }
}
