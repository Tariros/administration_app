import 'package:administration_application/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ObjectBoxService {
  static late Store _store;
  static bool _storeOpened = false;

  static Future<void> openObjectBoxStore() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final databaseDirectoryPath = appDocumentDir.path + '/objectbox';

    if (!Directory(databaseDirectoryPath).existsSync()) {
      Directory(databaseDirectoryPath).createSync();
    }

    _store = Store(getObjectBoxModel(), directory: databaseDirectoryPath);
    _storeOpened = true;

    // Create Admin instance if available
    if (Admin.isAvailable()) {
// Create the Admin instance
      // (Optional) Close at some later point.
      // admin.close();
    }
  }

  static Store get objectBoxStore {
    if (_storeOpened) {
      return _store;
    } else {
      throw Exception("ObjectBox store has not been initialized.");
    }
  }

// Other methods for managing products, queries, etc.
}
