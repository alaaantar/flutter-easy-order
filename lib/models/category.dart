import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class Category {
  String id;
  String uuid;
  String name;
  String description;
  String imageUrl;
  String imagePath;
  String userEmail;
  String userId;

  Category(
      {this.id,
      this.uuid,
      @required this.name,
      this.description,
      this.imageUrl,
      this.userEmail,
      this.userId,
      this.imagePath})
      : assert(name != null);

  Map<String, dynamic> toJson() => {
        'uuid': this.uuid,
        'name': this.name,
        'description': this.description,
        'imagePath': this.imagePath,
        'imageUrl': this.imageUrl,
        'userEmail': this.userEmail,
        'userId': this.userId,
      };

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        uuid = json['uuid'],
        name = json['name'],
        description = json['description'],
        imagePath = json['imagePath'],
        imageUrl = json['imageUrl'],
        userEmail = json['userEmail'],
        userId = json['userId'];

  factory Category.fromSnapshot(DocumentSnapshot snapshot) {

    if (snapshot == null) {
      return null;
    }

    Map<String, dynamic> json = snapshot.data;
    json['id'] = snapshot.documentID;
    return Category.fromJson(json);
  }

  factory Category.clone(Category category) {
    return category ?? Category(
        id: category.id,
        uuid: category.uuid,
        name: category.name,
        description: category.description,
        imagePath: category.imagePath,
        imageUrl: category.imageUrl,
        userEmail: category.userEmail,
        userId: category.userId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && uuid == other.uuid && name == other.name;

  @override
  int get hashCode => uuid.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Category{id: $id, uuid: $uuid, name: $name, description: $description, imageUrl: $imageUrl, imagePath: $imagePath, '
        'userEmail: $userEmail, userId: $userId}';
  }
}
