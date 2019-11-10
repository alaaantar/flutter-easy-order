import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/category_bloc.dart';
import 'package:flutter_easy_order/bloc/product_bloc.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/models/product.dart';
import 'package:flutter_easy_order/pages/category_edit_screen.dart';
import 'package:flutter_easy_order/widgets/form_inputs/drop_down_form_field.dart';
import 'package:flutter_easy_order/widgets/form_inputs/image_form_field.dart';
import 'package:flutter_easy_order/widgets/form_inputs/image_input_adapter.dart';
import 'package:flutter_easy_order/widgets/helpers/form_helper.dart';
import 'package:flutter_easy_order/widgets/helpers/validator.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class ProductEditScreen extends StatefulWidget {
  static const String routeName = '/product_edit';

  final Product _currentProduct;

  ProductEditScreen([this._currentProduct]);

  @override
  State<StatefulWidget> createState() {
    return _ProductEditScreenState();
  }
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  ProductBloc _productBloc;
  CategoryBloc _categoryBloc;
  Stream<List<Category>> _categories$;

  bool _isLoading = false;
  final Map<String, dynamic> _formData = {
    'name': null,
    'category': null,
    'description': null,
    'price': null,
    'image': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _categoryFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _categoryTextController = TextEditingController();
  final TextEditingController _descriptionTextController = TextEditingController();
  final TextEditingController _priceTextController = TextEditingController();
  bool _isNameClearVisible = false;
  bool _isDescriptionClearVisible = false;
  bool _isPriceClearVisible = false;

  @override
  void initState() {
    _nameTextController.addListener(_toggleNameClearVisible);
    _nameTextController.text = (widget._currentProduct == null) ? '' : widget._currentProduct.name;
    _descriptionTextController.addListener(_toggleDescriptionClearVisible);
    _descriptionTextController.text = (widget._currentProduct == null) ? '' : widget._currentProduct.description;
    _priceTextController.addListener(_togglePriceClearVisible);
    _priceTextController.text = (widget._currentProduct == null) ? '' : widget._currentProduct.price.toString();

    _productBloc = Provider.of<ProductBloc>(context, listen: false);
    _categoryBloc = Provider.of<CategoryBloc>(context, listen: false);
    _categories$ = _categoryBloc.categories$;
    super.initState();
  }

  @override
  void dispose() {
//    _productBloc.dispose();
//    _categoryBloc.dispose();
    _nameTextController.dispose();
    _categoryTextController.dispose();
    _descriptionTextController.dispose();
    _priceTextController.dispose();
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

  void _togglePriceClearVisible() {
    setState(() {
      _isPriceClearVisible = _priceTextController.text.isEmpty ? false : true;
    });
  }

  Widget _buildNameTextField(Product product) {
    return TextFormField(
      maxLength: 50,
      controller: _nameTextController,
      focusNode: _nameFocusNode,
//      decoration: InputDecoration(labelText: 'Product Name'),
//      initialValue: product == null ? '' : product.name,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (term) {
        FormHelper.changeFieldFocus(context, _nameFocusNode, _categoryFocusNode);
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
//          hintText: 'Product Name',
          labelText: 'Product Name',
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

  Widget _buildCategoriesDropDown(Product product, List<Category> categories) {
    final Widget dropDown = (categories == null || categories.isEmpty)
        ? Center(
            child: Text('Please add a category first !'),
          )
        : DropdownFormField<Category>(
            items: categories.map((Category category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            validator: (Category value) {
              return Validator.validateCategory(value);
            },
            onSaved: (Category value) {
              _formData['category'] = value;
            },
            initialValue: product?.category ?? null,
            icon: Icon(Icons.category),
            labelText: 'Category',
          );

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Expanded(
        flex: 5,
        child: dropDown,
      ),
      Expanded(
        flex: 1,
        child: IconButton(
          icon: Icon(Icons.add_circle),
          color: Theme.of(context).accentColor,
          splashColor: Theme.of(context).primaryColor,
          onPressed: _openEditCategoryScreen,
        ),
      ),
    ]);
  }

  Widget _buildDescriptionTextField(Product product) {
    return TextFormField(
      maxLength: 100,
      maxLines: 5,
      controller: _descriptionTextController,
      focusNode: _descriptionFocusNode,
      textInputAction: TextInputAction.newline,
//      textInputAction: TextInputAction.next,
      onFieldSubmitted: (term) {
        FormHelper.changeFieldFocus(context, _descriptionFocusNode, _priceFocusNode);
      },
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
          labelText: 'Product Description',
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

  Widget _buildPriceTextField(Product product) {
    return TextFormField(
      maxLength: 10,
      controller: _priceTextController,
      focusNode: _priceFocusNode,
      keyboardType: TextInputType.number,
//      decoration: InputDecoration(labelText: 'Product Price'),
//      initialValue: product == null ? '' : product.price.toString(),
      decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.attach_money,
            ),
          ),
          suffixIcon: !_isPriceClearVisible
              ? Container(height: 0.0, width: 0.0)
              : IconButton(
                  onPressed: () {
                    _priceTextController.clear();
                  },
                  icon: Icon(
                    Icons.clear,
                  )),
//          hintText: 'Product Price',
          labelText: 'Product Price',
          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          filled: true,
          fillColor: Colors.white),
      validator: (String value) {
        return Validator.validatePrice(value);
      },
      onSaved: (String value) {
        _formData['price'] = double.parse(value.replaceFirst(RegExp(r','), '.'));
      },
    );
  }

  Widget _buildImageField(Product product) {
    return ImageFormField(
      initialValue: ImageInputAdapter(url: product?.imageUrl),
      validator: (ImageInputAdapter value) {
        return Validator.validateImage(value);
      },
      onSaved: (ImageInputAdapter value) {
        _formData['image'] = value.file;
      },
    );
  }

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

  Widget _buildPageContent(BuildContext context, Product product, List<Category> categories) {
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
                _buildNameTextField(product),
                SizedBox(
                  height: 15.0,
                ),
                _buildCategoriesDropDown(product, categories),
                SizedBox(
                  height: 15.0,
                ),
                _buildDescriptionTextField(product),
                SizedBox(
                  height: 15.0,
                ),
                _buildPriceTextField(product),
                SizedBox(
                  height: 15.0,
                ),
//                ImageInput(_setImage, product),
                _buildImageField(product),
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

    if (widget._currentProduct == null) {
      _createProduct();
    } else {
      _updateProduct();
    }
  }

  void _createProduct() {
    Product productToCreate = Product(
        name: _formData['name'],
        category: _formData['category'],
        description: _formData['description'],
        price: _formData['price']);

    _productBloc
        .create(
      product: productToCreate,
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

  void _updateProduct() {
    final Product productToUpdate = Product.clone(widget._currentProduct);
    productToUpdate.name = _formData['name'];
    productToUpdate.category = _formData['category'];
    productToUpdate.description = _formData['description'];
    productToUpdate.price = _formData['price'];

    _productBloc
        .update(
      productId: widget._currentProduct.id,
      product: productToUpdate,
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

  @override
  Widget build(BuildContext context) {
    final String title = widget._currentProduct == null ? 'Create Product' : 'Edit Product';

    return StreamBuilder(
        stream: _categories$,
        builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
          final bool categoriesExist = snapshot.hasData && snapshot.data.isNotEmpty;
          final bool canEdit = widget._currentProduct != null || categoriesExist;
          final Widget pageContent = _buildPageContent(context, widget._currentProduct, snapshot.data);

          return ModalProgressHUD(
            inAsyncCall: _isLoading,
            progressIndicator: AdaptiveProgressIndicator(),
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
                actions: <Widget>[
                  categoriesExist
                      ? _buildSubmitButton()
                      : Container(
                          height: 0.0,
                          width: 0.0,
                        ),
                ],
              ),
              body: canEdit ? pageContent : Center(child: Text('Please add a category first !')),
              floatingActionButton: canEdit
                  ? Container(
                      height: 0.0,
                      width: 0.0,
                    )
                  : _buildAddCategoryButton(),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            ),
          );
        });
  }
}
