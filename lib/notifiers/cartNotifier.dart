import 'package:get/get.dart';
import '../models/food.dart';

class CartNotifier extends GetxController {
  final cartProducts = [].obs;

  CartNotifier();

//ADD ITEMS TO CART--
  addToCart(FoodModel product) {
    cartProducts.add(product);
  }

//REMOVE ITEMS TO CART--
  removeFromCart(FoodModel product) {
    cartProducts.removeWhere(((item) => item.id == product.id));
  }
}