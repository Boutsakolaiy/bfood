import 'dart:io';

import 'package:bfood_app/model/food_model.dart';
import 'package:bfood_app/utility/my_constant.dart';
import 'package:bfood_app/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditFoodMenu extends StatefulWidget {
  final FoodModel foodModel;
  EditFoodMenu({Key key, this.foodModel}) : super(key: key);
  @override
  _EditFoodMenuState createState() => _EditFoodMenuState();
}

class _EditFoodMenuState extends State<EditFoodMenu> {
  FoodModel foodModels;
  File file;
  String name, price, detail, pathImage;

  @override
  void initState() {
    super.initState();
    foodModels = widget.foodModel;
    name = foodModels.nameFood;
    price = foodModels.price;
    detail = foodModels.detail;
    pathImage = foodModels.pathImage;

    // print(' =========== ');
  }

  @override
  Widget build(BuildContext context) {
    print('data = ${foodModels.nameFood}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${foodModels.nameFood}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            nameFood(),
            groupImage(),
            priceFood(),
            detailFood(),
          ],
        ),
      ),
      floatingActionButton: uploadButton(),
    );
  }

  FloatingActionButton uploadButton() {
    return FloatingActionButton(
      onPressed: () {
        if (name.isEmpty || price.isEmpty || detail.isEmpty) {
          normalDialog(context, 'please enter all value');
        } else {
          confirmEdit();
        }
      },
      child: Icon(Icons.cloud_upload),
    );
  }

  Future<Null> confirmEdit() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Do you want to change value?'),
        children: [
          Row(
            children: [
              FlatButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  editValueOrMySql();
                },
                icon: Icon(Icons.check, color: Colors.green,),
                label: Text('Yes, Ido'),
              ),
              FlatButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.clear, color: Colors.red,),
                label: Text('No, I don\'t'),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<Null> editValueOrMySql() async {
    String id = foodModels.id;
    String url = '${MyConstant().domain}/bfood/editFoodWhereId.php?isAdd=true&id=$id&NameFood=$name&PathImage=$pathImage&Price=$price&Detail=$detail';

    await Dio().get(url).then((value) {
      if (value.toString() == 'true') {
        Navigator.pop(context);
      } else {
        normalDialog(context, 'upload failed, Please try again');
      }
    });
  }

  Widget groupImage() => Row(
        children: [
          IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () => chooseImage(ImageSource.camera)),
          Container(
            padding: EdgeInsets.all(16.0),
            width: 250.0,
            height: 250.0,
            child: file == null
                ? Image.network('${MyConstant().domain}${foodModels.pathImage}',
                    fit: BoxFit.cover)
                : Image.file(file, fit: BoxFit.cover),
          ),
          IconButton(
              icon: Icon(Icons.add_photo_alternate),
              onPressed: () => chooseImage(ImageSource.gallery))
        ],
      );

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

  Widget nameFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => name = value.trim(),
              initialValue: name,
              decoration: InputDecoration(
                labelText: 'food name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );

  Widget priceFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => price = value.trim(),
              keyboardType: TextInputType.number,
              initialValue: price,
              decoration: InputDecoration(
                labelText: 'price Food',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );

  Widget detailFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => detail = value.trim(),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              initialValue: detail,
              decoration: InputDecoration(
                labelText: 'food details',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );
}
