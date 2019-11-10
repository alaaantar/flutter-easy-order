import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/cart_bloc.dart';
import 'package:flutter_easy_order/bloc/order_bloc.dart';
import 'package:flutter_easy_order/bloc/order_pagination_bloc.dart';
import 'package:flutter_easy_order/models/cart.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:flutter_easy_order/models/order.dart';
import 'package:flutter_easy_order/models/order_filter.dart';
import 'package:flutter_easy_order/pages/cart_screen.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:flutter_easy_order/widgets/helpers/validator.dart';
import 'package:flutter_easy_order/widgets/orders/order_items_list_tile.dart';
import 'package:flutter_easy_order/widgets/orders/price_total_tag.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:flutter_easy_order/widgets/ui_elements/footer_layout.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class OrderEditScreen extends StatefulWidget {
  static const String routeName = '/order_edit';

  final Order _currentOrder;

  OrderEditScreen([this._currentOrder]);

  @override
  State<StatefulWidget> createState() {
    return _OrderEditScreenState();
  }
}

class _OrderEditScreenState extends State<OrderEditScreen> {

  OrderPaginationBloc _orderPaginationBloc;
  OrderBloc _orderBloc;
  CartBloc _cartBloc;
  Stream<Cart> _cart$;

  final Logger logger = getLogger();

  // Cart items to save
  List<CartItem> _cartItems;

  bool _isLoading = false;
  final Map<String, dynamic> _formData = {
    'clientId': null,
    'date': null,
  };
  bool _isOrderCompleted = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _clientIdFocusNode = FocusNode();
  final _dateFocusNode = FocusNode();

  final TextEditingController _clientIdTextController = TextEditingController();
  bool _isClientIdClearVisible = false;

  @override
  initState() {
    _clientIdTextController.addListener(_toggleClientIdClearVisible);
    _clientIdTextController.text = (widget._currentOrder == null) ? '' : widget._currentOrder.clientId;
    _isOrderCompleted = widget._currentOrder?.completed ?? false;

    _orderBloc = Provider.of<OrderBloc>(context, listen: false);
    _orderPaginationBloc = Provider.of<OrderPaginationBloc>(context, listen: false);
    _cartBloc = Provider.of<CartBloc>(context, listen: false);
    _cart$ = _cartBloc.cart$;
    super.initState();
  }

  @override
  void dispose() {
    _clientIdTextController.dispose();
    super.dispose();
  }

  void _toggleClientIdClearVisible() {
    setState(() {
      _isClientIdClearVisible = _clientIdTextController.text.isEmpty || _isOrderCompleted ? false : true;
    });
  }

  Widget _buildClientIdTextField(Order order) {
    return TextFormField(
      maxLength: 50,
      enabled: !_isOrderCompleted,
//      enableInteractiveSelection: ,
      focusNode: _clientIdFocusNode,
//      initialValue: order == null ? '' : order.clientId,
      controller: _clientIdTextController,
      textInputAction: TextInputAction.done,
//      onFieldSubmitted: (term) {
//        FormHelper.changeFieldFocus(context, _clientIdFocusNode, _dateFocusNode);
//      },
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.perm_identity,
            ),
          ),
          suffixIcon: !_isClientIdClearVisible
              ? Container(height: 0.0, width: 0.0)
              : IconButton(
              onPressed: () {
                _clientIdTextController.clear();
              },
              icon: Icon(
                Icons.clear,
              )),
//          hintText: 'Client ID',
          labelText: 'Client ID',
          contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          filled: true,
          fillColor: Colors.white),
      validator: (String value) {
        return Validator.validateClientId(value);
      },
      onSaved: (String value) {
        _formData['clientId'] = value;
      },
    );
  }

  Widget _buildDateTimeField(Order order) {
    return DateTimeField(
      enabled: !_isOrderCompleted,
      focusNode: _dateFocusNode,
//      dateOnly: true,
      format: DateFormat("EEEE, MMMM d, yyyy h:mma"),
      initialValue: order == null ? DateTime.now() : order.date,
      resetIcon: Icon(Icons.clear),
      onShowPicker: _onShowPicker,
      decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.calendar_today,
            ),
          ),
