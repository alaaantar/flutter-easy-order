import 'package:flutter_easy_order/models/cart.dart';
import 'package:flutter_easy_order/models/cart_item.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/models/order.dart';
import 'package:flutter_easy_order/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromJson', () {
    test('should return correct object from JSON map', () async {
      var now = DateTime.now();
      Map<String, dynamic> json = {
        'id': 'orderId',
        'uuid': 'uuid',
        'userId': 'mockUserId',
        'userEmail': 'mockUserEmail',
        'clientId': 'mockClientId',
        'date': now,
        'completed': true,
        'number': 'mockNumber',
        'cart': [
          {
            'product': {
              'id': 'product1',
              'uuid': 'productUuid1',
              'name': 'productName1',
              'category': {
                'id': 'cat1',
                'uuid': 'uuid1',
                'name': 'catName1',
                'description': 'catDesc1',
                'imageUrl': 'url1',
                'imagePath': 'path1',
                'userId': 'mockUserId',
                'userEmail': 'mockUserEmail',
              },
              'description': 'productDesc1',
              'price': 11.59,
              'imageUrl': 'productUrl1',
              'imagePath': 'productPath1',
              'userId': 'mockUserId',
              'userEmail': 'mockUserEmail',
            },
            'quantity': 3,
          },
          {
            'product': {
              'id': 'product2',
              'uuid': 'productUuid2',
              'name': 'productName2',
              'category': {
                'id': 'cat2',
                'uuid': 'uuid2',
                'name': 'catName2',
                'description': 'catDesc2',
                'imageUrl': 'url2',
                'imagePath': 'path2',
                'userId': 'mockUserId',
                'userEmail': 'mockUserEmail',
              },
              'description': 'productDesc2',
              'price': 55.99,
              'imageUrl': 'productUrl2',
              'imagePath': 'productPath2',
              'userId': 'mockUserId',
              'userEmail': 'mockUserEmail',
            },
            'quantity': 5,
          },
          {
            'product': {
              'id': 'product3',
              'uuid': 'productUuid3',
              'name': 'productName3',
              'category': {
                'id': 'cat3',
                'uuid': 'uuid3',
                'name': 'catName3',
                'description': 'catDesc3',
                'imageUrl': 'url3',
                'imagePath': 'path3',
                'userId': 'mockUserId',
                'userEmail': 'mockUserEmail',
              },
              'description': 'productDesc3',
              'price': 99.00,
              'imageUrl': 'productUrl3',
              'imagePath': 'productPath3',
              'userId': 'mockUserId',
              'userEmail': 'mockUserEmail',
            },
            'quantity': 26,
          },
        ],
      };

      var cat1 = Category(
        id: 'cat1',
        uuid: 'uuid1',
        name: 'catName1',
        description: 'catDesc1',
        imageUrl: 'url1',
        imagePath: 'path1',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
      );
      var cat2 = Category(
        id: 'cat2',
        uuid: 'uuid2',
        name: 'catName2',
        description: 'catDesc2',
        imageUrl: 'url2',
        imagePath: 'path2',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
      );
      var cat3 = Category(
        id: 'cat3',
        uuid: 'uuid3',
        name: 'catName3',
        description: 'catDesc3',
        imageUrl: 'url3',
        imagePath: 'path3',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
      );
      CartItem cartItem1 = CartItem(
          product: Product(
            id: 'product1',
            uuid: 'productUuid1',
            name: 'productName1',
            category: cat1,
            description: 'productDesc1',
            price: 11.59,
            imageUrl: 'productUrl1',
            imagePath: 'productPath1',
            userId: 'mockUserId',
            userEmail: 'mockUserEmail',
          ),
          quantity: 3);
      CartItem cartItem2 = CartItem(
          product: Product(
            id: 'product2',
            uuid: 'productUuid2',
            name: 'productName2',
            category: cat2,
            description: 'productDesc2',
            price: 55.99,
            imageUrl: 'productUrl2',
            imagePath: 'productPath2',
            userId: 'mockUserId',
            userEmail: 'mockUserEmail',
          ),
          quantity: 5);
      CartItem cartItem3 = CartItem(
          product: Product(
            id: 'product3',
            uuid: 'productUuid3',
            name: 'productName3',
            category: cat3,
            description: 'productDesc3',
            price: 99.00,
            imageUrl: 'productUrl3',
            imagePath: 'productPath3',
            userId: 'mockUserId',
            userEmail: 'mockUserEmail',
          ),
          quantity: 26);
      var cartItems = <CartItem>[cartItem1, cartItem2, cartItem3];
      Cart cart = Cart(cartItems: cartItems);

      Order expectedOrder = Order(
        id: 'orderId',
        uuid: 'uuid',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
        clientId: 'mockClientId',
        date: now,
        completed: true,
        number: 'mockNumber',
        cart: cart,
      );

      Order result = Order.fromJson(json);

      expect(result.toString(), expectedOrder.toString());
    });
  });

  group('toJson', () {
    test('should return correct JSON map from object', () async {
      var now = DateTime.now();
      var cat1 = Category(
        id: 'cat1',
        uuid: 'uuid1',
        name: 'catName1',
        description: 'catDesc1',
        imageUrl: 'url1',
        imagePath: 'path1',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
      );
      var cat2 = Category(
        id: 'cat2',
        uuid: 'uuid2',
        name: 'catName2',
        description: 'catDesc2',
        imageUrl: 'url2',
        imagePath: 'path2',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
      );
      var cat3 = Category(
        id: 'cat3',
        uuid: 'uuid3',
        name: 'catName3',
        description: 'catDesc3',
        imageUrl: 'url3',
        imagePath: 'path3',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
      );
      CartItem cartItem1 = CartItem(
          product: Product(
            id: 'product1',
            uuid: 'productUuid1',
            name: 'productName1',
            category: cat1,
            description: 'productDesc1',
            price: 11.59,
            imageUrl: 'productUrl1',
            imagePath: 'productPath1',
            userId: 'mockUserId',
            userEmail: 'mockUserEmail',
          ),
          quantity: 3);
      CartItem cartItem2 = CartItem(
          product: Product(
            id: 'product2',
            uuid: 'productUuid2',
            name: 'productName2',
            category: cat2,
            description: 'productDesc2',
            price: 55.99,
            imageUrl: 'productUrl2',
            imagePath: 'productPath2',
            userId: 'mockUserId',
            userEmail: 'mockUserEmail',
          ),
          quantity: 5);
      CartItem cartItem3 = CartItem(
          product: Product(
            id: 'product3',
            uuid: 'productUuid3',
            name: 'productName3',
            category: cat3,
            description: 'productDesc3',
            price: 99.00,
            imageUrl: 'productUrl3',
            imagePath: 'productPath3',
            userId: 'mockUserId',
            userEmail: 'mockUserEmail',
          ),
          quantity: 26);
      var cartItems = <CartItem>[cartItem1, cartItem2, cartItem3];
      Cart cart = Cart(cartItems: cartItems);

      Order order = Order(
        id: 'orderId',
        uuid: 'uuid',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
        clientId: 'mockClientId',
        date: now,
        completed: true,
        number: 'mockNumber',
        cart: cart,
      );

      Map<String, dynamic> expectedJson = {
//        'id': 'orderId',
        'uuid': 'uuid',
        'userId': 'mockUserId',
        'userEmail': 'mockUserEmail',
        'clientId': 'mockClientId',
        'date': now,
        'completed': true,
        'number': 'mockNumber',
        'cart': [
          {
            'product': {
//          'id': 'product1',
              'uuid': 'productUuid1',
              'name': 'productName1',
              'category': {
//            'id': 'cat1',
                'uuid': 'uuid1',
                'name': 'catName1',
                'description': 'catDesc1',
                'imageUrl': 'url1',
                'imagePath': 'path1',
                'userId': 'mockUserId',
                'userEmail': 'mockUserEmail',
              },
              'description': 'productDesc1',
              'price': 11.59,
              'imageUrl': 'productUrl1',
              'imagePath': 'productPath1',
              'userId': 'mockUserId',
              'userEmail': 'mockUserEmail',
            },
            'quantity': 3,
          },
          {
            'product': {
//          'id': 'product2',
              'uuid': 'productUuid2',
              'name': 'productName2',
              'category': {
//            'id': 'cat2',
                'uuid': 'uuid2',
                'name': 'catName2',
                'description': 'catDesc2',
                'imageUrl': 'url2',
                'imagePath': 'path2',
                'userId': 'mockUserId',
                'userEmail': 'mockUserEmail',
              },
              'description': 'productDesc2',
              'price': 55.99,
              'imageUrl': 'productUrl2',
              'imagePath': 'productPath2',
              'userId': 'mockUserId',
              'userEmail': 'mockUserEmail',
            },
            'quantity': 5,
          },
          {
            'product': {
//          'id': 'product3',
              'uuid': 'productUuid3',
              'name': 'productName3',
              'category': {
//            'id': 'cat3',
                'uuid': 'uuid3',
                'name': 'catName3',
                'description': 'catDesc3',
                'imageUrl': 'url3',
                'imagePath': 'path3',
                'userId': 'mockUserId',
                'userEmail': 'mockUserEmail',
              },
              'description': 'productDesc3',
              'price': 99.00,
              'imageUrl': 'productUrl3',
              'imagePath': 'productPath3',
              'userId': 'mockUserId',
              'userEmail': 'mockUserEmail',
            },
            'quantity': 26,
          },
        ],
      };

      Map<String, dynamic> result = order.toJson();

      expect(result, expectedJson);
    });
  });
}
