import 'package:get_storage/get_storage.dart';

class MyStorageUtility {

  late final GetStorage _storage;

  // Singleton instance
  static MyStorageUtility? _instance;

  MyStorageUtility._internal();

  factory MyStorageUtility.instance() {
    _instance ??= MyStorageUtility._internal();
    return _instance!;
  }

  static Future<void> init(String bucketName) async {
    await GetStorage.init(bucketName);
    _instance = MyStorageUtility._internal();
    _instance!._storage = GetStorage(bucketName);
  }

  // Generic method to save data
  Future<void> saveData<My>(String key, My value) async {
    if (!isInitialized()) {
      throw Exception('Storage has not been initialized.');
    }
    await _storage.write(key, value);
  }

  // Generic method to read data
  My? readData<My>(String key) {
    if (!isInitialized()) {
      throw Exception('Storage has not been initialized.');
    }
    return _storage.read<My>(key);
  }

  // Generic method to remove data
  Future<void> removeData(String key) async {
    if (!isInitialized()) {
      throw Exception('Storage has not been initialized.');
    }
    await _storage.remove(key);
  }

  // Clear all data in storage
  Future<void> clearAll() async {
    if (!isInitialized()) {
      throw Exception('Storage has not been initialized.');
    }
    await _storage.erase();
  }

  // Check if the storage is initialized
  bool isInitialized() {
    return _storage != null;
  }
}
