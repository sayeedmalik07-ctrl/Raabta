import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:raabta/features/exchange_locator/domain/repositories/exchange_locator_repository.dart';
import 'package:raabta/services/firebase_service.dart';

/// Reuses the housing/listing Storage upload pattern: ref → putFile → getDownloadURL.
class ExchangeLocatorStorageService implements ExchangeLocatorStorage {
  ExchangeLocatorStorageService({FirebaseStorage? storage})
      : _storage = FirebaseService.isReady
            ? (storage ?? FirebaseStorage.instance)
            : null;

  final FirebaseStorage? _storage;

  @override
  Future<String> uploadCompanyLogo(File file, String companyId) async {
    return _upload(file, 'exchange_locator/companies/$companyId/logo.jpg');
  }

  @override
  Future<String> uploadBranchPhoto(File file, String branchId) async {
    return _upload(
      file,
      'exchange_locator/branches/$branchId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  Future<String> _upload(File file, String path) async {
    if (_storage == null) {
      throw ExchangeLocatorException('Firebase Storage not initialized');
    }
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
