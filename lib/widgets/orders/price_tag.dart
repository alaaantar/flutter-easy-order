import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {
  final double price;
  final Color color;

  const PriceTag({
    Key key,
    @required this.price,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final String priceAsString = price?.toStringAsFixed(2) ?? '0.00';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
          color: color != null ? color : Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(5.0)),
      child: Text(
        '\$ $priceAsString',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
