import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<LocationInput> createState() {
    return _LocationInput();
  }
}

class _LocationInput extends State<LocationInput> {
  Location? pickedLoaction;
  var _isGettingLocation = false;

  Future<Map<String, dynamic>> getLocationAddress(
    double latitude,
    double longitude,
  ) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$latitude'
        '&lon=$longitude'
        '&addressdetails=1';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        // REQUIRED by Nominatim
        'User-Agent': 'favorite_places',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['address'];
    } else {
      throw Exception('Failed to fetch address');
    }
  }

  void _getCurrentLocation() async {
    Location location = Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      setState(() {
        _isGettingLocation = true;
      });

      final locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      final addressData = await getLocationAddress(lat!, lng!);

      final address = [
        addressData['road'],
        addressData['city'],
        addressData['postcode'],
        addressData['country'],
      ].where((e) => e != null).join(', ');

      debugPrint(address);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to get address. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      debugPrint(error.toString());
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: previewContent,
        ),
        const SizedBox(
          height: 6,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              label: const Text(
                'Get Current Location',
              ),
              icon: const Icon(Icons.location_on),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              label: const Text(
                'Select on Map',
              ),
              icon: const Icon(Icons.map),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
