import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/category_bloc.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/widgets/categories/category_list_tile.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatefulWidget {

  @override
  _CategoryListListState createState() => _CategoryListListState();
}

class _CategoryListListState extends State<CategoryList> {

  CategoryBloc _categoryBloc;
  Stream<List<Category>> _categories$;

  @override
  void initState() {
    _categoryBloc = Provider.of<CategoryBloc>(context, listen: false);
    _categories$ = _categoryBloc.categories$;
    super.initState();
  }

  Widget _buildCategoryStreamedList(BuildContext context) {
    return StreamBuilder(
      stream: _categories$,
      builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return _buildLoadingIndicator(context);
        }

        if (snapshot.data.isEmpty) {
          return Center(child: Text('No category found !'));
        }

        return ListView.separated(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(10.0),
          itemBuilder: (context, index) {
            Category category = snapshot.data[index];
            return CategoryListTile(category: category);
          },
          itemCount: snapshot.data.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
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
    return _buildCategoryStreamedList(context);
  }
}
