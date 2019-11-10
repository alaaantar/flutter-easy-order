import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/category_bloc.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/widgets/helpers/form_helper.dart';
import 'package:flutter_easy_order/widgets/helpers/validator.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class CategoryEditScreen extends StatefulWidget {
  static const String routeName = '/category_edit';

  final Category _currentCategory;

  CategoryEditScreen([this._currentCategory]);

  @override
  State<StatefulWidget> createState() {
    return _CategoryEditScreenState();
  }
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  CategoryBloc _categoryBloc;

  bool _isLoading = false;
  final Map<String, dynamic> _formData = {
    'name': null,
    'description': null,
    'image': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _descriptionTextController = TextEditingController();
  bool _isNameClearVisible = false;
  bool _isDescriptionClearVisible = false;

  @override
  void initState() {
    _nameTextController.addListener(_toggleNameClearVisible);
    _nameTextController.text = (widget._currentCategory == null) ? '' : widget._currentCategory.name;
    _descriptionTextController.addListener(_toggleDescriptionClearVisible);
    _descriptionTextController.text = (widget._currentCategory == null) ? '' : widget._currentCategory.description;
    _categoryBloc = Provider.of<CategoryBloc>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _descriptionTextController.dispose();
    super.dispose();
  }

  void _toggleNameClearVisible() {
    setState(() {
      _isNameClearVisible = _nameTextController.text.isEmpty ? false : true;
    });
  }

  void _toggleDescriptionClearVisible() {
    setState(() {
      _isDescriptionClearVisible = _descriptionTextController.text.isEmpty ? false : true;
    });
  }

  Widget _buildNameTextField(Category category) {
    return TextFormField(
      maxLength: 50,
      controller: _nameTextController,
      focusNode: _nameFocusNode,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (term) {
        FormHelper.changeFieldFocus(context, _nameFocusNode, _descriptionFocusNode);
      },
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.title,
            ),
          ),
          suffixIcon: !_isNameClearVisible
              ? Container(height: 0.0, width: 0.0)
              : IconButton(
                  onPressed: () {
                    _nameTextController.clear();
                  },
                  icon: Icon(
                    Icons.clear,
                  )),
          labelText: 'Category Name',
          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          filled: true,
          fillColor: Colors.white),
      validator: (String value) {
        return Validator.validateName(value);
      },
      onSaved: (String value) {
        _formData['name'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(Category category) {
    return TextFormField(
      maxLength: 100,
      maxLines: 5,
      controller: _descriptionTextController,
      focusNode: _descriptionFocusNode,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
//      decoration: InputDecoration(labelText: 'Product Description'),
//      initialValue: product == null ? '' : product.description,
      decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.description,
            ),
          ),
          suffixIcon: !_isDescriptionClearVisible
              ? Container(height: 0.0, width: 0.0)
              : IconButton(
                  onPressed: () {
                    _descriptionTextController.clear();
                  },
                  icon: Icon(
                    Icons.clear,
                  )),
//          hintText: 'Product Description',
          labelText: 'Category Description',
          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          filled: true,
          fillColor: Colors.white),
      validator: (String value) {
        return Validator.validateDescription(value);
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

//  Widget _buildImageField(Category category) {
//    return ImageFormField(
//      fileMaxWidth: 100.0,
//      previewImageHeight: 100.0,
//      initialValue: ImageInputAdapter(url: category?.image),
//      validator: (ImageInputAdapter value) {
//        return Validator.validateImage(value);
//      },
//      onSaved: (ImageInputAdapter value) {
//        _formData['image'] = value.file;
//      },
//    );
//  }

  Widget _buildSubmitButton() {
    return FlatButton.icon(
        label: Text('SAVE'),
        textColor: Colors.white,
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        disabledTextColor: Colors.white,
        onPressed: !_isLoading ? _submitForm : null);
  }

  Widget _buildPageContent(BuildContext context, Category category) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                _buildNameTextField(category),
                SizedBox(
                  height: 15.0,
                ),
                _buildDescriptionTextField(category),
//                SizedBox(
//                  height: 15.0,
//                ),
//                _buildImageField(category),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    setState(() => _isLoading = true);
//    await Future.delayed(Duration(seconds: 5));

    if (!_formKey.currentState.validate()) {
      setState(() => _isLoading = false);
      return;
    }
    _formKey.currentState.save();

    if (widget._currentCategory == null) {
      _createCategory();
    } else {
      _updateCategory();
    }
  }

  void _createCategory() {
    Category categoryToCreate = Category(
      name: _formData['name'],
      description: _formData['description'],
    );

    _categoryBloc
        .create(
      category: categoryToCreate,
      image: _formData['image'],
    )
        .then((bool success) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        _showErrorDialog();
      }
    });
  }

  void _updateCategory() {
    final Category categoryToUpdate = Category.clone(widget._currentCategory);
    categoryToUpdate.name = _formData['name'];
    categoryToUpdate.description = _formData['description'];

    _categoryBloc
        .update(
      categoryId: widget._currentCategory.id,
      category: categoryToUpdate,
      image: _formData['image'],
    )
        .then((bool success) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        _showErrorDialog();
      }
    });
  }

  _showErrorDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Something went wrong'),
            content: Text('Please try again!'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final Widget pageContent = _buildPageContent(context, widget._currentCategory);
    final String title = widget._currentCategory == null ? 'Create Category' : 'Edit Category';

    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator: AdaptiveProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          actions: <Widget>[
            _buildSubmitButton(),
          ],
        ),
        body: pageContent,
//      floatingActionButton: _buildSubmitButton(),
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
