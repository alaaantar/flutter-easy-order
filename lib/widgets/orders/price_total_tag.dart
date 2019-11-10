import 'package:flutter/material.dart';

class PriceTotalTag extends StatelessWidget {
  final double price;

  const PriceTotalTag({
    Key key,
    @required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final String priceAsString = price?.toStringAsFixed(2) ?? '0.00';

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
//          side: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Total',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '\$  ',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  priceAsString,
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
