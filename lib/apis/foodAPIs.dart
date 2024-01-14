import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:online_food_order_app/models/user.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../models/food.dart';

import '../views/adminscreens/adminHome.dart';
import '../views/loginScreen.dart';

ProgressDialog? pr;

void toast(String data) {
  Fluttertoast.showToast(
      msg: data,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white);
}

Future<bool> signInWithGoogle(
    {required AuthNotifier authNotifier, required BuildContext context}) async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn().catchError((e) {
    log("Error");
    toast(e.toString());
  });

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
  log(userCredential.user.toString());
  if (userCredential.user != null) {
    authNotifier.setUser(userCredential.user!);
  }
  return true;
}

login(UserModel user, AuthNotifier authNotifier, BuildContext context) async {
  pr = ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr!.show();
  UserCredential authResult;
  try {
    authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email ?? "", password: user.password ?? "");
  } catch (error) {
    pr!.hide().then((isHidden) {
      print(isHidden);
    });
    toast(error.toString());
    print(error);
    return;
  }

  try {
    User? firebaseUser = authResult.user;
    // if (!firebaseUser!.isAnonymous) {
    //   await FirebaseAuth.instance.signOut();
    //   pr!.hide().then((isHidden) {
    //     print(isHidden);
    //   });
    //   toast("Email ID not verified");
    //   return;
    // } else {
    //   print("Log In: $firebaseUser");
    // }
    if (firebaseUser != null) {
      authNotifier.setUser(firebaseUser);
      await getAdminDetails(authNotifier);
      print("done");
      pr!.hide().then((isHidden) {
        print(isHidden);
      });
      if (authNotifier.adminDetails!.role == 'admin') {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return const AdminHomePage();
        }), (Route<dynamic> route) => false);
      }
    }
  } catch (error) {
    pr!.hide().then((isHidden) {
      print(isHidden);
    });
    toast(error.toString());
    print(error);
    return;
  }
}

signUp(UserModel user, AuthNotifier authNotifier, BuildContext context) async {
  pr = ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr!.show();
  bool userDataUploaded = false;
  UserCredential authResult;
  try {
    authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email!.trim(), password: user.password ?? "");
  } catch (error) {
    pr!.hide().then((isHidden) {
      print(isHidden);
    });
    toast(error.toString());
    print(error);
    return;
  }

  try {
    User? firebaseUser = authResult.user;
    await firebaseUser?.sendEmailVerification();
    await firebaseUser!.updateDisplayName(user.displayName);
    await firebaseUser.updateEmail(user.email ?? "");
    await firebaseUser.reload();
    print("Sign Up: $firebaseUser");
    uploadUserData(user, userDataUploaded);
    await FirebaseAuth.instance.signOut();
    pr!.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Verification link is sent to ${user.email}");
    Navigator.pop(context);
    pr!.hide().then((isHidden) {
      print(isHidden);
    });
  } catch (error) {
    pr!.hide().then((isHidden) {
      print(isHidden);
    });
    toast(error.toString());
    print(error);
    return;
  }
}

getAdminDetails(AuthNotifier authNotifier) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(authNotifier.user!.uid)
      .get()
      .catchError((e) => print(e))
      .then((value) => {
            (value != null)
                ? authNotifier.setUserDetails(UserModel.fromMap(value.data()!))
                : print(value)
          });
}

// getItemsDetails(AuthNotifier authNotifier) async {
//   await FirebaseFirestore.instance
//       .collection('Menu')
//       .doc(authNotifier.user!.uid)
//       .get()
//       .catchError((e) => print(e))
//       .then((value) => {
//     (value != null)
//         ? authNotifier.setUserDetails(UserModel.fromMap(value.data()!))
//         : print(value)
//   });
// }

uploadUserData(UserModel user, bool userdataUpload) async {
  bool userDataUploadVar = userdataUpload;
  User? currentUser = await FirebaseAuth.instance.currentUser;

  CollectionReference userRef = FirebaseFirestore.instance.collection('users');
  CollectionReference cartRef = FirebaseFirestore.instance.collection('carts');

  user.uuid = currentUser!.uid;
  if (userDataUploadVar != true) {
    await userRef
        .doc(currentUser!.uid)
        .set(user.toMap())
        .catchError((e) => print(e))
        .then((value) => userDataUploadVar = true);
  } else {
    print('already uploaded user data');
  }
  print('user data uploaded successfully');
}

initializeCurrentUser(AuthNotifier authNotifier, BuildContext context) async {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  print(firebaseUser.toString());
  if (firebaseUser != null) {
    authNotifier.setUser(firebaseUser);
    //Identify this user is admin or not
    await getAdminDetails(authNotifier);
  }
}

signOut(AuthNotifier authNotifier, BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  authNotifier.setUser(null);
  authNotifier.setUserDetails(null);

  print('log out');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) {
      return const LoginPage();
    }),
  );
}

