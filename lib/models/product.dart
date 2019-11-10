import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:meta/meta.dart';

class Product {
  // extends Equatable {
  String id;
  String uuid;
  String name;
  Category category;
  String description;
  double price;
  String imageUrl;
  String imagePath;
  String userEmail;
  String userId;

  Product(
      {this.id,
      this.uuid,
      @required this.name,
      @required this.category,
      @required this.description,
      @required this.price,
      this.imageUrl,
      this.userEmail,
      this.userId,
      this.imagePath})
      : assert(name != null && category != null && description != null && price != null);

//      : super([id, title, category, description, price, image, userEmail, userId, imagePath]);

  Map<String, dynamic> toJson() => {
        'uuid': this.uuid,
        'name': this.name,
        'description': this.description,
        'category': this.category.toJson(),
        'price': this.price,
        'imagePath': this.imagePath,
        'imageUrl': this.imageUrl,
        'userEmail': this.userEmail,
        'userId': this.userId,
      };

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        uuid = json['uuid'],
        name = json['name'],
        description = json['description'],
        category = json['category'] == null ? null : Category.fromJson(Map<String, dynamic>.from(json['category'])),
        price = json['price'],
        imagePath = json['imagePath'],
        imageUrl = json['imageUrl'],
        userEmail = json['userEmail'],
        userId = json['userId'];

  factory Product.fromSnapshot(DocumentSnapshot snapshot) {

    if (snapshot == null) {
      return null;
    }

    Map<String, dynamic> json = snapshot.data;
    json['id'] = snapshot.documentID;
    final double price = double.tryParse(json['price'].toString());
    json['price'] = price;
    return Product.fromJson(json);
  }

  factory Product.clone(Product product) {
    return product ?? Product(
        id: product.id,
        uuid: product.uuid,
        name: product.name,
        description: product.description,
        category: product.category,
        price: product.price,
        imagePath: product.imagePath,
        imageUrl: product.imageUrl,
        userEmail: product.userEmail,
        userId: product.userId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && runtimeType == other.runtimeType && uuid == other.uuid;

//          && name == other.name;

  @override
  int get hashCode => uuid.hashCode; // ^ name.hashCode;

  @override
  String toString() {
    return 'Product{id: $id, uuid: $uuid, name: $name, category: $category, description: $description, price: $price, image: $imageUrl, imagePath: $imagePath, userEmail: $userEmail, '
        'userId: $userId}';
  }
}
