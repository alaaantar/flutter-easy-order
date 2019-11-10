import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter_easy_order/models/order.dart';
import 'package:flutter_easy_order/models/order_filter.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/repository/order_repository.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

abstract class OrderBloc {

  Stream<List<Order>> get orders$;

  Stream<int> get ordersCount$;

  Future<bool> create({@required Order order});

  Future<bool> update({@required String orderId, @required Order order});

  Future<bool> delete({@required String orderId, @required String userId});

  void dispose();
}

class OrderBlocImpl implements OrderBloc {
  final User user;
  final OrderRepository orderRepository;

  final Logger logger = getLogger();

  final PublishSubject<int> _ordersCountSubject = PublishSubject<int>(); //.seeded(0);
  final PublishSubject<List<Order>> _ordersSubject = PublishSubject<List<Order>>(); //.seeded([]);
  final PublishSubject<OrderFilter> _filterSubject = PublishSubject<OrderFilter>();

  OrderBlocImpl({@required this.user, @required this.orderRepository}) {
    assert(user != null && orderRepository != null, 'Invalid parameters !');
  }

  @override
  Stream<int> get ordersCount$ => _ordersCountSubject.stream;

  @override
  Stream<List<Order>> get orders$ => _ordersSubject.stream;

  @override
  Future<bool> create({@required Order order}) async {
    logger.d('add order');

    if (order == null || user == null) {
      logger.e('order or user is null');
      return false;
    }

    final Uuid uuid = Uuid();
    final DateFormat format = DateFormat("yyyyMMddhhMMss");

    final Order orderToCreate = Order.clone(order);
    orderToCreate.uuid = uuid.v4();
//    orderData['number'] = DateTime.now().millisecondsSinceEpoch;
    orderToCreate.number = format.format(DateTime.now());
    orderToCreate.completed = false;
    orderToCreate.userId = user.id;
    orderToCreate.userEmail = user.email;

    return orderRepository.create(order: orderToCreate);
  }

  @override
  Future<bool> update({@required String orderId, @required Order order}) async {
    logger.d('update order: $orderId');

    if (order == null || orderId == null) {
      logger.e('order or orderId is null');
      return false;
    }

    return orderRepository.update(orderId: orderId, order: order);
  }

  @override
  Future<bool> delete({@required String orderId, @required String userId}) {
    logger.d('delete order: $orderId');

    if (userId == null || orderId == null) {
      logger.e('userId or orderId is null');
      return Future.value(false);
    }

    return orderRepository.delete(orderId: orderId, userId: userId);
  }

  @override
  void dispose() {
    logger.d('*** DISPOSE OrderBloc ***');
    _ordersCountSubject.close();
    _ordersSubject.close();
    _filterSubject.close();
  }
}
