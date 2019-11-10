import 'dart:collection';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:flutter_easy_order/models/product.dart';

class Cart {
  /// Creates an empty cart.
//  Cart();

  List<CartItem> cartItems = <CartItem>[];

  /// Creates a cart with items.
  Cart({@required this.cartItems}) {
//    _items.sort((CartItem item1, CartItem item2) => item1.product.name.compareTo(item2.product.name));
  }

  /// Creates a Cart from another Cart
  Cart.clone(Cart cart) {
    cartItems.addAll(cart.cartItems);
  }

  double get price => cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  /// The total count of items in cart, including duplicates of the same item.
  ///
  /// This is in contrast of just doing [items.length], which only counts
  /// each product once, regardless of how many are being bought.
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// This is the current state of the cart.
  ///
  /// This is a list because users expect their cart items to be in the same
  /// order they bought them.
  ///
  /// It is an unmodifiable view because we don't want a random widget to
  /// put the cart into a bad state. Use [add] and [remove] to modify the state.
  UnmodifiableListView<CartItem> get items => UnmodifiableListView(cartItems);

  /// Adds [product] to cart. This will either update an existing [CartItem]
  /// in [items] or add a one at the end of the list.
  void add(Product product, [int count = 1]) {
    _updateCount(product, count);
  }

  /// Removes [product] from cart. This will either update the count of
  /// an existing [CartItem] in [items] or remove it entirely (if count reaches
  /// `0`.
  void remove(Product product, [int count = 1]) {
    _updateCount(product, -count);
  }

  void _updateCount(Product product, int difference) {
    if (difference == 0 || product == null) {
      return;
    }

    for (int i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      if (product == item.product) {
        final newCount = item.quantity + difference;
        if (newCount <= 0) {
          cartItems.removeAt(i);
          return;
        }
        cartItems[i] = CartItem(product: item.product, quantity: newCount);
        return;
      }
    }

    if (difference < 0) {
      return;
    }

    cartItems.add(CartItem(product: product, quantity: max(difference, 0)));
  }

  void addAll(List<CartItem> cartItems) {
    cartItems.forEach((cartItem) => add(cartItem.product, cartItem.quantity));
  }

  List<Map<String, dynamic>> toJson() {
    return this.cartItems.map((item) => item.toJson()).toList();
  }

  factory Cart.fromJson(List<dynamic> jsonList) {
    List<CartItem> cartItems = [];
    if (jsonList != null) {
      cartItems.addAll(
          jsonList.map<CartItem>((cartItem) => CartItem.fromJson(Map<String, dynamic>.from(cartItem))).toList());
    }
    return Cart(cartItems: cartItems);
  }

  @override
  String toString() => 'items: $cartItems';
}
