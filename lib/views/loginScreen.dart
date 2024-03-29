import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/models/user.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';

import 'signup.dart';
import 'userviews/navigationBar.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  AuthNotifier authNotifier = Get.put(AuthNotifier());

  final UserModel _user = UserModel();
  bool isSignedIn = false, showPassword = true;

  TabController? tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    initializeCurrentUser(authNotifier, context);
    super.initState();
  }

  void toast(String data) {
    Fluttertoast.showToast(
        msg: data,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white);
  }

  void _submitForm() {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    _formkey.currentState!.save();

    RegExp regExp =
        RegExp(r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$');
    if (!regExp.hasMatch(_user.email ?? "")) {
      toast("Enter a valid Email ID");
    } else if (_user.password!.length < 8) {
      toast("Password must have atleast 8 characters");
    } else {
      print("Success");
      login(_user, authNotifier, context);

    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(255, 138, 120, 1),
                Color.fromRGBO(255, 114, 117, 1),
                Color.fromRGBO(255, 63, 111, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 60),
                child: const Text(
                  'CanteeXpress',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'MuseoModerno',
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                child: Container(
                  //color: Colors.red,
                  child: TabBar(
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.red,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(
                        text: "USER",
                      ),
                      Tab(
                        text: "ADMIN",
                      )
                    ],
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Colors.red,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [userLoginWidget(), adminLoginWidget()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userLoginWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            //login using gmail---
            await signInWithGoogle(
                    authNotifier: Get.put(
                      AuthNotifier(),
                    ),
                    context: context)
                .then((value) {
              if (value) {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return NavigationBarPage(selectedIndex: 1);
                  },
                ));
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Gmail",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget adminLoginWidget() {
    return SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            // Email Text Field
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _user.email = value;
                },
                cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255, 63, 111, 1),
                  ),
                  icon: Icon(
                    Icons.email,
                    color: Color.fromRGBO(255, 63, 111, 1),
                  ),
                ),
              ),
            ), //EMAIL TEXT FIELD
            const SizedBox(
              height: 20,
            ),
            // Password Text Field
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: TextFormField(
                obscureText: showPassword,
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _user.password = value;
                },
                keyboardType: TextInputType.visiblePassword,
                cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: Icon(
                        (showPassword)
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color.fromRGBO(255, 63, 111, 1),
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      }),
                  border: InputBorder.none,
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255, 63, 111, 1),
                  ),
                  icon: const Icon(
                    Icons.lock,
                    color: Color.fromRGBO(255, 63, 111, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            //LOGIN BUTTON
            GestureDetector(
              onTap: () {
                _submitForm();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "LogIn",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(255, 63, 111, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Not a registered user?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const SignupPage();
                  },
                ));
              },
              child: Container(
                child: const Text(
                  'Sign Up here',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
      ]
    )
    ));
  }
}
