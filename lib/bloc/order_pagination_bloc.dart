import 'package:flutter/material.dart';
import 'package:flutter_easy_order/models/order.dart';
import 'package:flutter_easy_order/models/order_filter.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/repository/order_repository.dart';
import 'package:flutter_easy_order/shared/global_config.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

abstract class OrderPaginationBloc with ChangeNotifier {
  List<Order> get orders;

  Stream<int> get ordersCount$;

  bool get isLoading;

  Stream<OrderFilter> get orderFilter$;

  Future<void> handlePagination({@required bool completed, @required DateTime lastDate, @required int index});

  void refresh({@required OrderFilter filter});

  void dispose();
}

class OrderPaginationBlocImpl with ChangeNotifier implements OrderPaginationBloc {
  final User user;
  final OrderRepository orderRepository;

  final Logger logger = getLogger();

  final PublishSubject<int> _ordersCountSubject = PublishSubject<int>(); //.seeded(0);
  List<Order> _orders = [];
  int _currentPage = 0;
  bool _isLoading = false;

  final _filterSubject = PublishSubject<OrderFilter>();

  OrderPaginationBlocImpl({@required this.user, @required this.orderRepository}) {
    assert(user != null && orderRepository != null, 'Invalid parameters !');

    _filterSubject.listen((OrderFilter filter) async {
      await _refresh(completed: filter.completed);
    });
  }

  @override
  List<Order> get orders => this._orders;

  @override
  Stream<int> get ordersCount$ => _ordersCountSubject.stream;

  @override
  bool get isLoading => this._isLoading;

  @override
  Stream<OrderFilter> get orderFilter$ => this._filterSubject.stream;

  @override
  refresh({@required OrderFilter filter}) {
    assert(filter != null);
    _filterSubject.add(filter);
  }

  @override
  handlePagination({@required bool completed, @required DateTime lastDate, @required int index}) async {
    var itemPosition = index + 1;
    var nextPage = itemPosition ~/ PAGE_SIZE;
    var isLastItemInPage = itemPosition % PAGE_SIZE == 0;
    var isLoadNextPage = isLastItemInPage && nextPage > _currentPage;

    if (isLoadNextPage) {
      _orders.add(null);
      notifyListeners();

      _currentPage = nextPage;

      final List<Order> orders = await orderRepository.find(user: user, pageSize: PAGE_SIZE, completed: completed, lastDate: lastDate);
      _orders.remove(null);
      _orders.addAll(orders);
      _ordersCountSubject.add(_orders.length);
      notifyListeners();
    }
  }

  Future<void> _refresh({bool completed}) async {
    _isLoading = true;
    notifyListeners();

    _currentPage = 0;

    final List<Order> orders = await orderRepository.find(user: user, pageSize: PAGE_SIZE, completed: completed);
    _orders.clear();
    _orders.addAll(orders);
    _ordersCountSubject.add(_orders.length);
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    logger.d('*** DISPOSE OrderPaginationBloc ***');
    _ordersCountSubject.close();
    _filterSubject.close();
    super.dispose();
  }
}
