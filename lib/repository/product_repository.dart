import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/models/order.dart';
import 'package:flutter_easy_order/models/product.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

abstract class ProductRepository {
  Stream<List<Product>> findByCategoryAndUser({@required Category category, @required User user});

  Stream<List<Product>> findByUserOrderByCategory({@required User user});

  Future<bool> create({@required Product product});

  Future<bool> update({@required String productId, @required Product product});

  Future<bool> delete({@required Product product});
}

class ProductRepositoryFirebaseImpl implements ProductRepository {
  final Firestore _store = Firestore.instance;
  final Logger logger = getLogger();

  @override
  Stream<List<Product>> findByCategoryAndUser({@required Category category, @required User user}) {
    logger.d('find products by category: ${category.name}');
//    return Observable(this.user$).switchMap((User user) {

    if (user == null || user.id == null) {
      logger.e('user is null');
      return Stream.empty();
    }

    try {
      // Find documents by user id
      final Stream<List<Product>> products$ = _store
          .collection('users')
          .document(user.id)
          .collection('products')
          .where('category.uuid', isEqualTo: category.uuid)
          .orderBy('name')
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        final List<Product> products = querySnapshot.documents
            .map((DocumentSnapshot documentSnapshot) => Product.fromSnapshot(documentSnapshot))
            .toList();
//      _productsCountSubject.add(products.length);
        return products;
      });

      return products$;
    } on Exception catch (ex) {
      logger.e(ex);
      return Stream.empty();
    }
//    });
  }

  @override
  Stream<List<Product>> findByUserOrderByCategory({@required User user}) {
    logger.d('find products order by category');
//    return Observable(this.user$).switchMap((User user) {

    if (user == null || user.id == null) {
      logger.e('user is null');
      return Stream.empty();
    }

    try {
      // Find products with category
      final Stream<List<Product>> products$ = _store
          .collection('users')
          .document(user.id)
          .collection('products')
          .orderBy('categoryName')
          .orderBy('name')
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        final List<Product> products = querySnapshot.documents
            .map((DocumentSnapshot documentSnapshot) => Product.fromSnapshot(documentSnapshot))
            .toList();
        return products;
      });

      return products$;
    } on Exception catch (ex) {
      logger.e(ex);
      return Stream.empty();
    }
//    });
  }

  @override
  Future<bool> create({@required Product product}) async {
    if (product == null ||
        product.userId == null ||
        product.userEmail == null ||
        product.uuid == null ||
        product.name == null ||
        product.description == null ||
        product.category == null ||
        product.price == null) {
      logger.e('Invalid parameters');
      return false;
    }

    try {
      final Map<String, dynamic> productAsJson = product.toJson();
      productAsJson['createdDateTime'] = FieldValue.serverTimestamp(); // DateTime.now();
      productAsJson['categoryName'] = product.category?.name;
      logger.d('productData: $productAsJson');

      // Add document by user id
      DocumentReference docRef =
          await _store.collection('users').document(product.userId).collection('products').add(productAsJson);
      logger.d('Create success: new product ID= ${docRef.documentID}');
      return true;
    } catch (error) {
      logger.e('add product error: $error');
      return false;
    }
  }

  @override
  Future<bool> update({@required String productId, @required Product product}) async {
    if (productId == null ||
        product == null ||
        product.userId == null ||
        product.userEmail == null ||
        product.uuid == null ||
        product.name == null ||
        product.description == null ||
        product.category == null ||
        product.price == null) {
      logger.e('Invalid parameters');
      return false;
    }

    try {
      final Map<String, dynamic> productAsJson = product.toJson();
      productAsJson['updatedDateTime'] = FieldValue.serverTimestamp(); // DateTime.now();
      productAsJson['categoryName'] = product.category?.name;
      logger.d('updatedProduct: $productAsJson');

      logger.d('running batch write');

      // Init batch write
      final WriteBatch batch = _store.batch();

      // Update order cart
      await _updateOrdersWithProduct(batch, product.uuid, product.userId, product);

      // Update product
      batch.updateData(_store.collection('users').document(product.userId).collection('products').document(productId),
          productAsJson);

      batch.commit();

      logger.d('Update success');
      return true;
    } catch (error) {
      logger.e('updateProduct error: $error');
      return false;
    }
  }

  @override
  Future<bool> delete({@required Product product}) async {
    if (product == null || product.userId == null || product.uuid == null || product.id == null) {
      logger.e('Invalid parameters');
      return false;
    }

    try {
      logger.d('running batch write');

      // Init batch write
      final WriteBatch batch = _store.batch();

      // Update order cart
      await _updateOrdersWithProduct(batch, product.uuid, product.userId, null);

      // Delete product
      batch.delete(_store.collection('users').document(product.userId).collection('products').document(product.id));

      batch.commit();

      logger.d('Delete product success');
      return true;
    } catch (error) {
      logger.e('Delete product error: $error');
      return false;
    }
  }

  _updateOrdersWithProduct(WriteBatch batch, String productUuid, String userId, Product updatedProduct) async {
    logger.d('update order with product');

    // Get all orders of the product
    final QuerySnapshot ordersQuerySnapshot = await _store
        .collection('users')
        .document(userId)
        .collection('orders')
        .where('completed', isEqualTo: false)
        .where('productUuids', arrayContains: productUuid)
        .getDocuments();

    ordersQuerySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
      final Order order = Order.fromSnapshot(documentSnapshot);
      final CartItem item =
          order.cart.items.firstWhere((CartItem item) => item.product.uuid == productUuid, orElse: () => null);

      if (updatedProduct == null) {
        // Remove product from cart
        order.cart.remove(item.product, item.quantity);
      } else {
        // Update cart with updated product
        item.product = updatedProduct;
      }

      final List<CartItem> items = order.cart.items;
      final List<String> productUuids = items.map((CartItem cartItem) => cartItem.product.uuid).toList();
      final List<String> categoryUuids = items.map((CartItem cartItem) => cartItem.product.category?.uuid).toList();

      final Map<String, dynamic> updatedOrder = {
        'cart': order.cart.toJson(),
        'productUuids': productUuids,
        'categoryUuids': categoryUuids,
      };
      logger.d('updatedOrder: $updatedOrder');

      // Update orders with new product
      batch.updateData(documentSnapshot.reference, updatedOrder);
    });
  }
}
