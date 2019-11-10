import 'package:flutter/material.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:flutter_easy_order/models/product.dart';
import 'package:flutter_easy_order/widgets/orders/price_tag.dart';

class OrderItemsListTile extends StatelessWidget {

  final CartItem item;

  OrderItemsListTile({@required this.item})
  : assert(item != null);

  @override
  Widget build(BuildContext context) {

    final Product product = item.product;
    final double itemTotalPrice = product.price * item.quantity;

    return ListTile(
      title: Text('${product.name}'),
//      subtitle: Text('Quantity: ${item.quantity}'),
//      leading: CircleAvatar(
//        backgroundImage: item.product.image == null
//            ? AssetImage('assets/placeholder.jpg')
//            : NetworkImage(item.product.image),
//      ),
    leading: Text('${item.quantity} x'),
      trailing: PriceTag(price: itemTotalPrice),
    );
//    return Text('$item');
  }
}
