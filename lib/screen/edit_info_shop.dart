import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bfood_app/model/user_model.dart';
import 'package:bfood_app/utility/my_constant.dart';
import 'package:bfood_app/utility/my_style.dart';
import 'package:bfood_app/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInfoShop extends StatefulWidget {
  @override
  _EditInfoShopState createState() => _EditInfoShopState();
}

class _EditInfoShopState extends State<EditInfoShop> {
  UserModel userModel;
  String nameShop, address, phone, urlPicture;
  Location location = Location();
  double lat, lng;
  File file;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    readCurrentInfo();

    location.onLocationChanged.listen((event) {
      setState(() {
        lat = event.latitude;
        lng = event.longitude;
        // print('lat = $lat, lng = $lng');
      });
    });
  }

  Future<Null> readCurrentInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    // print('$idShop');
    String url =
        '${MyConstant().domain}/bfood/getUserWhereId.php?isAdd=true&id=$idShop';
    Response response = await Dio().get(url);
    // print('response =$response');
    var result = json.decode(response.data);
    // print(result);

    for (var map in result) {
      print('map = $map');
      setState(() {
        userModel = UserModel.fromJson(map);
        nameShop = userModel.nameShop;
        address = userModel.address;
        phone = userModel.phone;
        urlPicture = userModel.urlPicture;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit shop infomation'),
      ),
      body: userModel == null ? MyStyle().showProgress() : showContent(),
    );
  }

  Widget showContent() => SingleChildScrollView(
        child: Column(
          children: [
            nameShopForm(),
            showImage(),
            addressForm(),
            phoneForm(),
            lat == null ? MyStyle().showProgress() : showMap(),
            updateButton()
          ],
        ),
      );

  Widget updateButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton.icon(
        color: MyStyle().primaryColor,
        onPressed: () => confirmDialog(),
        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        label: Text(
          'Update',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<Null> confirmDialog() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Are you sure? to charnge your info'),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlineButton(
                onPressed: () {
                  Navigator.pop(context);
                  updateThread();
                },
                child: Text('Yes'),
              ),
              OutlineButton(
                onPressed: () => Navigator.pop(context),
                child: Text('No'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> updateThread() async {
    Random random = Random();
    int i = random.nextInt(10000);
    String nameFile = 'editShop$i.jpg';

    Map<String, dynamic> map = Map();
    map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
    FormData formData = FormData.fromMap(map);

    String urlUpload = '${MyConstant().domain}/bfood/saveShop.php';
    await Dio().post(urlUpload, data: formData).then(
      (value) async {
        urlPicture = '/bfood/Shop/$nameFile';

        String id = userModel.id;
        print(id);
        String url =
            '${MyConstant().domain}/bfood/editUserWhereId.php?isAdd=true&id=$id&NameShop=$nameShop&Address=$address&Phone=$phone&UrlPicture=$urlPicture&Lat=$lat&Lng=$lng';
        Response response = await Dio().get(url);

        if (response.toString() == 'true') {
          Navigator.pop(context);
        } else {
          normalDialog(context, 'please try again');
        }
      },
    );
  }

  Set<Marker> currentMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('myMarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: 'shop', snippet: '$lat , $lng'),
      )
    ].toSet();
  }

  Container showMap() {
    CameraPosition cameraPosition =
        CameraPosition(target: LatLng(lat, lng), zoom: 16.0);

    return Container(
      margin: EdgeInsets.only(top: 16.0),
      height: 250.0,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: currentMarker(),
      ),
    );
  }

  Widget showImage() => Container(
        margin: EdgeInsets.only(top: 16.0),
        child: Row(
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
                  ? Image.network('${MyConstant().domain}$urlPicture')
                  : Image.file(file),
            ),
            IconButton(
              icon: Icon(Icons.add_photo_alternate),
              onPressed: () => chooseImage(ImageSource.gallery),
            ),
          ],
        ),
      );

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var object = await picker.getImage(
        source: source,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );

      setState(() {
        file = File(object.path);
      });
    } catch (e) {}
  }

  Widget nameShopForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            margin: EdgeInsets.only(top: 16.0),
            child: TextFormField(
              onChanged: (value) => nameShop = value,
              initialValue: nameShop,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Name Shop'),
            ),
          ),
        ],
      );

  Widget addressForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            margin: EdgeInsets.only(top: 16.0),
            child: TextFormField(
              onChanged: (value) => address = value,
              initialValue: address,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Address'),
            ),
          ),
        ],
      );

  Widget phoneForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            margin: EdgeInsets.only(top: 16.0),
            child: TextFormField(
              onChanged: (value) => phone = value.trim(),
              initialValue: phone,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Phone'),
            ),
          ),
        ],
      );
}
