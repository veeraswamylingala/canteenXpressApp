import 'package:flutter/material.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/models/food.dart';

import '../../widgets/customRaisedButton.dart';

class ItemForm extends StatefulWidget {
  final FoodModel? foodModel;
  const ItemForm({Key? key, this.foodModel}) : super(key: key);

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedFType = "Veg";
  TextEditingController _fName = TextEditingController();
  TextEditingController _fDescription = TextEditingController();
  TextEditingController _fPrice = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.foodModel != null) {
      _fName = TextEditingController(text: widget.foodModel!.name.toString());
      _fDescription =
          TextEditingController(text: widget.foodModel!.description.toString());
      _fPrice = TextEditingController(text: widget.foodModel!.price.toString());
      _selectedFType = widget.foodModel!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Food Item"),
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Name";
                      } else {
                        return null;
                      }
                    },
                    controller: _fName,
                    readOnly: widget.foodModel != null,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {},
                    cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                    decoration: const InputDecoration(
                      hintText: 'Food Name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Description";
                      } else {
                        return null;
                      }
                    },
                    controller: _fDescription,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {},
                    cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                    decoration: const InputDecoration(
                      hintText: 'Food Description',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedFType,
                    items: ["Veg", "Non-Veg"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFType = newValue;
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _fPrice,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Price";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {},
                    keyboardType: const TextInputType.numberWithOptions(),
                    cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                    decoration: const InputDecoration(
                      hintText: 'Price in INR',
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              if (widget.foodModel != null) {
                                //update the existing food item
                                FoodModel foodModel = widget.foodModel!;
                                foodModel.description = _fDescription.text;
                                foodModel.category = _selectedFType;
                                foodModel.price = double.parse(_fPrice.text);
                                addNewItem(
                                        foodModel: foodModel, context: context)
                                    .then((value) {
                                  Navigator.pop(context);
                                });
                              } else {
                                //add new food item
                                FoodModel foodModel = FoodModel(
                                    id: idGenerator(),
                                    name: _fName.text,
                                    category: _selectedFType,
                                    price: double.parse(_fPrice.text),
                                    image: "",
                                    description: _fDescription.text,
                                    quantity: 1);
                                addNewItem(
                                        foodModel: foodModel, context: context)
                                    .then((value) {
                                  Navigator.pop(context);
                                });
                              }
                            }
                          },
                          child: CustomRaisedButton(
                              buttonText: widget.foodModel != null
                                  ? "Update Item"
                                  : 'Add Item'),
                        ),
                        Visibility(
                          visible: widget.foodModel != null,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Color.fromRGBO(255, 63, 111, 1),
                                child: IconButton(
                                    onPressed: () {
                                      deleteItem(widget.foodModel!.id, context)
                                          .then((value) {
                                        Navigator.pop(context);
                                      });
                                    },
                                    icon: Icon(Icons.delete))),
                          ),
                        )
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String idGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }
}
