import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/models/user.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  final UserModel _user = UserModel();
  bool isSignedIn = false, showPassword = true, showConfirmPassword = true;
  AuthNotifier authNotifier = Get.put(AuthNotifier());

  @override
  void initState() {
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

    if (_user.displayName!.length < 3) {
      toast("Name must have atleast 3 characters");
    } else if (!regExp.hasMatch(_user.email ?? "")) {
      toast("Enter a valid Email ID");
    } else if (_user.phone!.length != 10) {
      toast("Contact number length must be 10");
    } else if (int.tryParse(_user.phone ?? "") == null) {
      toast("Contact number must be a number");
    } else if (_user.password!.length < 8) {
      toast("Password must have atleast 8 characters");
    } else if (_passwordController.text.toString() != _user.password) {
      toast("Confirm password does'nt match your password");
    } else {
      print("Success");
      _user.role = "admin";
      _user.balance = 0.0;

         signUp(_user, authNotifier, context);
    }
  }

  Widget _buildSignUPForm() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 60,
        ),
        // User Name Field
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
              _user.displayName = value;
            },
            cursorColor: const Color.fromRGBO(255, 63, 111, 1),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'User name',
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
              icon: Icon(
                Icons.account_circle,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        // Email Field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextFormField(
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              _user.email = value;
            },
            keyboardType: TextInputType.emailAddress,
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
        ),
        const SizedBox(
          height: 20,
        ),
        //Phone Number Field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextFormField(
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              _user.phone = value;
            },
            keyboardType: TextInputType.phone,
            cursorColor: const Color.fromRGBO(255, 63, 111, 1),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Contact Number',
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
              icon: Icon(
                Icons.phone,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        // Password Field
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
                    (showPassword) ? Icons.visibility_off : Icons.visibility,
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
        // Confirm Password Field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextFormField(
            validator: (value) {
              return null;
            },
            obscureText: showConfirmPassword,
            keyboardType: TextInputType.visiblePassword,
            controller: _passwordController,
            cursorColor: const Color.fromRGBO(255, 63, 111, 1),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: Icon(
                    (showConfirmPassword)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: const Color.fromRGBO(255, 63, 111, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  }),
              border: InputBorder.none,
              hintText: 'Confirm Password',
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
          height: 50,
        ),
        // Sign Up Button
        GestureDetector(
          onTap: () {
            _submitForm();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Sign Up",
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
        // Login Line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Already a registered user?',
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
                Navigator.pop(context);
              },
              child: Container(
                child: const Text(
                  'Log In here',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Container(
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
                ),
                const Text(
                  '',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 17,
                    color: Color.fromRGBO(252, 188, 126, 1),
                  ),
                ),
                _buildSignUPForm()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
