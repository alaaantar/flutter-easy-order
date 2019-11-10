import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easy_order/bloc/order_pagination_bloc.dart';
import 'package:flutter_easy_order/models/order.dart';
import 'package:flutter_easy_order/widgets/orders/order_list_tile.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:provider/provider.dart';

class OrderList extends StatelessWidget {
  final bool completed;

  OrderList({this.completed});

  Widget _buildLoadingIndicator() {
    return Center(
      child: AdaptiveProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderPaginationBloc = Provider.of<OrderPaginationBloc>(context, listen: false);
    var orders = orderPaginationBloc.orders;

    return Consumer<OrderPaginationBloc>(
      builder: (BuildContext context, OrderPaginationBloc orderPaginationBloc, _) {
        return orderPaginationBloc.isLoading
            ? _buildLoadingIndicator()
            : orders.isEmpty
                ? Center(
                    child: Text('No order found!'),
                  )
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      final Order order = orders[index];

                      if (order == null) {
                        return ListTile(
                          title: _buildLoadingIndicator(),
                        );
                      }

                      SchedulerBinding.instance.addPostFrameCallback((duration) {
                        orderPaginationBloc.handlePagination(completed: completed, lastDate: order.date, index: index);
                      });
                      return OrderListTile(order: order);
                    },
                    itemCount: orders.length,
                  );
      },
    );
  }
}
