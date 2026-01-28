import 'dart:convert';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInput();
  }
}

class _LocationInput extends State<LocationInput> {
  PlaceLocation? _pickedLoaction;
  var _isGettingLocation = false;
  String get locationImage {
    if (_pickedLoaction == null) {
      return '';
    }

    final lat = _pickedLoaction!.latitude;
    final lng = _pickedLoaction!.longitude;
    final uri = Uri.https(
      'maps.geoapify.com',
      '/v1/staticmap',
      {
        'style': 'osm-bright-smooth',
        'width': '600',
        'height': '300',
        'center': 'lonlat:$lng,$lat',
        'zoom': '16',
        'marker': 'lonlat:$lng,$lat;type:awesome;color:#d90000;size:x-large',
        'apiKey': '1e6f6e759ae04c1d8ab596c93bc67a0a',
      },
    );
    return uri.toString();
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    final addressData = await getLocationAddress(latitude, longitude);

    final address = [
      addressData['road'],
      addressData['city'],
      addressData['postcode'],
      addressData['country'],
    ].where((e) => e != null).join(', ');

    debugPrint(address);
    setState(() {
      _pickedLoaction = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
    });
    widget.onSelectLocation(_pickedLoaction!);
  }

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

      if (lat == null || lng == null) return;

      await _savePlace(lat, lng);
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

  void _selectMap() async {
    final pickedLocation = await Navigator.of(
      context,
    ).push<LatLng>(MaterialPageRoute(builder: (ctx) => const MapScreen()));
    if (pickedLocation == null) {
      return;
    }
    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
    //
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
    if (_pickedLoaction != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

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
              onPressed: _selectMap,
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
