import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_order/pages/category_list_screen.dart';
import 'package:flutter_easy_order/pages/order_list_screen.dart';
import 'package:flutter_easy_order/pages/privacy_policy_screen.dart';
import 'package:flutter_easy_order/pages/product_list_screen.dart';
import 'package:flutter_easy_order/pages/terms_conditions_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideDrawer extends StatelessWidget {
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Simple Order Manager'),
            elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Manage Orders'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  settings: RouteSettings(name: OrderListScreen.routeName), builder: (context) => OrderListScreen()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Manage Products'),
            onTap: () {
//              Navigator.pushReplacementNamed(context, '/');
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  settings: RouteSettings(name: ProductListScreen.routeName),
                  builder: (context) => ProductListScreen()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Manage Categories'),
            onTap: () {
//              Navigator.pushReplacementNamed(context, '/');
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  settings: RouteSettings(name: CategoryListScreen.routeName),
                  builder: (context) => CategoryListScreen()));
            },
          ),
          Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child:
            Container(
              padding: EdgeInsets.only(left: 20.0),
                child: Text(
              'ABOUT',
            ),),
          ),
          Divider(),
          ListTile(
            leading: Icon(FontAwesomeIcons.userLock),
            title: Text('Privacy Policy'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  settings: RouteSettings(name: PrivacyPolicyScreen.routeName),
                  builder: (context) => PrivacyPolicyScreen(isLoggedIn: true)));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(FontAwesomeIcons.fileContract),
            title: Text('Terms & Conditions'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  settings: RouteSettings(name: TermsConditionsScreen.routeName),
                  builder: (context) => TermsConditionsScreen(isLoggedIn: true)));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDrawer(context);
  }
}
