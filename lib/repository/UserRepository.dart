
import '../models/User.dart';

class UserRepository {
  User? user;

  bool hasUser(){
    if(user != null) return true;
    else return false;
  }
}