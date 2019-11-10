import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/product_bloc.dart';
import 'package:flutter_easy_order/pages/product_edit_screen.dart';
import 'package:flutter_easy_order/widgets/products/product_list.dart';
import 'package:flutter_easy_order/widgets/ui_elements/logout_button.dart';
import 'package:flutter_easy_order/widgets/ui_elements/side_drawer.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  static const String routeName = '/products';

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {

  ProductBloc _productBloc;
  Stream<int> _productsCount$;

  @override
  void initState() {
    _productBloc = Provider.of<ProductBloc>(context, listen: false);
    _productsCount$ = _productBloc.productsCount$;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: Text('Products'),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        actions: <Widget>[
          _buildChip(),
          LogoutButton(),
        ],
      ),
      body: ProductList(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(name: ProductEditScreen.routeName),
              builder: (context) => ProductEditScreen()));
        },
      ),
    );
  }

  Widget _buildChip() {
    return StreamBuilder<int>(
        stream: _productsCount$,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          final String count = snapshot.hasData ? snapshot.data.toString() : '0';
          return Chip(
            label: Text(count),
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).accentColor,
          );
        }
    );
  }

}
