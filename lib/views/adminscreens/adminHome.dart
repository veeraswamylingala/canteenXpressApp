import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/models/food.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';
import 'package:online_food_order_app/views/adminscreens/itemForm.dart';
import 'package:online_food_order_app/widgets/customRaisedButton.dart';
import '../../../notifiers/cartNotifier.dart';
import '../loginScreen.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyEdit = GlobalKey<FormState>();
  List<FoodModel> _foodItems = [];
  String name = '';
  AuthNotifier authNotifier = Get.put(AuthNotifier());
  CartNotifier cartNotifier = Get.put(CartNotifier());

  signOutUser() {
    signOut(authNotifier, context);
  }

  @override
  void initState() {
    getAdminDetails(authNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CanteeXpress'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              signOutUser();
            },
          )
        ],
      ),
      // ignore: unrelated_type_equality_checks
      body: (authNotifier.adminDetails == null)
          ? const Center(child: Text("No Items to display"))
          : (authNotifier.adminDetails!.role == 'admin')
              ? adminHome(context)
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: const Text("No Items to display"),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ItemForm()));
          // showDialog(
          //     context: context,
          //     barrierDismissible: false,
          //     builder: (BuildContext context) {
          //       return createNewFoodItem(context);
          //     });
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(255, 63, 111, 1),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget adminHome(context) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('menu_items').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                // List<Food> suggestionList = (name == '')
                //     ? _foodItems
                //     : _foodItems
                //         .where((element) => element.itemName
                //             .toLowerCase()
                //             .contains(name.toLowerCase()))
                //         .toList();
                if (_foodItems.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _foodItems.length,
                        itemBuilder: (context, int i) {
                          return Card(
                            elevation: 10.0,
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
                                      Icons.fastfood);
                                }),
                              ),
                              title: Text(_foodItems[i].name ?? ''),
                              subtitle: Text(
                                  'cost: ${_foodItems[i].price.toString()}'),
                              trailing:
                                  Text('${_foodItems[i].category.toString()}'),

                              onTap: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => ItemForm(foodModel: _foodItems[i],)));
                              },
                            ),
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
          ),
        ],
      ),
    );
  }

  Widget createNewFoodItem(context) {
    String itemName = "";
    int totalQty = 0;
    int price = 0;
    return AlertDialog(
        content: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "New Food Item",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 63, 111, 1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            ],
          ),
        ),
      ],
    ));
  }

  Widget popupEditForm(context, FoodModel data) {
    String itemName = "data.itemName";
    int totalQty = 0;
    //data.totalQty, price = data.price;
    return AlertDialog(
        content: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKeyEdit,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Edit Food Item",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 63, 111, 1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: itemName,
                  validator: (value) {
                    if (value!.length < 3) {
                      return "Not a valid name";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  onSaved: (value) {
                    itemName = value ?? "";
                  },
                  cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                  decoration: const InputDecoration(
                    hintText: 'Food Name',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.fastfood,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextFormField(
              //     initialValue: price.toString(),
              //     validator: (value) {
              //       if (value!.length > 3) {
              //         return "Not a valid price";
              //       } else if (int.tryParse(value) == null)
              //         return "Not a valid integer";
              //       else
              //         return null;
              //     },
              //     keyboardType: const TextInputType.numberWithOptions(),
              //     onSaved: (value) {
              //    //   price = int.parse(value!);
              //     },
              //     cursorColor: const Color.fromRGBO(255, 63, 111, 1),
              //     decoration: const InputDecoration(
              //       hintText: 'Price in INR',
              //       hintStyle: TextStyle(
              //         fontWeight: FontWeight.bold,
              //         color: Color.fromRGBO(255, 63, 111, 1),
              //       ),
              //       icon: Icon(
              //         Icons.attach_money,
              //         color: Color.fromRGBO(255, 63, 111, 1),
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: totalQty.toString(),
                  validator: (value) {
                    if (value!.length > 4) {
                      return "QTY cannot be above 4 digits";
                    } else if (int.tryParse(value) == null)
                      return "Not a valid integer";
                    else
                      return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(),
                  onSaved: (value) {
                    if (value != null) {
                      totalQty = int.parse(value);
                    }
                  },
                  cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                  decoration: const InputDecoration(
                    hintText: 'Total QTY',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    if (_formKeyEdit.currentState!.validate()) {
                      _formKeyEdit.currentState!.save();
                      //   editItem(itemName, price, totalQty, context, data.id);
                    }
                  },
                  child: const CustomRaisedButton(buttonText: 'Edit Item'),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget popupDeleteOrEmpty(context, FoodModel data) {
    return AlertDialog(
        content: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  // deleteItem(data.id, context);
                },
                child: const CustomRaisedButton(buttonText: 'Delete Item'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  ///  editItem(data.itemName, data.price, 0, context, data.id);
                },
                child: const CustomRaisedButton(buttonText: 'Empty Item'),
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
