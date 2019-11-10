import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:flutter_easy_order/bloc/storage_bloc.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/models/image_type.dart';
import 'package:flutter_easy_order/models/product.dart';
import 'package:flutter_easy_order/models/storage.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/repository/product_repository.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

abstract class ProductBloc {

  Stream<int> get productsCount$;

  Stream<List<Product>> get products$;

  Stream<List<Product>> filterByCategory({@required Category category});

  Future<bool> create({@required Product product, File image});

  Future<bool> update({@required String productId, @required Product product, File image});

  Future<bool> delete({@required Product product});

  void dispose();
}

class ProductBlocImpl implements ProductBloc {

  final Logger logger = getLogger();

//  final Stream<User> user$;
  final User user;
  final ProductRepository productRepository;
  final StorageBloc storageBloc;

  final BehaviorSubject<int> _productsCountSubject = BehaviorSubject<int>.seeded(0);
  @override
  Stream<int> get productsCount$ => _productsCountSubject.stream;

  final BehaviorSubject<List<Product>> _productsSubject = BehaviorSubject<List<Product>>();
  @override
  Stream<List<Product>> get products$ => _productsSubject.stream;

  final PublishSubject<List<Product>> _productsByCategorySubject = PublishSubject<List<Product>>(); //.seeded([]);
  final PublishSubject<Category> _categoryFilterSubject = PublishSubject<Category>();

  ProductBlocImpl({@required this.user, @required this.productRepository, @required this.storageBloc}) {

    assert(user != null && productRepository != null && storageBloc != null);

    final Stream<List<Product>> products$ = productRepository.findByUserOrderByCategory(user: user);
    products$.listen((List<Product> products) {
      _productsSubject.add(products);
      _productsCountSubject.add((products.length));
    }, onError: (error) => logger.e('products listen error: $error'), cancelOnError: false);

    // Products filtered by category
    _categoryFilterSubject.listen((Category category) {
      final Stream<List<Product>> productsByCategory$ = productRepository.findByCategoryAndUser(category: category, user: user);
      productsByCategory$.listen((List<Product> productsByCategory) {
        _productsByCategorySubject.add(productsByCategory);
      }, onError: (error) => logger.e('_categoryFilterSubject listen error: $error'), cancelOnError: false);
    }, onError: (error) => logger.e('_productsByCategorySubject listen error: $error'), cancelOnError: false);
  }

  @override
  Stream<List<Product>> filterByCategory({@required Category category}) {
    _categoryFilterSubject.add(category);
    return _productsByCategorySubject.stream;
  }

  @override
  Future<bool> create({Product product, File image}) async {
    logger.d('add product, user: $user');

    if (product == null || user == null) {
      logger.e('product or user is null');
      return false;
    }

    String imageUrl;
    String imagePath;

    if (image != null) {
      logger.d('uploading image');
      final Storage storage = await storageBloc.upload(file: image, imageType: ImageType.Product);

      if (storage == null) {
        logger.d('Upload failed!');
        return false;
      }

      imageUrl = storage.url;
      imagePath = storage.path;
    }

    final Uuid uuid = Uuid();

    final Product productToCreate = Product.clone(product);
    productToCreate.uuid = uuid.v4();
    productToCreate.imagePath = imagePath;
    productToCreate.imageUrl = imageUrl;
    productToCreate.userEmail = user.email;
    productToCreate.userId = user.id;

    return productRepository.create(product: productToCreate);
  }

  @override
  Future<bool> update({String productId, Product product, File image}) async {
    logger.d('updateProduct: $productId');

    if (productId == null || product == null) {
      logger.e('productId or product is null');
      return false;
    }

    String imageUrl = product.imageUrl;
    String imagePath = product.imagePath;

    if (image != null) {
      logger.d('uploading image');
      final Storage storage = await storageBloc.upload(file: image, imageType: ImageType.Product, path: product.imagePath);

      if (storage == null) {
        logger.e('Upload failed!');
        return false;
      }

      imageUrl = storage.url;
      imagePath = storage.path;
    }

    final Product productToUpdate = Product.clone(product);
    productToUpdate.imagePath = imagePath;
    productToUpdate.imageUrl = imageUrl;

    return productRepository.update(productId: productId, product: productToUpdate);
  }

  @override
  Future<bool> delete({@required Product product}) async {

    if (product == null) {
      logger.e('product is null');
      return Future.value(false);
    }

    logger.d('deleteProduct: ${product.id}, user: ${product.userId}');

    // Delete image
    if (product.imagePath != null) {
      storageBloc.delete(path: product.imagePath);
    }

    return productRepository.delete(product: product);
  }

  @override
  void dispose() {
    logger.d('*** DISPOSE ProductBloc ***');
    _productsCountSubject.close();
    _productsSubject.close();
    _productsByCategorySubject.close();
    _categoryFilterSubject.close();
  }
}