//          hintText: 'Date',
          labelText: 'Date',
          contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          filled: true,
          fillColor: Colors.white),
      validator: (DateTime value) {
        return Validator.validateOrderDate(value);
      },
      onSaved: (DateTime value) {
        _formData['date'] = value;
      },
    );
  }

  Future<DateTime> _onShowPicker(context, currentValue) async {
    final date = await showDatePicker(
        context: context,
        firstDate: DateTime(2010),
        lastDate: DateTime(2100),
        initialDate: currentValue ?? DateTime.now()
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime:
        TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
      );
      return DateTimeField.combine(date, time);
    } else {
      return currentValue;
    }
  }

  Widget _buildCartItemsList(BuildContext context) {
//    return StreamBuilder<List<CartItem>>(
//      stream: _items$,
    return StreamBuilder<Cart>(
      stream: _cart$,
      builder: (BuildContext context, snapshot) {
        // Reset cart items
        _cartItems = [];

        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return _buildLoadingIndicator(context);
        }

        if (snapshot.data.itemCount <= 0) {
          return Center(child: Text('No item selected'));
        }

        // Set the cart items list
        final List<CartItem> items = snapshot.data.items;
        _cartItems = items;

        return ListView.separated(
          scrollDirection: Axis.vertical,
//          padding: EdgeInsets.all(2.0),
          itemBuilder: (context, index) {
            final CartItem item = items[index];
            return OrderItemsListTile(item: item);
          },
          itemCount: items.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          // https://medium.com/flutterpub/flutter-listview-gridview-inside-scrollview-68b722ae89d4
          // https://stackoverflow.com/questions/45270900/child-listview-within-listview-parent
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return _isOrderCompleted
        ? Container(
      height: 0.0,
      width: 0.0,
    )
        : FlatButton.icon(
        label: Text('SAVE'),
        textColor: Colors.white,
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        disabledTextColor: Colors.white,
        onPressed: !_isLoading ? _submitForm : null);
  }

  Widget _buildPageContent(BuildContext context, Order order) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: FooterLayout(
          body: _buildBody(order),
          footer: _buildPriceTotalTag(),
        ));
  }

  Widget _buildBody(Order order) {
    final double deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
//    final double deviceHeight = MediaQuery.of(context).size.height;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return Container(
      margin: EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  _buildClientIdTextField(order),
                  SizedBox(
                    height: 15.0,
                  ),
                  _buildDateTimeField(order),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            _buildCartItemsList(context),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    setState(() => _isLoading = true);
//    await Future.delayed(Duration(seconds: 5));

    final Cart cart = Cart(cartItems: _cartItems);

    if (!_formKey.currentState.validate()) {
      setState(() => _isLoading = false);
      return;
    }
    _formKey.currentState.save();

    if (widget._currentOrder == null) {
      _createOrder(cart);
    } else {
      _updateOrder(cart);
    }
  }

  void _createOrder(Cart cart) {
    Order orderToCreate = Order(clientId: _formData['clientId'], date: _formData['date'], cart: cart);

    _orderBloc.create(order: orderToCreate).then((bool success) {
      setState(() => _isLoading = false);
      if (success) {
        final currentFilter = Provider.of<OrderFilter>(context);
        _refreshOrders(completed: currentFilter.completed);
        Navigator.pop(context);
      } else {
        _showErrorDialog();
      }
    });
  }

  void _updateOrder(Cart cart) {
    final Order orderToUpdate = Order.clone(widget._currentOrder);
    orderToUpdate.clientId = _formData['clientId'];
    orderToUpdate.date = _formData['date'];
//    orderToUpdate.completed = _isCompleted;
    orderToUpdate.cart = cart;

    _orderBloc.update(orderId: widget._currentOrder.id, order: orderToUpdate).then((bool success) {
      setState(() => _isLoading = false);
      if (success) {
        _refreshOrders(completed: widget._currentOrder.completed);
        Navigator.pop(context);
      } else {
        _showErrorDialog();
      }
    });
  }

  void _completeOrReopenOrder(bool isCompleted) {
    setState(() => _isLoading = true);
    final Order orderToUpdate = Order.clone(widget._currentOrder);
    orderToUpdate.completed = isCompleted;

    _orderBloc.update(orderId: widget._currentOrder.id, order: orderToUpdate).then((bool success) {
      setState(() => _isLoading = false);
      if (success) {
        _refreshOrders(completed: !isCompleted);
        Navigator.pop(context);
      } else {
        _showErrorDialog();
      }
    });
  }

  _refreshOrders({bool completed}) {
    final orderFilter = OrderFilter(completed: completed);
    _orderPaginationBloc.refresh(filter: orderFilter);
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

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: AdaptiveProgressIndicator(),
    );
  }

  Widget _buildPriceTotalTag() {
    return Container(
        child: StreamBuilder<Cart>(
            stream: _cart$,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }

              final double price = snapshot.hasData ? snapshot.data.price : 0;
              return PriceTotalTag(price: price);
            }));
  }

  Widget _buildAddOrEditProductButton(List<CartItem> cartItems) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: RaisedButton.icon(
          elevation: 4.0,
          label: (cartItems == null || cartItems.length <= 0) ? Text('ADD') : Text('EDIT'),
          icon: Icon(Icons.add_shopping_cart),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
//            padding: EdgeInsets.all(12),
          color: Theme
              .of(context)
              .accentColor,
          textColor: Colors.white,
          onPressed: _addProduct,
        ),
      ),
    );
  }

  _addProduct() {
    final Widget cartScreen = Provider<CartBloc>(
      builder: (BuildContext context) => _cartBloc,
//      dispose: (BuildContext context, productBloc) => productBloc.dispose(),
      child: CartScreen(),
    );

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        settings: RouteSettings(name: CartScreen.routeName),
        builder: (BuildContext context) {
          return cartScreen;
        },
      ),
    )
        .then((value) {
      logger.d('Back to order list screen: $value');
//      _cartStream = value as Stream<List<CartItem>>;
    });
  }

  Widget _buildCompleteOrReopenButton() {
    final String label = _isOrderCompleted ? 'REOPEN' : 'COMPLETE';
    final Icon icon = _isOrderCompleted ? Icon(Icons.open_in_new) : Icon(Icons.check);
    final Color color = _isOrderCompleted ? Colors.red : Colors.green;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: RaisedButton.icon(
          elevation: 4.0,
          label: Text(label),
          icon: icon,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
//            padding: EdgeInsets.all(12),
          color: color,
          textColor: Colors.white,
          onPressed: () => _completeOrReopenOrder(!_isOrderCompleted),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Order currentOrder = widget._currentOrder;
    final Widget pageContent = _buildPageContent(context, currentOrder);
    final String title = (currentOrder == null) ? 'Create Order' : 'Edit Order';

    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator: AdaptiveProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          elevation: Theme
              .of(context)
              .platform == TargetPlatform.iOS ? 0.0 : 4.0,
          actions: <Widget>[
            _buildSubmitButton(),
          ],
        ),
        body: pageContent,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          elevation: 1.0,
          notchMargin: 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // center
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (!_isOrderCompleted) _buildAddOrEditProductButton(widget._currentOrder?.cart?.items),
              if (widget._currentOrder != null) _buildCompleteOrReopenButton(),
            ],
          ),
        ),
      ),
    );
  }
}
