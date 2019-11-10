import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easy_order/models/storage.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:meta/meta.dart';

abstract class StorageRepository {

  Future<Storage> upload({@required File file, @required String path});

  Future<void> delete({@required String path});
}

class StorageRepositoryImpl implements StorageRepository {

  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  final Logger logger = getLogger();

  @override
  Future<Storage> upload({@required File file, @required String path}) async {
    try {
      final List<String> mimeTypeData = lookupMimeType(file.path).split('/');
      final StorageUploadTask uploadTask = _storageReference.child(path).putFile(
        file,
        StorageMetadata(
          contentType: mimeTypeData[0] + '/' + mimeTypeData[1],
        ),
      );

      final StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
      final String url = await downloadUrl.ref.getDownloadURL();
      final Storage result = Storage(url: url, path: path);
      logger.d('upload result: $result');
      return result;
    } catch (error) {
      logger.e('uploadImage error: $error');
      return null;
    }
  }

  @override
  Future<void> delete({@required String path}) {
    return _storageReference.child(path).delete();
  }

}
