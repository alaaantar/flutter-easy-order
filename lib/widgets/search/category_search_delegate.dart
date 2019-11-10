import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/category_bloc.dart';
import 'package:flutter_easy_order/widgets/categories/category_list.dart';
import 'package:provider/provider.dart';

class CategorySearchDelegate extends SearchDelegate {

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
//    theme.copyWith(
//      hintColor: Colors.white,
//      textTheme: theme.textTheme.copyWith(
//        title: theme.textTheme.title.copyWith(
//          color: Colors.white,
//        ),
//      ),
//    );
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
//          _filter(context, query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        query = '';
        _filter(context, query);
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _filter(context, query);
    return CategoryList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  _filter(BuildContext context, String query) {
    final categoryBloc = Provider.of<CategoryBloc>(context, listen: false);
    categoryBloc.filter(name: query);
  }
}
