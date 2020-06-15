import 'dart:convert';

import 'package:bfood_app/model/user_model.dart';
import 'package:bfood_app/screen/main_rider.dart';
import 'package:bfood_app/screen/main_shop.dart';
import 'package:bfood_app/screen/main_user.dart';
import 'package:bfood_app/utility/my_constant.dart';
import 'package:bfood_app/utility/my_style.dart';
import 'package:bfood_app/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  String user, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(
          colors: <Color>[Colors.white, MyStyle().primaryColor],
          center: Alignment(0, -0.3),
          radius: 1.0,
        )),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MyStyle().showLogo(),
                MyStyle().mySizeBox(),
                MyStyle().showTitle('B\'Food'),
                MyStyle().mySizeBox(),
                userForm(),
                MyStyle().mySizeBox(),
                passwordForm(),
                MyStyle().mySizeBox(),
                loginButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loginButton() {
    return Container(
      width: 250.0,
      child: RaisedButton(
        color: MyStyle().darkColor,
        onPressed: () {
          if(user == null || user.isEmpty || password == null || password.isEmpty){
            normalDialog(context, 'enter');
          }else{
            checkAuthen();
          }
        },
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<Null> checkAuthen() async {
     String url = '${MyConstant().domain}/bfood/getUserWhereUser.php?isAdd=true&User=$user';
     try{
       Response response = await Dio().get(url);
       print('res = $response');

       var result = json.decode(response.data);
       print('rsult = $result');
       for (var map in result){
         UserModel userModel = UserModel.fromJson(map);
         if(password == userModel.password){
           String chooseType = userModel.chooseType;
           if(chooseType == 'User'){
             routeToService(MainUser(), userModel);
           }else if(chooseType == 'Shop'){
             routeToService(MainShop(), userModel);
           }else if(chooseType == 'Rider'){
             routeToService(MainRider(), userModel);
           }else{
             normalDialog(context, 'Error');
           }
         }else{
           normalDialog(context, 'password false');
         }
       }
     }catch(e){

     }
  }

  Future<Null> routeToService(Widget myWidget, UserModel userModel) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('id', userModel.id);
    preferences.setString('ChooseType', userModel.chooseType);
    preferences.setString('Name', userModel.name);

    MaterialPageRoute route = MaterialPageRoute(builder: (context) => myWidget,);
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  Widget userForm() => Container(
        width: 250.0,
        child: TextField(onChanged: (value) => user = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.account_box,
              color: MyStyle().darkColor,
            ),
            labelStyle: TextStyle(color: MyStyle().darkColor),
            labelText: 'User :',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().darkColor)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().primaryColor)),
          ),
        ),
      );

  Widget passwordForm() => Container(
        width: 250.0,
        child: TextField(onChanged: (value) => password = value.trim(),
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: MyStyle().darkColor,
            ),
            labelStyle: TextStyle(color: MyStyle().darkColor),
            labelText: 'Password :',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().darkColor)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().primaryColor)),
          ),
        ),
      );
}
