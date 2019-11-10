import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/product_bloc.dart';
import 'package:flutter_easy_order/models/product.dart';
import 'package:flutter_easy_order/pages/product_edit_screen.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:flutter_easy_order/widgets/helpers/ui_helper.dart';
import 'package:flutter_easy_order/widgets/orders/price_tag.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';

class ProductListTile extends StatefulWidget {
  final Product product;

  ProductListTile({@required this.product})
  : assert(product != null);

  @override
  _ProductListTileState createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
  ProductBloc _productBloc;

  final Logger logger = getLogger();

  @override
  void initState() {
    _productBloc = Provider.of<ProductBloc>(context, listen: false);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, Product product) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () => _openProductEditScreen(product),
    );
  }

  _openProductEditScreen(Product product) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
          settings: RouteSettings(name: ProductEditScreen.routeName),
          builder: (BuildContext context) => ProductEditScreen(product)),
    )
        .then((_) {
      logger.d('Back to product list');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart) {
          _productBloc.delete(product: widget.product).then((bool success) {
            final Flushbar flushbar = (success)
                ? UiHelper.createSuccess(message: '${widget.product.name} successfully removed !', title: 'Success !')
                : UiHelper.createError(message: 'Failed to remove ${widget.product.name} !', title: 'Error !');
            flushbar.show(context);
          });
        }
//        else if (direction == DismissDirection.startToEnd) {
//          logger.d('Swiped start to end');
//        } else {
//          logger.d('Other swiping');
//        }
      },
      background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          color: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
                size: 36,
              ),
              Text(
                'DELETE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          )),
      child: Card(
//        color: Colors.indigo[100],
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
//          side: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
        child: InkWell(
          splashColor: Theme.of(context).primaryColor,
          onTap: () => _openProductEditScreen(widget.product),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.product.imageUrl == null
                  ? AssetImage('assets/placeholder.jpg')
                  : NetworkImage(widget.product.imageUrl),
            ),
            title: Text(
              widget.product.name,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            subtitle: Column(
              children: <Widget>[
//                SizedBox(
//                  height: 2.0,
//                ),
//                Text(
//                  widget._product.category == null ? 'No category' : widget._product.category.name,
//                  style: TextStyle(color: Theme.of(context).accentColor),
//                ),
                SizedBox(
                  height: 2.0,
                ),
                PriceTag(price: widget.product.price),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            trailing: _buildEditButton(context, widget.product),
          ),
        ),
      ),
    );
  }
}
