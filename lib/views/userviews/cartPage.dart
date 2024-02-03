import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/utils.dart';
import 'package:online_food_order_app/apis/razorpay/razorpayInegrations.dart';
import 'package:online_food_order_app/models/food.dart';
import 'package:online_food_order_app/notifiers/cartNotifier.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartNotifier cartcontroller = Get.put(CartNotifier());
  final RazorPayIntegration _integration = RazorPayIntegration();
  @override
  void initState() {
    super.initState();
    _integration.intiateRazorPay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //  backgroundColor: Colors.redAccent,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(255, 63, 111, 1),
          title: const Text('CanteeXpress'),
        ),
        body: SizedBox(
            //height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    if (cartcontroller.cartProducts.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(19)),
                            width: double.infinity,
                            child: const Center(
                              child: Text(
                                "Zero items in cart .",
                                style: TextStyle(color: Colors.black),
                              ),
                            )),
                      );
                    } else {
                      return Container(
                          padding: const EdgeInsets.all(10),
                          child: ListView.builder(
                            itemCount: cartcontroller.cartProducts.length,
                            itemBuilder: ((context, index) {
                              return productCartListTile(
                                  product: cartcontroller.cartProducts[index]);
                            }),
                          ));
                    }
                  }),
                ),
                const Divider(),
                Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20))),
                    // height: 200,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                          child: ListTile(
                            title: const Text("-"),
                            leading: const Text("Price"),
                            trailing: Obx(
                              () => Text("\$ ${totalPrice()}"),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                          child: ListTile(
                            title: Text("-"),
                            leading: Text("Discount"),
                            trailing: Text("\$ " "-0"),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: ListTile(
                            title: const Text("-"),
                            leading: const Text("Total"),
                            trailing: Obx(() => Text("\$${totalPrice()}")),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Card(
                          elevation: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                        child: Obx(() => Text(
                                              "\$ ${totalPrice()}",
                                              style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 17,
                                                  letterSpacing: 1,
                                                  fontWeight: FontWeight.bold),
                                            ))),
                                    const Text(
                                      "Total Amount",
                                      style: TextStyle(
                                          //    color: Colors.green,
                                          fontSize: 11,
                                          // letterSpacing: 1,
                                          fontWeight: FontWeight.w200),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(255, 63, 111, 1),
                                  ),
                                  onPressed: () {
                                    print(totalPrice());
                                    if (totalPrice() != "0.00") {
                                      _integration.openSession(
                                          amount: num.parse(totalPrice()));
                                    }
                                  },
                                  child: const Text(
                                    "Confirm Order",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 70,
                ),
              ],
            )));
  }

  Widget productCartListTile({required FoodModel product}) {
    return Card(
      child: ListTile(
          leading: SizedBox(
            width: 50,
            child: Image.network(product.image, fit: BoxFit.fitWidth,
                errorBuilder: (
              context,
              v,
              c,
            ) {
              return const Icon(Icons.emoji_food_beverage_rounded);
            }),
          ),
          title: Text(product.name.toString(),
              style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600)),
          subtitle: Text(
            "${product.quantity} * ${product.price}=\$ ${(product.price * product.quantity).toStringAsFixed(1)}",
            style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w600),
          ),
          trailing: FittedBox(
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      var index = cartcontroller.cartProducts
                          .indexWhere((element) => element.id == product.id);
                      if (cartcontroller.cartProducts[index].quantity == 1) {
                        cartcontroller.cartProducts
                            .removeWhere((element) => element.id == product.id);
                      } else {
                        cartcontroller.cartProducts[index].quantity--;
                        cartcontroller.cartProducts.refresh();
                      }
                    },
                    child: const Icon(
                      Icons.remove,
                      color: Colors.black,
                      size: 16,
                    )),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white),
                    child: Text(
                      product.quantity.toString(),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    )),
                InkWell(
                    onTap: () {
                      var index = cartcontroller.cartProducts
                          .indexWhere((element) => element.id == product.id);
                      cartcontroller.cartProducts[index].quantity++;
                      cartcontroller.cartProducts.refresh();
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 16,
                    )),
              ],
            ),
          )),
    );
  }

  String totalPrice() {
    double price = 0;
    for (var element in cartcontroller.cartProducts) {
      var itemPrice = element.price * element.quantity;
      price = price + double.parse(itemPrice.toString());
    }
    return price.toStringAsFixed(2);
  }
}
