import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';

import 'package:online_food_order_app/widgets/customRaisedButton.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'orderDetails.dart';
import '../loginScreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // Razorpay _razorpay;
  // int money = 0;
  AuthNotifier authNotifier = Get.put(AuthNotifier());

  signOutUser() {
    if (authNotifier.user != null) {
      signOut(authNotifier, context);
    }
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return const LoginPage();
    }));
  }

  @override
  void initState() {
    // AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    // getUserDetails(authNotifier);
    // super.initState();
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
//    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 63, 111, 1),
        title: const Text('Profile'),
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
            Container(
              height: 70,
              width: 70,
              child: CircleAvatar(
                child: Image.network(
                  authNotifier.user!.photoURL ?? "",
                  errorBuilder: (context, v, c) {
                    return const Icon(Icons.account_box);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              authNotifier.user!.displayName ?? "",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'MuseoModerno',
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Divider(
              color: Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Order History",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'MuseoModerno',
              ),
              textAlign: TextAlign.left,
            ),
            //   myOrders(authNotifier.userDetails!.uuid),
          ],
        ),
      ),
    );
  }

  Widget myOrders(uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('placed_by', isEqualTo: uid)
          .orderBy("is_delivered")
          .orderBy("placed_at", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          List<dynamic> orders = snapshot.data!.docs;
          return Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, int i) {
                  return GestureDetector(
                    child: Card(
                      child: ListTile(
                          enabled: !orders[i]['is_delivered'],
                          title: Text("Order #${(i + 1)}"),
                          subtitle: Text(
                              'Total Amount: ${orders[i]['total'].toString()} INR'),
                          trailing: Text(
                              'Status: ${(orders[i]['is_delivered']) ? "Delivered" : "Pending"}')),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsPage(orders[i])));
                    },
                  );
                }),
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: MediaQuery.of(context).size.width * 0.6,
            child: const Text(""),
          );
        }
      },
    );
  }
}
