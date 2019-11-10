import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/category_bloc.dart';
import 'package:flutter_easy_order/pages/category_edit_screen.dart';
import 'package:flutter_easy_order/widgets/categories/category_list.dart';
import 'package:flutter_easy_order/widgets/search/category_search_delegate.dart';
import 'package:flutter_easy_order/widgets/ui_elements/logout_button.dart';
import 'package:flutter_easy_order/widgets/ui_elements/side_drawer.dart';
import 'package:provider/provider.dart';

class CategoryListScreen extends StatefulWidget {
  static const String routeName = '/categories';

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {

  CategoryBloc _categoryBloc;
  Stream<int> _categoriesCount$;

  @override
  void initState() {
    _categoryBloc = Provider.of<CategoryBloc>(context, listen: false);
    _categoriesCount$ = _categoryBloc.categoriesCount$;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: Text('Categories'),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        actions: <Widget>[
          _buildChip(),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: CategorySearchDelegate()),
          ),
          LogoutButton(),
        ],
      ),
      body: CategoryList(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(name: CategoryEditScreen.routeName),
              builder: (context) => CategoryEditScreen()));
        },
      ),
    );
  }

  Widget _buildChip() {
    return StreamBuilder<int>(
        stream: _categoriesCount$,
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
