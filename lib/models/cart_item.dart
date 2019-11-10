import 'package:meta/meta.dart';
import 'package:flutter_easy_order/models/product.dart';

class CartItem {
  Product product;
  int quantity;

  CartItem({@required this.product, @required this.quantity})
      : assert(product != null && quantity != null);

  Map<String, dynamic> toJson() => {
        'product': this.product.toJson(),
        'quantity': this.quantity,
      };

  CartItem.fromJson(Map<String, dynamic> json)
      : product = Product.fromJson(Map<String, dynamic>.from(json['product'])),
        quantity = json['quantity'];

  @override
  String toString() => "${product.name} X $quantity";
}
