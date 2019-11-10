import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/models/order.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

abstract class CategoryRepository {
  Stream<List<Category>> findByUser({@required User user});

  Stream<List<Category>> findByUserAndName({@required User user, String name});

  Future<bool> create({@required Category category});

  Future<bool> update({@required String categoryId, @required Category category});

  Future<bool> delete({@required Category category});
}

class CategoryRepositoryFirebaseImpl implements CategoryRepository {
  final Firestore _store = Firestore.instance;
  final Logger logger = getLogger();

  @override
  Stream<List<Category>> findByUser({@required User user}) {
    logger.d('find categories');
//    return Observable(this.user$).switchMap((User user) {
    if (user == null || user.id == null) {
      logger.e('user is null');
      return Stream.empty();
    }

    try {
      // Find documents by user id
      final Stream<List<Category>> categories$ = _store
          .collection('users')
          .document(user.id)
          .collection('categories')
          .orderBy('name')
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        final List<Category> categories = querySnapshot.documents
            .map((DocumentSnapshot documentSnapshot) => Category.fromSnapshot(documentSnapshot))
            .toList();
//      _categoriesCountSubject.add(categories.length);
        return categories;
      });

      return categories$;
    } on Exception catch (ex) {
      logger.e(ex);
      return Stream.empty();
    }
  }

  @override
  Stream<List<Category>> findByUserAndName({@required User user, String name}) {
    logger.d('find categories by name: $name');
//    return Observable(this.user$).switchMap((User user) {
    if (user == null || user.id == null) {
      logger.e('user is null');
      return Stream.empty();
    }

    try {
      // Find documents by user id
      Query query = _store.collection('users').document(user.id).collection('categories').orderBy('name');

      if (name != null) {
        query = query.startAt([name]).endAt([name + '~']);
      }

      Stream<List<Category>> categories$ = query.snapshots().map((QuerySnapshot querySnapshot) {
        List<Category> categories = querySnapshot.documents
            .map((DocumentSnapshot documentSnapshot) => Category.fromSnapshot(documentSnapshot))
            .toList();
//      _categoriesCountSubject.add(categories.length);
        return categories;
      });

      return categories$;
    } on Exception catch (ex) {
      logger.e(ex);
      return Stream.empty();
    }
  }

  @override
  Future<bool> create({Category category}) async {
    if (category == null ||
        category.userId == null ||
        category.userEmail == null ||
        category.uuid == null ||
        category.name == null ||
        category.description == null) {
      logger.e('Invalid parameters');
      return false;
    }

    try {
      final Map<String, dynamic> categoryData = category.toJson();
      categoryData['createdDateTime'] = FieldValue.serverTimestamp(); // DateTime.now();
      logger.d('categoryData: $categoryData');

      // Add document by user id
      DocumentReference docRef =
          await _store.collection('users').document(category.userId).collection('categories').add(categoryData);
      logger.d('Create success: new category ID= ${docRef.documentID}');
      return true;
    } catch (error) {
      logger.e('create category error: $error');
      return false;
    }
  }

  @override
  Future<bool> update({String categoryId, Category category}) async {
    if (categoryId == null ||
        category == null ||
        category.userId == null ||
        category.userEmail == null ||
        category.uuid == null ||
        category.name == null ||
        category.description == null) {
      logger.e('Invalid parameters');
      return false;
    }

    try {
      final Map<String, dynamic> updatedCategoryAsJson = category.toJson();
      updatedCategoryAsJson['updatedDateTime'] = FieldValue.serverTimestamp(); // DateTime.now();
      logger.d('updatedCategory: $updatedCategoryAsJson');

      final Map<String, dynamic> updatedProduct = {'category': category.toJson(), 'categoryName': category.name};

      logger.d('running batch write');

      // Init batch write
      final WriteBatch batch = _store.batch();

      // Update all products of the category
      await _updateProductsWithCategory(batch, category.uuid, category.userId, updatedProduct);

      batch.updateData(
          _store.collection('users').document(category.userId).collection('categories').document(categoryId),
          updatedCategoryAsJson);

      batch.commit();

      logger.d('Update success');
      return true;
    } catch (error) {
      logger.e('updateCategory error: $error');
      return false;
    }
  }

  @override
  Future<bool> delete({Category category}) async {
    if (category == null || category.userId == null || category.uuid == null || category.id == null) {
      logger.e('Invalid parameters');
      return false;
    }

    try {
//      final Map<String, dynamic> updatedProduct = Map();
//      updatedProduct['category'] = null;
//      updatedProduct['categoryName'] = null;

      final Map<String, dynamic> updatedProduct = {'category': null, 'categoryName': null};

      logger.d('running batch write');

      // Init batch write
      final WriteBatch batch = _store.batch();

      // Update all orders of the product with category
      await _updateOrdersWithCategory(batch, category.uuid, category.userId);

      // Update all products of the category
      await _updateProductsWithCategory(batch, category.uuid, category.userId, updatedProduct);

      // Delete category
      batch.delete(_store.collection('users').document(category.userId).collection('categories').document(category.id));

      batch.commit();

      logger.d('Delete category success');
      return true;
    } catch (error) {
      logger.e('Delete category error: $error');
      return false;
    }
  }

  _updateProductsWithCategory(
      WriteBatch batch, String categoryUuid, String userId, final Map<String, dynamic> updatedProduct) async {
    logger.d('update product with category');

    // Get all products of the category
    final QuerySnapshot productsQuerySnapshot = await _store
        .collection('users')
        .document(userId)
        .collection('products')
        .where('category.uuid', isEqualTo: categoryUuid)
        .getDocuments();

    productsQuerySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
      // Update products with new category
      batch.updateData(documentSnapshot.reference, updatedProduct);
    });
  }

  _updateOrdersWithCategory(WriteBatch batch, String categoryUuid, String userId) async {
    logger.d('update orders with category');

    // Get all orders of the product
    final QuerySnapshot ordersQuerySnapshot = await _store
        .collection('users')
        .document(userId)
        .collection('orders')
        .where('completed', isEqualTo: false)
        .where('categoryUuids', arrayContains: categoryUuid)
        .getDocuments();

    ordersQuerySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
      final Order order = Order.fromSnapshot(documentSnapshot);
      final CartItem item = order.cart.items
          .firstWhere((CartItem item) => item.product.category.uuid == categoryUuid, orElse: () => null);
      // Remove product from cart
      order.cart.remove(item.product, item.quantity);

      final List<CartItem> items = order.cart.items;
      final List<String> productUuids = items.map((CartItem cartItem) => cartItem.product.uuid).toList();
      final List<String> categoryUuids = items.map((CartItem cartItem) => cartItem.product.category?.uuid).toList();

      final Map<String, dynamic> updatedOrder = Map();
      updatedOrder['cart'] = order.cart.toJson();
      updatedOrder['productUuids'] = productUuids;
      updatedOrder['categoryUuids'] = categoryUuids;
      logger.d('updatedOrder: $updatedOrder');

      // Update order without updated product
      batch.updateData(documentSnapshot.reference, updatedOrder);
    });
  }
}
