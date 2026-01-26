import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Place {
  Place({required this.tilte, required this.image}) : id = uuid.v4();
  final String id;
  final String tilte;
  final File image;
}
