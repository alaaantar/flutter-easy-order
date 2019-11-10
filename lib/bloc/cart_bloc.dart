import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easy_order/models/cart.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:flutter_easy_order/models/product.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

abstract class CartBloc {

  Stream<Cart> get cart$;

  Stream<int> get cartItemsCount$;

  addToCart(CartItem cartItem);

  removeFromCart(CartItem cartItem);

  Stream<List<CartItem>> findAllItems(Stream<Cart> cart$, Stream<List<Product>> products$);

  void dispose();
}

class CartBlocImpl implements CartBloc {
  final Cart cart;

  final Logger logger = getLogger();

  final BehaviorSubject<Cart> _cartSubject = BehaviorSubject<Cart>.seeded(Cart(cartItems: []));
  @override
  Stream<Cart> get cart$ => _cartSubject.stream;

  final BehaviorSubject<int> _cartItemsCountSubject = BehaviorSubject<int>.seeded(0);
  @override
  Stream<int> get cartItemsCount$ => _cartItemsCountSubject.stream;

  // Add / remove items in cart
  final PublishSubject<CartItem> _cartAddSubject = PublishSubject<CartItem>();
  final PublishSubject<CartItem> _cartRemoveSubject = PublishSubject<CartItem>();

  CartBlocImpl({@required this.cart}) {

    assert(this.cart != null);

    // Init cart
    _cartSubject.add(cart);
    _cartItemsCountSubject.add(cart.itemCount);

    // Add cart item
    _cartAddSubject.stream.listen((cartItem) {
      cart.add(cartItem.product, cartItem.quantity);
      _cartItemsCountSubject.add(cart.itemCount);
    }, onError: (error) => logger.e('_cartAddSubject listen error: $error'), cancelOnError: false);

    // Remove cart item
    _cartRemoveSubject.stream.listen((cartItem) {
      cart.remove(cartItem.product, cartItem.quantity);
      _cartItemsCountSubject.add(cart.itemCount);
    }, onError: (error) => logger.e('_cartRemoveSubject listen error: $error'), cancelOnError: false);
  }

  @override
  addToCart(CartItem cartItem) {
    _cartAddSubject.add(cartItem);
  }

  @override
  removeFromCart(CartItem cartItem) {
    _cartRemoveSubject.add(cartItem);
  }

  // Combine all products with cart items
  @override
  Stream<List<CartItem>> findAllItems(Stream<Cart> cart$, Stream<List<Product>> products$) {
    final Stream<List<CartItem>> allItems$ = Observable.combineLatest2(cart$, products$, _calculateProductsQuantity);
    return allItems$;
  }

  List<CartItem> _calculateProductsQuantity(Cart cart, List<Product> products) {
    final List<CartItem> results = [];
    products.forEach((Product product) {
      final CartItem item = cart.items.firstWhere((CartItem item) => product == item.product, orElse: () => null);
      int quantity = item == null ? 0 : item.quantity;

      final CartItem cartItem = CartItem(product: product, quantity: quantity);
      results.add(cartItem);
    });
    return results;
  }

  @override
  void dispose() {
    logger.d('*** DISPOSE CartBloc ***');
    _cartSubject.close();
    _cartItemsCountSubject.close();
    _cartAddSubject.close();
    _cartRemoveSubject.close();
  }
}
