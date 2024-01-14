import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/models/food.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';
import 'package:online_food_order_app/notifiers/cartNotifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> cartIds = [];
  List<FoodModel> _foodItems = [];
  String name = '';
  AuthNotifier authNotifier = Get.put(AuthNotifier());
  final CartNotifier cartNotifier = Get.put(CartNotifier());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(255, 63, 111, 1),
          title: const Text('CanteeXpress'),
          //   actions: [Text(cartNotifier.cartProducts.length.toString())],
        ),
        body: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: Column(children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('menu_items')
                    // .where('total_qty', isGreaterThan: 0)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    _foodItems = [];
                    for (var item in snapshot.data!.docs) {
                      _foodItems.add(FoodModel(
                          id: item['id'],
                          name: item['name'],
                          category: item['category'],
                          price: double.parse(item['price'].toString()),
                          image: item['image'],
                          description: item['description'],
                          quantity: item['quantity']));
                    }
                    if (_foodItems.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _foodItems.length,
                            itemBuilder: (context, int i) {
                              return Card(
                                child: ListTile(
                                    leading: SizedBox(
                                      width: 50,
                                      child: Image.network(_foodItems[i].image,
                                          fit: BoxFit.fitWidth, errorBuilder: (
                                        context,
                                        v,
                                        c,
                                      ) {
                                        return Icon(
                                            Icons.emoji_food_beverage_rounded);
                                      }),
                                    ),
                                    title: Text(_foodItems[i].name ?? ''),
                                    subtitle: Text(
                                        'cost: ${_foodItems[i].price.toString()}'),
                                    trailing: Obx(() => IconButton(
                                        icon: cartNotifier.cartProducts
                                                .indexWhere((element) =>
                                                    element.id ==
                                                    _foodItems[i].id)
                                                .isNegative
                                            ? const Icon(Icons.add)
                                            : const Icon(Icons.remove),
                                        onPressed: () async {
                                          !cartNotifier.cartProducts
                                                  .indexWhere((element) =>
                                                      element.id ==
                                                      _foodItems[i].id)
                                                  .isNegative
                                              ? cartNotifier
                                                  .removeFromCart(_foodItems[i])
                                              : cartNotifier
                                                  .addToCart(_foodItems[i]);
                                        }))),
                              );
                            }),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Center(child: const Text("No Items to display")),
                      );
                    }
                  } else {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Center(child: const Text("No Items to display")),
                    );
                  }
                },
              )
            ])));
  }
}
