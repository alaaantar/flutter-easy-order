import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/category_bloc.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/pages/category_edit_screen.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:flutter_easy_order/widgets/helpers/ui_helper.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';

class CategoryListTile extends StatefulWidget {
  final Category category;

  CategoryListTile({@required this.category})
  : assert(category != null);

  @override
  _CategoryListTileState createState() => _CategoryListTileState();
}

class _CategoryListTileState extends State<CategoryListTile> {
  CategoryBloc _categoryBloc;

  final Logger logger = getLogger();

  @override
  void initState() {
    _categoryBloc = Provider.of<CategoryBloc>(context, listen: false);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, Category category) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () => _openCategoryEditScreen(category),
    );
  }

  _openCategoryEditScreen(Category category) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
          settings: RouteSettings(name: CategoryEditScreen.routeName),
          builder: (BuildContext context) => CategoryEditScreen(category)),
    )
        .then((_) {
      logger.d('Back to category list');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.category.id),
      direction: DismissDirection.endToStart,
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart) {
          _categoryBloc.delete(category: widget.category).then((bool success) {
            final Flushbar flushbar = (success)
                ? UiHelper.createSuccess(message: '${widget.category.name} successfully removed !', title: 'Success !')
                : UiHelper.createError(message: 'Failed to remove ${widget.category.name} !', title: 'Error !');
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
          onTap: () => _openCategoryEditScreen(widget.category),
          child: ListTile(
//            leading: CircleAvatar(
//              backgroundImage: widget._category.image == null
//                  ? AssetImage('assets/placeholder.jpg')
//                  : NetworkImage(widget._category.image),
//            ),
            title: Text(
              widget.category.name,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            subtitle: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    widget.category.description ?? '',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
                // https://proandroiddev.com/flutter-thursday-02-beautiful-list-ui-and-detail-page-a9245f5ceaf0
//                Expanded(
//                    flex: 1,
//                    child: Container(
//                      // tag: 'hero',
//                      child: LinearProgressIndicator(
//                          backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
//                          value: indicatorValue,
//                          valueColor: AlwaysStoppedAnimation(Colors.green)),
//                    )),
//                Expanded(
//                  flex: 4,
//                  child: Padding(
//                      padding: EdgeInsets.only(left: 10.0),
//                      child: Text(level,
//                          style: TextStyle(color: Colors.white))
//                  ),
//                ),
              ],
            ),
            trailing: _buildEditButton(context, widget.category),
          ),
        ),
      ),
    );
  }
}
