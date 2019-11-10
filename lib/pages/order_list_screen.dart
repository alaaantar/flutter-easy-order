import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/cart_bloc.dart';
import 'package:flutter_easy_order/bloc/order_pagination_bloc.dart';
import 'package:flutter_easy_order/models/cart.dart';
import 'package:flutter_easy_order/models/order_filter.dart';
import 'package:flutter_easy_order/pages/order_edit_screen.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:flutter_easy_order/widgets/orders/order_list.dart';
import 'package:flutter_easy_order/widgets/ui_elements/logout_button.dart';
import 'package:flutter_easy_order/widgets/ui_elements/side_drawer.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class OrderListScreen extends StatefulWidget {
  static const String routeName = '/orders';

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
//  OrderBloc _orderBloc;
  OrderPaginationBloc _orderPaginationBloc;
  Stream<int> _ordersCount$;

  int _currentIndex;
  PageController _pageController;

  final Logger logger = getLogger();

  @override
  void initState() {
    _currentIndex = 0;
    _pageController = PageController(
      initialPage: 0,
    );

    _orderPaginationBloc = Provider.of<OrderPaginationBloc>(context, listen: false);
    // Init orders
    final orderFilter = OrderFilter(completed: _currentIndex != 0);
    _orderPaginationBloc.refresh(filter: orderFilter);
    _ordersCount$ = _orderPaginationBloc.ordersCount$;
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final variable to avoid recreation of the screen every time when the keyboard is opened or closed in this screen.
    final Widget orderEditScreen = Provider<CartBloc>(
      builder: (BuildContext context) => CartBlocImpl(cart: Cart(cartItems: [])),
      dispose: (BuildContext context, cartBloc) => cartBloc.dispose(),
      child: OrderEditScreen(),
    );

//    final User currentUser = Provider.of<User>(context);

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        bottom: true,
        top: true,
        child: Scaffold(
          drawer: SideDrawer(),
          appBar: AppBar(
            title: Text('Orders'),
            elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
            actions: <Widget>[
              _buildChip(),
              LogoutButton(),
            ],
          ),
          body: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: <Widget>[
              OrderList(completed: false),
              OrderList(completed: true),
            ],
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              _switchTab(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket),
                title: Text('Current Orders'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time),
                title: Text('Past Orders'),
              ),
            ],
            elevation: 10.0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.indigo[100],
            selectedFontSize: 16.0,
            selectedIconTheme: IconThemeData(size: 30.0),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                    settings: RouteSettings(name: OrderEditScreen.routeName), builder: (context) => orderEditScreen),
              ).then((value) {
                logger.d('Back to order list');
              });
            },
          ),
        ),
      ),
//      ),
    );
  }

  _switchTab(int tabIndex) {
    final orderFilter = OrderFilter(completed: tabIndex != 0);
    _orderPaginationBloc.refresh(filter: orderFilter);
    _pageController.jumpToPage(tabIndex);
  }

  Widget _buildChip() {
    return StreamBuilder<int>(
        stream: _ordersCount$,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          final String count = snapshot.hasData ? snapshot.data.toString() : '0';
          return Chip(
            label: Text(count),
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).accentColor,
          );
        });
  }
}
