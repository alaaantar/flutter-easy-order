import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/cart_bloc.dart';
import 'package:flutter_easy_order/models/order.dart';
import 'package:flutter_easy_order/pages/order_edit_screen.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:flutter_easy_order/widgets/orders/price_tag.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class OrderListTile extends StatefulWidget {
  final Order order;

  OrderListTile({@required this.order}) : assert(order != null);

  @override
  _OrderListTileState createState() => _OrderListTileState();
}

class _OrderListTileState extends State<OrderListTile> {
  final Logger logger = getLogger();

  Widget _buildEditButton(BuildContext context, Order order) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () => _openOrderEditScreen(order),
    );
  }

  _openOrderEditScreen(Order order) {
    // final variable to avoid recreation of the screen every time when the keyboard is opened or closed in this screen.
    final Widget orderEditScreen = Provider<CartBloc>(
      builder: (BuildContext context) => CartBlocImpl(cart: order.cart),
      dispose: (BuildContext context, cartBloc) => cartBloc.dispose(),
      child: OrderEditScreen(order),
    );

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        settings: RouteSettings(name: OrderEditScreen.routeName),
        builder: (BuildContext context) {
          return orderEditScreen;
        },
      ),
    ).then((value) {
      logger.d('Back to order list');
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat format = DateFormat("EEEE MMMM d, yyyy 'at' h:mm a");
    final String dateAsString = format.format(widget.order.date);
    final Color color = widget.order.completed ? Colors.red : Colors.green;

    return Column(
      children: <Widget>[
        Card(
//          color: Colors.indigo[100],
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
//          side: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
          child: InkWell(
            splashColor: Theme.of(context).primaryColor,
            onTap: () => _openOrderEditScreen(widget.order),
            child: ListTile(
              title: Text(
                'Order#: ${widget.order.number}',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              subtitle: Column(
                children: <Widget>[
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    'Client ID : ${widget.order.clientId}',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    dateAsString,
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                  PriceTag(
                    price: widget.order.cart.price,
                    color: color,
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
//            leading: Text('${_order.clientId}'),
              trailing: _buildEditButton(context, widget.order),
//            isThreeLine: true,
            ),
          ),
        ),
        Divider()
      ],
    );
  }
}
