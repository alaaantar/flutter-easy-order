import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/cart_bloc.dart';
import 'package:flutter_easy_order/bloc/product_bloc.dart';
import 'package:flutter_easy_order/models/cart.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/models/product.dart';
import 'package:flutter_easy_order/widgets/orders/cart_item_list_tile.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:provider/provider.dart';

class CartItemList extends StatefulWidget {
  final Category category;

  CartItemList({@required this.category})
  : assert(category != null);

  @override
  _CartItemListState createState() => _CartItemListState();
}

class _CartItemListState extends State<CartItemList> { //with AutomaticKeepAliveClientMixin<CartItemList> {

//  @override
//  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return _buildCartItemList(context, widget.category);
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: AdaptiveProgressIndicator(),
    );
  }

  Widget _buildCartItemList(BuildContext context, Category selectedCategory) {

    final ProductBloc productBloc = Provider.of<ProductBloc>(context, listen: false);
    final CartBloc cartBloc = Provider.of<CartBloc>(context, listen: false);
    final Stream<List<Product>> productsByCategory$ = productBloc.filterByCategory(category: selectedCategory);
    final Stream<Cart> cart$ = cartBloc.cart$;
    final Stream<List<CartItem>> allItemsByCategory$ = cartBloc.findAllItems(cart$, productsByCategory$);

    return StreamBuilder(
        stream: allItemsByCategory$,
        builder: (BuildContext context, AsyncSnapshot<List<CartItem>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return _buildLoadingIndicator(context);
          }

          if (snapshot.data.length <= 0) {
            return Center(child: Text('No product found !'));
          }

          return ListView.separated(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              CartItem cartItem = snapshot.data[index];
              return CartItemListTile(cartItem: cartItem);
            },
            itemCount: snapshot.data.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
          );
        });
  }
}
