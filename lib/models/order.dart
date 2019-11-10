import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easy_order/models/cart.dart';
import 'package:meta/meta.dart';

class Order {
  String id;
  String uuid;
  String number;
  String clientId;
  DateTime date;
  Cart cart;
  bool completed;
  String userEmail;
  String userId;

  Order(
      {this.id,
      this.uuid,
      this.number,
      @required this.clientId,
      @required this.date,
      this.cart,
      this.completed,
      this.userEmail,
      this.userId})
      : assert(clientId != null && date != null);

  Map<String, dynamic> toJson() => {
        'uuid': this.uuid,
        'number': this.number,
        'clientId': this.clientId,
        'date': this.date,
        'cart': this.cart.toJson(),
        'completed': this.completed,
        'userId': this.userId,
        'userEmail': this.userEmail,
      };

  Order.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        uuid = json['uuid'],
        number = json['number'].toString(),
        clientId = json['clientId'],
        date = json['date'],
        cart = Cart.fromJson(List.from(json['cart'])),
        completed = json['completed'],
        userId = json['userId'],
        userEmail = json['userEmail'];

  factory Order.fromSnapshot(DocumentSnapshot snapshot) {

    if (snapshot == null) {
      return null;
    }

    Map<String, dynamic> json = snapshot?.data;
    json['id'] = snapshot?.documentID;

    final Timestamp timestamp = snapshot?.data['date'] as Timestamp;
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp?.millisecondsSinceEpoch, isUtc: false);
    json['date'] = date;

    final List<dynamic> cartFromSnapshot = snapshot?.data['cart'] == null ? [] : List.from(snapshot?.data['cart']);
    json['cart'] = cartFromSnapshot;

    return Order.fromJson(json);
  }

  factory Order.clone(Order order) {
    return order ?? Order(
        id: order.id,
        uuid: order.uuid,
        number: order.number,
        clientId: order.clientId,
        date: order.date,
        cart: order.cart,
        completed: order.completed,
        userId: order.userId,
        userEmail: order.userEmail
    );
  }

  @override
  String toString() {
    return 'Order{id: $id, uuid: $uuid, number: $number, clientId: $clientId, date: $date, cart: $cart, completed: $completed, userId: $userId, userEmail: $userEmail}';
  }
}
