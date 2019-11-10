import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easy_order/bloc/product_bloc.dart';
import 'package:flutter_easy_order/models/product.dart';
import 'package:flutter_easy_order/widgets/products/product_list_tile.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  ProductBloc _productBloc;
  Stream<List<Product>> _products$;
//  ScrollController _scrollController;

//  @override
//  void initState() {
//    _scrollController = ScrollController();
//    super.initState();
//  }
//
//  @override
//  void dispose() {
//    _scrollController.dispose();
//    super.dispose();
//  }

  @override
  void initState() {
    _productBloc = Provider.of<ProductBloc>(context, listen: false);
    _products$ = _productBloc.products$;
    super.initState();
  }

  Widget _buildProductStreamedList(BuildContext context) {
    return StreamBuilder(
      stream: _products$,
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return _buildLoadingIndicator(context);
        }

        if (snapshot.data.isEmpty) {
          return Center(child: Text('No product found !'));
        }

        // Init scroll direction
//        ScrollDirection scrollDirection = ScrollDirection.idle;

//        return NotificationListener<ScrollUpdateNotification>(
//          onNotification: (ScrollUpdateNotification notification) {
//            final double scrollDelta = notification.scrollDelta;
//            scrollDirection = scrollDelta > 0.0 ? ScrollDirection.forward : (scrollDelta < 0.0 ? ScrollDirection.reverse : ScrollDirection.idle);
//            return null;
//          },
//          child:
          return ListView.separated(
//            controller: _scrollController,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(10.0),
            itemCount: snapshot.data.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (context, index) {
              final Product product = snapshot.data[index];
              final Product previousProduct = index >= 1 ? snapshot.data[index - 1] : null;
//              final Product nextProduct = index < snapshot.data.length - 1 ? snapshot.data[index + 1] : null;
              final bool displayHeader = index == 0 || product.category != previousProduct.category;

              return StickyHeader(
                header: !displayHeader
                    ? Container(
                        width: 0.0,
                        height: 0.0,
                      )
                    : Container(
                        height: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.indigo[100],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          product.category == null ? 'No category' : '${product.category.name}',
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20.0),
                        ),
                      ),
                content: ProductListTile(product: product),
              );
            },
        );
      },
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: AdaptiveProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductStreamedList(context);
  }
}
