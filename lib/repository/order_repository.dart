import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:flutter_easy_order/models/order.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:firebase_performance/firebase_performance.dart';

abstract class OrderRepository {

  Stream<List<Order>> stream({@required User user, bool completed});

  Future<List<Order>> find({@required User user, int pageSize, bool completed, DateTime lastDate});

  Future<bool> create({@required Order order});

  Future<bool> update({@required String orderId, @required Order order});

  Future<bool> delete({@required String orderId, @required String userId});
}

class OrderRepositoryFirebaseImpl implements OrderRepository {
  final Firestore _store = Firestore.instance;
  final Logger logger = getLogger();

  @override
  Future<List<Order>> find({@required User user, int pageSize, bool completed, DateTime lastDate}) async {

    //TODO
//    FieldValue.increment(1.0);




    logger.d('find orders: pageSize=$pageSize, completed=$completed, lastDate=$lastDate');

    if (user == null || user.id == null) {
      logger.e('user is null');
      return Future.value([]);
    }

    // Firebase performance trace
    final Trace trace = FirebasePerformance.instance.newTrace("orders_fetch");
    trace.putAttribute("userId", user.id);
    trace.start();

    try {
      // Find documents by user id
      CollectionReference ref = _store.collection('users').document(user.id).collection('orders');

      final bool descending = completed ? true : false;
      Query query = ref.orderBy('date', descending: descending);

      if (completed != null) {
        query = query.where('completed', isEqualTo: completed);
      }

      if (lastDate != null) {
        query = descending ? query.where('date', isLessThan: lastDate) : query.where('date', isGreaterThan: lastDate);
      }

      if (pageSize != null) {
        query = query.limit(pageSize);
      }

      final QuerySnapshot querySnapshot = await query.getDocuments();
      final List<Order> orders = querySnapshot.documents
          .map((DocumentSnapshot documentSnapshot) => Order.fromSnapshot(documentSnapshot))
          .toList();

      trace.stop();

      return orders;
    } on Exception catch (ex) {
      logger.e(ex);
      trace.stop();
      return Future.value([]);
    }
  }

  @override
  Stream<List<Order>> stream({@required User user, bool completed}) {
    logger.d('stream orders: completed=$completed');
//    return Observable(this.user$).switchMap((User user) {

    if (user == null || user.id == null) {
      logger.e('user is null');
      return Stream.empty();
    }

    try {
      // Find documents by user id
      CollectionReference ref = _store.collection('users').document(user.id).collection('orders');

      Query query = ref.orderBy('date');
      if (completed != null) {
        query = query.where('completed', isEqualTo: completed);
      }

      final Stream<List<Order>> orders$ = query.snapshots().map((QuerySnapshot querySnapshot) {
        final List<Order> orders = querySnapshot.documents
            .map((DocumentSnapshot documentSnapshot) => Order.fromSnapshot(documentSnapshot))
            .toList();
        return orders;
      });

      return orders$;
    } on Exception catch (ex) {
      logger.e(ex);
      return Stream.empty();
    }
  }

  @override
  Future<bool> create({@required Order order}) async {
    if (order == null ||
        order.userId == null ||
        order.userEmail == null ||
        order.clientId == null ||
        order.date == null ||
        order.completed == null ||
        order.number == null ||
        order.uuid == null ||
        order.cart == null) {
      logger.e('Invalid parameters');
      return false;
    }

    try {
      final List<CartItem> items = order.cart.items;
      final List<String> productUuids = items.map((CartItem cartItem) => cartItem.product.uuid).toList();
      final List<String> categoryUuids = items.map((CartItem cartItem) => cartItem.product.category?.uuid).toList();

      final Map<String, dynamic> orderData = order.toJson();
      orderData['createdDateTime'] = FieldValue.serverTimestamp(); // DateTime.now();
      orderData['productUuids'] = productUuids;
      orderData['categoryUuids'] = categoryUuids;
      logger.d('orderData: $orderData');

      // Add document by user id
      DocumentReference docRef =
          await _store.collection('users').document(order.userId).collection('orders').add(orderData);
      logger.d('Create success: new order ID= ${docRef.documentID}');
      return true;
    } catch (error) {
      logger.e('addOrder error: $error');
      return false;
    }
  }

  @override
  Future<bool> update({@required String orderId, @required Order order}) async {
    if (orderId == null ||
        order == null ||
        order.userId == null ||
        order.userEmail == null ||
        order.clientId == null ||
        order.date == null ||
        order.completed == null ||
        order.number == null ||
        order.uuid == null ||
        order.cart == null) {
      logger.e('Invalid parameters');
      return false;
    }

    try {
      final List<CartItem> items = order.cart.items;
      final List<String> productUuids = items.map((CartItem cartItem) => cartItem.product.uuid).toList();
      final List<String> categoryUuids = items.map((CartItem cartItem) => cartItem.product.category?.uuid).toList();

      final Map<String, dynamic> updatedOrder = order.toJson();
      updatedOrder['updatedDateTime'] = FieldValue.serverTimestamp(); // DateTime.now();
      updatedOrder['productUuids'] = productUuids;
      updatedOrder['categoryUuids'] = categoryUuids;
      logger.d('updatedOrder: $updatedOrder');

      await _store.runTransaction((transaction) async {
        await transaction.update(
            // Update document by user id
            _store.collection('users').document(order.userId).collection('orders').document(orderId),
            updatedOrder);
      });

      logger.d('Update success');
      return true;
    } catch (error) {
      logger.e('updateOrder error: $error');
      return false;
    }
  }

  @override
  Future<bool> delete({@required String orderId, @required String userId}) {
    if (orderId == null || userId == null) {
      logger.e('Invalid parameters');
      return Future.value(false);
    }

    return _store.runTransaction((transaction) {
      return transaction.delete(
          // Delete document by user id
          _store.collection('users').document(userId).collection('orders').document(orderId));
    }).then((_) {
      logger.d('Delete order success');
      return true;
    }).catchError((error) {
      logger.e('Delete order error: $error');
      return false;
    });
  }
}
