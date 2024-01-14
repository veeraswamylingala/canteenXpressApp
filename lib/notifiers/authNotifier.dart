import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:online_food_order_app/models/user.dart';

import '../apis/foodAPIs.dart';
import '../models/food.dart';

class AuthNotifier extends GetxController {
  User? _user;

  User? get user {
    return _user;
  }

  void setUser(User? user) {
    _user = user;
  }

  // Test
  UserModel? _adminDetails;

  UserModel? get adminDetails => _adminDetails;

  setUserDetails(UserModel? user) {
    _adminDetails = user;
  }
}
