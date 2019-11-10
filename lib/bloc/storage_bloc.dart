import 'dart:io';

import 'package:flutter_easy_order/models/image_type.dart';
import 'package:flutter_easy_order/models/storage.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/repository/storage_repository.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:meta/meta.dart';

abstract class StorageBloc {
  Future<Storage> upload({@required File file, @required ImageType imageType, String path});

  Future<void> delete({@required String path});

  void dispose();
}

class StorageBlocImpl implements StorageBloc {
  final User user;
  final StorageRepository storageRepository;

  final Logger logger = getLogger();

  StorageBlocImpl({@required this.user, @required this.storageRepository})
      : assert(user != null && storageRepository != null);

  @override
  Future<Storage> upload({@required File file, @required ImageType imageType, String path}) async {
    logger.d('uploadImage: $file');

    try {
      final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      final String fileName = currentTimestamp.toString() + '_' + basename(file.path);
      final String directory = ImageTypeDirectory.getDirectory(imageType);
      final String filePath = path ?? '/users/' + user.id + '/' + directory + '/' + fileName;

      final Storage result = await storageRepository.upload(file: file, path: filePath);
      logger.d('upload result: $result');
      return result;
    } catch (error) {
      logger.e('uploadImage error: $error');
      return null;
    }
  }

  @override
  Future<void> delete({String path}) {
    return storageRepository.delete(path: path);
  }

  @override
  void dispose() {
    logger.d('*** DISPOSE StorageBloc ***');
  }
}
