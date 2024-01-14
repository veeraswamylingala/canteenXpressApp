import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';

import '../../../notifiers/cartNotifier.dart';

class OrderDetailsPage extends StatefulWidget {
  final dynamic orderdata;

  const OrderDetailsPage(this.orderdata, {super.key});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  AuthNotifier authNotifier = Get.put(AuthNotifier());
  CartNotifier cartNotifier = Get.put(CartNotifier());

  @override
  void initState() {

    getAdminDetails(authNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = widget.orderdata['items'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 30, right: 10),
                ),
              ],
            ),
            const Text(
              "Order Details",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'MuseoModerno',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, int i) {
                  return ListTile(
                    title: Text(
                      "${items[i]["item_name"]}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    subtitle: Text("Quantity: ${items[i]["count"]}"),
                    trailing: Text(
                        "Price: ${items[i]["count"]} * ${items[i]["price"]} = ${items[i]["price"] * items[i]["count"]} INR"),
                  );
                }),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Total Amount: ${widget.orderdata['total'].toString()} INR",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'MuseoModerno',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Status: ${widget.orderdata['is_delivered'] ? "Delivered" : "Pending"}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'MuseoModerno',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // (!widget.orderdata['is_delivered'])
            //     ? GestureDetector(
            //         onTap: () {
            //           orderReceived(widget.orderdata.documentID, context);
            //           print(widget.orderdata.documentID);
            //         },
            //         child: CustomRaisedButton(buttonText: 'Received'),
            //       )
            //     : const Text(""),
          ],
        ),
      ),
    );
  }
}