Future addNewItem(
    {required FoodModel foodModel, required BuildContext context}) async {
  try {
    CollectionReference itemRef =
        FirebaseFirestore.instance.collection('menu_items');
    await itemRef
        .doc(foodModel.id)
        .set(foodModel.toJson())
        .catchError((e) => print(e))
        .then((value) => print("Success"));
  } catch (error) {
    toast("Failed to add to new item!");
    print(error);
    return;
  }
  toast("New Item added successfully!");
}

Future deleteItem(String id, BuildContext context) async {

  try {
    CollectionReference itemRef =
        FirebaseFirestore.instance.collection('menu_items');
    await itemRef
        .doc(id)
        .delete()
        .catchError((e) => print(e))
        .then((value) => print("Success"));
  } catch (error) {
    toast("Failed to edit item!");
    print(error);
    return;
  }
  toast("Item edited successfully!");
}

// placeOrder(BuildContext context, double total) async {
//   pr = ProgressDialog(context,
//       type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
//   pr.show();
//   try {
//     // Initiaization
//     FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
//     CollectionReference cartRef = Firestore.instance.collection('carts');
//     CollectionReference orderRef = Firestore.instance.collection('orders');
//     CollectionReference itemRef = Firestore.instance.collection('items');
//     CollectionReference userRef = Firestore.instance.collection('users');

//     List<String> foodIds = List<String>();
//     Map<String, int> count = <String, int>{};
//     List<dynamic> cartItems = List<dynamic>();

//     // Checking user balance
//     DocumentSnapshot userData = await userRef.document(currentUser.uid).get();
//     if (userData.data['balance'] < total) {
//       pr.hide().then((isHidden) {
//         print(isHidden);
//       });
//       toast("You dont have succifient balance to place this order!");
//       return;
//     }

//     // Getting all cart items of the user
//     QuerySnapshot data = await cartRef
//         .document(currentUser.uid)
//         .collection('items')
//         .getDocuments();
//     data.documents.forEach((item) {
//       foodIds.add(item.documentID);
//       count[item.documentID] = item.data['count'];
//     });

//     // Checking for item availability
//     QuerySnapshot snap = await itemRef
//         .where(FieldPath.documentId, whereIn: foodIds)
//         .getDocuments();
//     for (var i = 0; i < snap.documents.length; i++) {
//       if (snap.documents[i].data['total_qty'] <
//           count[snap.documents[i].documentID]) {
//         pr.hide().then((isHidden) {
//           print(isHidden);
//         });
//         print("not");
//         toast(
//             "Item: ${snap.documents[i].data['item_name']} has QTY: ${snap.documents[i].data['total_qty']} only. Reduce/Remove the item.");
//         return;
//       }
//     }

//     // Creating cart items array
//     snap.documents.forEach((item) {
//       cartItems.add({
//         "item_id": item.documentID,
//         "count": count[item.documentID],
//         "item_name": item.data['item_name'],
//         "price": item.data['price']
//       });
//     });

//     // Creating a transaction
//     await Firestore.instance.runTransaction((Transaction transaction) async {
//       // Update the item count in items table
//       for (var i = 0; i < snap.documents.length; i++) {
//         transaction.update(snap.documents[i].reference, {
//           "total_qty": snap.documents[i].data["total_qty"] -
//               count[snap.documents[i].documentID]
//         });
//       }

//       // Deduct amount from user
//       await userRef
//           .document(currentUser.uid)
//           .updateData({'balance': FieldValue.increment(-1 * total)});

//       // Place a new order
//       await orderRef.document().setData({
//         "items": cartItems,
//         "is_delivered": false,
//         "total": total,
//         "placed_at": DateTime.now(),
//         "placed_by": currentUser.uid
//       });

//       // Empty cart
//       for (var i = 0; i < data.documents.length; i++) {
//         transaction.delete(data.documents[i].reference);
//       }
//       print("in in");
//       // return;
//     });

//     // Successfull transaction
//     pr.hide().then((isHidden) {
//       print(isHidden);
//     });
//     Navigator.pop(context);
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (BuildContext context) {
//         return NavigationBarPage(selectedIndex: 1);
//       }),
//     );
//     toast("Order Placed Successfully!");
//   } catch (error) {
//     pr.hide().then((isHidden) {
//       print(isHidden);
//     });
//     Navigator.pop(context);
//     toast("Failed to place order!");
//     print(error);
//     return;
//   }
// }

// orderReceived(String id, BuildContext context) async {
//   pr = ProgressDialog(context,
//       type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
//   pr.show();
//   try {
//     CollectionReference ordersRef = Firestore.instance.collection('orders');
//     await ordersRef
//         .document(id)
//         .updateData({'is_delivered': true})
//         .catchError((e) => print(e))
//         .then((value) => print("Success"));
//   } catch (error) {
//     pr.hide().then((isHidden) {
//       print(isHidden);
//     });
//     toast("Failed to mark as received!");
//     print(error);
//     return;
//   }
//   pr.hide().then((isHidden) {
//     print(isHidden);
//   });
//   Navigator.pop(context);
//   toast("Order received successfully!");
// }
