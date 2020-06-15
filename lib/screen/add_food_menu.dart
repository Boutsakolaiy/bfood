import 'dart:io';
import 'dart:math';

import 'package:bfood_app/utility/my_constant.dart';
import 'package:bfood_app/utility/my_style.dart';
import 'package:bfood_app/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFoodMenu extends StatefulWidget {
  @override
  _AddFoodMenuState createState() => _AddFoodMenuState();
}

class _AddFoodMenuState extends State<AddFoodMenu> {
  File file;
  String nameFood, price, detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food Menu'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            showTitleFood('food image'),
            groupImage(),
            showTitleFood('Food details'),
            nameForm(),
            MyStyle().mySizeBox(),
            priceForm(),
            MyStyle().mySizeBox(),
            detailForm(),
            MyStyle().mySizeBox(),
            saveButton()
          ],
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton.icon(
        color: MyStyle().primaryColor,
        onPressed: () {
          if (file == null) {
            normalDialog(context, 'please enter your image');
          } else if (nameFood == null ||
              nameFood.isEmpty ||
              price == null ||
              price.isEmpty ||
              detail == null ||
              detail.isEmpty) {
            normalDialog(context, 'plesse enter all');
          } else {
            uploadFoodAndInsertData();
          }
        },
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        label: Text(
          'Save Food Menu',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<Null> uploadFoodAndInsertData() async {
    String urlUpload = '${MyConstant().domain}/bfood/saveFood.php';
    Random random = Random();
    int i = random.nextInt(1000000);
    String nameFile = 'food$i.jpg';

    try {
      Map<String, dynamic> map = Map();
      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);

      await Dio().post(urlUpload, data: formData).then((value) async {
        String urlPathImage = '/bfood/Food/$nameFile';
        print('urlPathImage =${MyConstant().domain}$urlPathImage');

        SharedPreferences preferences = await SharedPreferences.getInstance();
        String idShop = preferences.getString('id');

        String urlInsertData =
            '${MyConstant().domain}/bfood/addFood.php?isAdd=true&idShop=$idShop&NameFood=$nameFood&PathImage=$urlPathImage&Price=$price&Detail=$detail';
        await Dio().get(urlInsertData).then((value) => Navigator.pop(context));
      });
    } catch (e) {
      print('error = $e');
    }
  }

  Widget nameForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => nameFood = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.fastfood),
            border: OutlineInputBorder(),
            labelText: 'Food name',
          ),
        ),
      );

  Widget priceForm() => Container(
        width: 250.0,
        child: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => price = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
            labelText: 'Price',
          ),
        ),
      );

  Widget detailForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => detail = value.trim(),
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.details),
            border: OutlineInputBorder(),
            labelText: 'Details',
          ),
        ),
      );

  Row groupImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () => chooseImage(ImageSource.camera),
        ),
        Container(
          width: 250.0,
          height: 250.0,
          child: file == null
              ? Image.asset('images/food_image.png')
              : Image.file(file),
        ),
        IconButton(
          icon: Icon(Icons.add_photo_alternate),
          onPressed: () => chooseImage(ImageSource.gallery),
        )
      ],
    );
  }

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker().getImage(
        source: source,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );
      setState(() {
        file = File(object.path);
      });
    } catch (e) {}
  }

  Widget showTitleFood(String string) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: [
          MyStyle().showTitleH2(string),
        ],
      ),
    );
  }
}
