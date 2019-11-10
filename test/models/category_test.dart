import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromJson', () {
    test('should return correct object from JSON map', () async {

      Map<String, dynamic> json = {
          'id': 'categoryId',
          'uuid': 'uuid',
          'userId': 'mockUserId',
          'userEmail': 'mockUserEmail',
          'name': 'name',
          'imagePath': 'path',
          'imageUrl': 'url',
          'description': 'mockDescription'
      };

      Category expectedCategory = Category(
          id: 'categoryId',
          uuid: 'uuid',
          userId: 'mockUserId',
          userEmail: 'mockUserEmail',
          name: 'name',
          imagePath: 'path',
          imageUrl: 'url',
          description: 'mockDescription',
      );

      Category result = Category.fromJson(json);

      expect(result.toString(), expectedCategory.toString());
    });
  });

  group('toJson', () {
    test('should return correct JSON map from object', () async {

      Category category = Category(
        id: 'categoryId',
        uuid: 'uuid',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
        name: 'name',
        imagePath: 'path',
        imageUrl: 'url',
        description: 'mockDescription',
      );

      Map<String, dynamic> expectedJson = {
//        'id': 'categoryId',
        'uuid': 'uuid',
        'userId': 'mockUserId',
        'userEmail': 'mockUserEmail',
        'name': 'name',
        'imagePath': 'path',
        'imageUrl': 'url',
        'description': 'mockDescription'
      };

      Map<String, dynamic> result = category.toJson();

      expect(result, expectedJson);
    });
  });
}
