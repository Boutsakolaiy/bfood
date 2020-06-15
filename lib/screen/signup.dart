import 'package:bfood_app/utility/my_constant.dart';
import 'package:bfood_app/utility/my_style.dart';
import 'package:bfood_app/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String chooseType, name, user, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: ListView(
        padding: EdgeInsets.all(30.0),
        children: <Widget>[
          myLogo(),
          MyStyle().mySizeBox(),
          showAppName(),
          MyStyle().mySizeBox(),
          nameForm(),
          MyStyle().mySizeBox(),
          userForm(),
          MyStyle().mySizeBox(),
          passwordForm(),
          MyStyle().mySizeBox(),
          MyStyle().showTitleH2('type of member :'),
          MyStyle().mySizeBox(),
          userRadio(),
          shopRadio(),
          riderRadio(),
          MyStyle().mySizeBox(),
          registerButton(),
        ],
      ),
    );
  }

  Widget registerButton() {
    return Container(
      width: 250.0,
      child: RaisedButton(
        color: MyStyle().darkColor,
        onPressed: () {
          print(
              'name = $name, user = $user, password = $password, chooseType = $chooseType');

          if (name == null ||
              name.isEmpty ||
              user == null ||
              user.isEmpty ||
              password == null ||
              password.isEmpty) {
            print('Have space');
            normalDialog(context, 'Have space');
          }else if(chooseType == null){
            normalDialog(context, 'plase choose type register');
          }else{
            checkUser();
          }
        },
        child: Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<Null> checkUser() async {
    String url = '${MyConstant().domain}/bfood/getUserWhereUser.php?isAdd=true&User=$user';
    try{
      Response response = await Dio().get(url);
      if(response.toString() == 'null'){
        registerTread();
      }else{
        normalDialog(context, 'this user \"$user\" has already been used');
      }
    }catch(e){

    }
  }

  Future<Null> registerTread() async {
    String url = '${MyConstant().domain}/bfood/addUser.php?isAdd=true&Name=$name&User=$user&Password=$password&ChooseType=$chooseType';

    try{
      Response response = await Dio().get(url);
      print('res = $response');

      if(response.toString() == 'true'){
        Navigator.pop(context);
      }else{
        normalDialog(context, 'Can not register. Please try again');
      }
    }catch(e){

    }

  }

  Widget userRadio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 250.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Radio(
                value: 'User',
                groupValue: chooseType,
                onChanged: (value) {
                  setState(() {
                    chooseType = value;
                  });
                },
              ),
              Text(
                'User',
                style: TextStyle(color: MyStyle().darkColor),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget shopRadio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 250.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Radio(
                value: 'Shop',
                groupValue: chooseType,
                onChanged: (value) {
                  setState(() {
                    chooseType = value;
                  });
                },
              ),
              Text(
                'Shop',
                style: TextStyle(color: MyStyle().darkColor),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget riderRadio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 250.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Radio(
                value: 'Rider',
                groupValue: chooseType,
                onChanged: (value) {
                  setState(() {
                    chooseType = value;
                  });
                },
              ),
              Text(
                'Rider',
                style: TextStyle(color: MyStyle().darkColor),
              )
            ],
          ),
        ),
      ],
    );
  }

  Row showAppName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        MyStyle().showTitle('B\'Food'),
      ],
    );
  }

  Widget myLogo() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MyStyle().showLogo(),
        ],
      );

  Widget nameForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => name = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.face,
                  color: MyStyle().darkColor,
                ),
                labelStyle: TextStyle(color: MyStyle().darkColor),
                labelText: 'Name :',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkColor)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().primaryColor)),
              ),
            ),
          ),
        ],
      );

  Widget userForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => user = value.trim(),
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
          ),
        ],
      );

  Widget passwordForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => password = value.trim(),
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
          ),
        ],
      );
}
