// To parse this JSON data, do
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<FoodModel> welcomeFromJson(String str) =>
    List<FoodModel>.from(json.decode(str).map((x) => FoodModel.fromJson(x)));

String welcomeToJson(List<FoodModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FoodModel {
  FoodModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
    required this.quantity,
  });

  String id;
  String name;
  String category;
  double price;
  String image;
  String description;
  int quantity;

  factory FoodModel.fromJson(Map<String, dynamic> json) => FoodModel(
      id: json["id"],
      name: json["name"],
      category: json["category"],
      price: json["price"].toDouble(),
      image: json["image"],
      description: json["description"],
      quantity: json['quantity']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category,
        "price": price,
        "image": image,
        "description": description,
        "quantity": quantity
      };
}
