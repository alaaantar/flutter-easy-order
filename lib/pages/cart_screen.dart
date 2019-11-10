import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/cart_bloc.dart';
import 'package:flutter_easy_order/bloc/category_bloc.dart';
import 'package:flutter_easy_order/bloc/product_bloc.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/pages/category_edit_screen.dart';
import 'package:flutter_easy_order/pages/product_edit_screen.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:flutter_easy_order/widgets/orders/cart_item_list.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:flutter_easy_order/widgets/ui_elements/badge.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = '/order_cart';

  CartScreen();

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  ProductBloc _productBloc;
  CategoryBloc _categoryBloc;
  CartBloc _cartBloc;

  final Logger logger = getLogger();

  // CHECK FIRST IF WE HAVE AT LEAST 1 CATEGORY AND 1 PRODUCT !
  Stream<int> _productsCount$;
  Stream<List<Category>> _categories$;
  Stream<int> _cartItemsCount$;

  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0, keepPage: false);

    _productBloc = Provider.of<ProductBloc>(context, listen: false);
    _categoryBloc = Provider.of<CategoryBloc>(context, listen: false);
    _cartBloc = Provider.of<CartBloc>(context, listen: false);
    _productsCount$ = _productBloc.productsCount$;
    _categories$ = _categoryBloc.categories$;
    _cartItemsCount$ = _cartBloc.cartItemsCount$;
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _buildShoppingCartBadge() {
    return StreamBuilder<int>(
        stream: _cartItemsCount$,
        builder: (context, snapshot) {
          final String count = (snapshot.hasData) ? '${snapshot.data}' : '0';
          return Badge(
            color: Colors.red,
            value: count,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.shopping_cart,
                size: 30.0,
              ),
            ),
          );
        });
  }

  Future<bool> _onBackPressed() {
    Navigator.pop(context, 'Back pressed'); // Navigator.pop(context, _cartBloc.items);
    return Future.value(false);
  }

  Future<bool> _onDone() {
    Navigator.pop(context, 'Done'); // Navigator.pop(context, _cartBloc.items);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final String pageTitle = 'Choose Products';
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: _buildCategoriesStreamBuilder(pageTitle),
    );
  }

  Widget _buildCategoriesStreamBuilder(String pageTitle) {
    return StreamBuilder<List<Category>>(
        stream: _categories$,
        builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(pageTitle),
              ),
              body: Center(child: AdaptiveProgressIndicator()),
            );
          } else if (snapshot.data.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: Text(pageTitle),
              ),
              body: Center(child: Text('Please add a category first !')),
              floatingActionButton: _buildAddCategoryButton(),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            );
          }

          return _buildProductsStreamBuilder(pageTitle, snapshot.data);
//          return _buildTabController(pageTitle, snapshot.data);
        });
  }

  Widget _buildProductsStreamBuilder(String pageTitle, List<Category> categories) {
    return StreamBuilder<int>(
        stream: _productsCount$,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(pageTitle),
              ),
              body: Center(child: AdaptiveProgressIndicator()),
            );
          } else if (snapshot.data <= 0) {
            return Scaffold(
              appBar: AppBar(
                title: Text(pageTitle),
              ),
              body: Center(child: Text('Please add a product first !')),
              floatingActionButton: _buildAddProductButton(),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            );
          }

          return _buildTabController(pageTitle, categories);
        });
  }

  Widget _buildTabController(String pageTitle, List<Category> categories) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          actions: <Widget>[
            _buildShoppingCartBadge(),
          ],
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Colors.white,
            ),
            isScrollable: true,
            indicatorColor: Colors.indigo[100],
            onTap: (index) {
              logger.d('tab index: $index ${categories[index].name}');
//              _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
              _pageController.jumpToPage(index);
            },
            tabs: List<Widget>.generate(categories.length, (int index) {
              final Category category = categories[index];
//              final Widget image = category.image == null
//                  ? Image.asset(
//                      'assets/placeholder.jpg',
//                      width: 24.0,
//                    )
//                  : FadeInImage.assetNetwork(
//                      image: category.image,
//                      fit: BoxFit.cover,
//                      placeholder: 'assets/placeholder.jpg',
//                      width: 24.0,
//                    );

              return Tab(
                text: category.name,
//                icon: image,
              );
            }),
          ),
        ),
        // https://github.com/flutter/flutter/issues/28345
//        body: IndexedStack(
//          body: TabBarView(
//            children: List<Widget>.generate(categories.length, (int index) {
//              return _buildCartItemList(categories[index]);
//            }),
//          ),
        body: PageView.builder(
          controller: _pageController,
          itemBuilder: (BuildContext context, int index) {
            return _buildCartItemList(categories[index]);
          },
          itemCount: categories.length,
        ),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          icon: Icon(Icons.add),
          label: Text('DONE'),
          onPressed: _onDone,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildCartItemList(Category category) {
    return CartItemList(category: category);
  }

  Widget _buildAddCategoryButton() {
    return FloatingActionButton.extended(
      elevation: 4.0,
      icon: Icon(Icons.add),
      label: Text('ADD CATEGORY'),
      onPressed: _openEditCategoryScreen,
    );
  }

  _openEditCategoryScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: CategoryEditScreen.routeName), builder: (context) => CategoryEditScreen()));
  }

  Widget _buildAddProductButton() {
    return FloatingActionButton.extended(
      elevation: 4.0,
      icon: Icon(Icons.add),
      label: Text('ADD PRODUCT'),
      onPressed: _openEditProductScreen,
    );
  }

  _openEditProductScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: ProductEditScreen.routeName), builder: (context) => ProductEditScreen()));
  }
}
