import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/cart_bloc.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:provider/provider.dart';

class CartItemListTile extends StatefulWidget {
  final CartItem cartItem;

  CartItemListTile({@required this.cartItem})
  : assert(cartItem != null);

  @override
  _CartItemListTileState createState() => _CartItemListTileState();
}

class _CartItemListTileState extends State<CartItemListTile> {

  CartBloc _cartBloc;

  int _count = 0;
  bool _isMinusButtonDisabled = false;

  @override
  void initState() {
    _initCount();
    _cartBloc = Provider.of<CartBloc>(context, listen: false);
    super.initState();
  }

  @override
  void didUpdateWidget(CartItemListTile oldWidget) {
    _initCount();
    super.didUpdateWidget(oldWidget);
  }

  void _initCount() {
    _count = widget.cartItem.quantity;
    _isMinusButtonDisabled = _count <= 0 ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: widget.cartItem.product.imageUrl == null
            ? AssetImage('assets/placeholder.jpg')
            : NetworkImage(widget.cartItem.product.imageUrl),
      ),
      title: Text(widget.cartItem.product.name),
      subtitle: Text('\$${widget.cartItem.product.price.toString()}'),
      trailing: _buildAddRemoveButtons(context, widget.cartItem),
    );
  }

  Widget _buildAddRemoveButtons(BuildContext context, CartItem cartItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.remove ),
          onPressed: _isMinusButtonDisabled ? null :  () => _decrement(cartItem),
          disabledColor: Colors.grey,
          color: Colors.black,
        ),
        Text('$_count'),
        IconButton(
          icon: Icon(Icons.add,),
          onPressed: () => _increment(cartItem),
          color: Colors.black,
        ),
      ],
    );
  }

  _increment(CartItem cartItem) {
    _cartBloc.addToCart(CartItem(product: cartItem.product, quantity: 1));
    setState(() {
      _count = _count + 1;
      _isMinusButtonDisabled = _count <= 0 ? true : false;
    });
  }

  _decrement(CartItem cartItem) {
    _cartBloc.removeFromCart(CartItem(product: cartItem.product, quantity: 1));
    setState(() {
      _count = _count - 1;
      _isMinusButtonDisabled = _count <= 0 ? true : false;
    });
  }
}
