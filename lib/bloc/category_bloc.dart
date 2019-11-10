import 'dart:async';
import 'dart:io';

import 'package:flutter_easy_order/bloc/storage_bloc.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/models/image_type.dart';
import 'package:flutter_easy_order/models/storage.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/repository/category_repository.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:meta/meta.dart';

abstract class CategoryBloc {

  Stream<int> get categoriesCount$;

  Stream<List<Category>> get categories$;

  void filter({@required String name});

  Future<bool> create({@required Category category, File image});

  Future<bool> update({@required String categoryId, @required Category category, File image});

  Future<bool> delete({@required Category category});

  void dispose();
}

class CategoryBlocImpl implements CategoryBloc {
//  final Stream<User> user$;
  final User user;
  final CategoryRepository categoryRepository;
  final StorageBloc storageBloc;

  final Logger logger = getLogger();

  final BehaviorSubject<int> _categoriesCountSubject = BehaviorSubject<int>.seeded(0);
  @override
  Stream<int> get categoriesCount$ => _categoriesCountSubject.stream;

  final BehaviorSubject<List<Category>> _categoriesSubject = BehaviorSubject<List<Category>>.seeded([]);
  @override
  Stream<List<Category>> get categories$ => _categoriesSubject.stream;

  final _nameFilterSubject = BehaviorSubject<String>.seeded(null);
  StreamSubscription<List<Category>> _categories$Subscription;

//  CategoryBloc({@required this.user$}) {
  CategoryBlocImpl({@required this.user, @required this.categoryRepository, @required this.storageBloc}) {

    assert(user != null && categoryRepository != null && storageBloc != null);

    _nameFilterSubject.listen((name) {
      final Stream<List<Category>> categories$ = categoryRepository.findByUserAndName(user: user, name: name);
      _categories$Subscription = categories$.listen((List<Category> categories) {
        _categoriesCountSubject.add(categories.length);
        _categoriesSubject.add(categories);
      }, onError: (error) => logger.e('categories listen error: $error'), cancelOnError: false);
    });
  }

  @override
  void filter({@required String name}) {
    _categories$Subscription?.cancel();
    _nameFilterSubject.add(name);
  }

  @override
  Future<bool> create({@required Category category, File image}) async {
    logger.d('add category, user: $user');

    if (category == null || user == null) {
      logger.e('category or user is null');
      return false;
    }

    String imageUrl;
    String imagePath;

    if (image != null) {
      logger.d('uploading image');
      final Storage storage = await storageBloc.upload(file: image, imageType: ImageType.Category);

      if (storage == null) {
        logger.e('Upload failed!');
        return false;
      }

      imageUrl = storage.url;
      imagePath = storage.path;
    }

    final Uuid uuid = Uuid();

    final Category categoryToCreate = Category.clone(category);
    categoryToCreate.uuid = uuid.v4();
    categoryToCreate.imagePath = imagePath;
    categoryToCreate.imageUrl = imageUrl;
    categoryToCreate.userEmail = user.email;
    categoryToCreate.userId = user.id;

    return categoryRepository.create(category: categoryToCreate);
  }

  @override
  Future<bool> update({@required String categoryId, @required Category category, File image}) async {
    logger.d('update category: $categoryId');

    if (category == null || categoryId == null) {
      logger.e('category or categoryId is null');
      return false;
    }

    String imageUrl = category.imageUrl;
    String imagePath = category.imagePath;

    if (image != null) {
      logger.d('uploading image');
      final Storage storage = await storageBloc.upload(file: image, imageType: ImageType.Category, path: category.imagePath);

      if (storage == null) {
        logger.e('Upload failed!');
        return false;
      }

      imageUrl = storage.url;
      imagePath = storage.path;
    }

    final Category categoryToUpdate = Category.clone(category);
    categoryToUpdate.imagePath = imagePath;
    categoryToUpdate.imageUrl = imageUrl;

    return categoryRepository.update(categoryId: categoryId, category: categoryToUpdate);
  }

  @override
  Future<bool> delete({@required Category category}) async {

    if (category == null) {
      logger.e('category is null');
      return Future.value(false);
    }

    logger.d('delete category: ${category.id}, user: ${category.userId}');

    // Delete image
    if (category.imagePath != null) {
      storageBloc.delete(path: category.imagePath);
    }

    return categoryRepository.delete(category: category);
  }

  @override
  void dispose() {
    logger.d('*** DISPOSE CategoryBloc ***');
    _categoriesSubject.close();
    _categoriesCountSubject.close();
    _nameFilterSubject.close();
  }
}
