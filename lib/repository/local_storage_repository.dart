import 'dart:convert';

import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

abstract class LocalStorageRepository {

  Future<Map<String, dynamic>> get({@required String key});

  save({@required String key, @required Map<String, dynamic> json});

  delete({@required String key});
}

class LocalStorageRepositoryImpl implements LocalStorageRepository {

  final Logger logger = getLogger();

  @override
  Future<Map<String, dynamic>> get({@required String key}) async {
    logger.d('get json from key: $key');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String valueAsJsonString = prefs.getString(key);
    logger.d('json value as string fetched: $valueAsJsonString');
    final Map<String, dynamic> json = valueAsJsonString != null ? jsonDecode(valueAsJsonString) : null;
    logger.d('json value fetched: $json');
    return json;
  }

  @override
  save({@required String key, @required Map<String, dynamic> json}) async {
    logger.d('save json with key $key: $json');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    logger.d('saving json string: ${jsonEncode(json)}');
    prefs.setString(key, jsonEncode(json));
  }

  @override
  delete({@required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

//  test() async {
//    LocalStorageRepository localStorageRepository = LocalStorageRepositoryImpl();
//    await localStorageRepository.save(key: 'test', json: user.toJson());
//    await localStorageRepository.get(key: 'test');
//    await localStorageRepository.delete(key: 'test');
//    await localStorageRepository.get(key: 'test');
//  }
}
