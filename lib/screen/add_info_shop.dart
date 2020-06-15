import 'dart:io';
import 'dart:math';

import 'package:bfood_app/utility/my_constant.dart';
import 'package:bfood_app/utility/my_style.dart';
import 'package:bfood_app/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddInfoShop extends StatefulWidget {
  @override
  _AddInfoShopState createState() => _AddInfoShopState();
}

class _AddInfoShopState extends State<AddInfoShop> {
  double lat, lng;
  File file;
  String nameShop, address, phone, urlImage;

  @override
  void initState() {
    super.initState();
    findLatLng();
  }

  Future<Null> findLatLng() async {
    LocationData locationData = await findLocationData();
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
    });
    print('lat =$lat, lng =$lng');
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add infomation"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyStyle().mySizeBox(),
            nameForm(),
            MyStyle().mySizeBox(),
            addressForm(),
            MyStyle().mySizeBox(),
            phoneForm(),
            MyStyle().mySizeBox(),
            groupImage(),
            MyStyle().mySizeBox(),
            lat == null ? MyStyle().showProgress() : showMap(),
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
            if (nameShop == null ||
                nameShop.isEmpty ||
                address == null ||
                address.isEmpty ||
                phone == null ||
                phone.isEmpty) {
              normalDialog(context, 'please enter all');
            } else if (file == null) {
              normalDialog(context, "please choose your image");
            } else {
              uploadImage();
            }
          },
          icon: Icon(Icons.save, color: Colors.white),
          label: Text(
            'Save Infomation',
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  Future<Null> uploadImage() async {
    Random random = Random();
    int i = random.nextInt(100000);
    String nameImage = 'shop$i.jpg';

    String url = '${MyConstant().domain}/bfood/saveShop.php';

    try {
      Map<String, dynamic> map = Map();

      map['file'] =
          await MultipartFile.fromFile(file.path, filename: nameImage);

      FormData formData = FormData.fromMap(map);
      await Dio().post(url, data: formData).then((value){
        print('respone ==>> $value');
        urlImage = '/bfood/Shop/$nameImage';
        print('uselImage $urlImage');
        editUSerShop();
      });

    } catch (e) {}
  }

  Future<Null> editUSerShop() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.get('id');
    String url = "${MyConstant().domain}/bfood/editUserWhereId.php?isAdd=true&id=$id&NameShop=$nameShop&Address=$address&Phone=$phone&UrlPicture=$urlImage&Lat=$lat&Lng=$lng";

    await Dio().get(url).then((value) {
      if (value.toString() == 'true') {
        Navigator.pop(context);
      } else {
        normalDialog(context, 'couldn\'t saved, Please try again');
      }
    });
  }

  Set<Marker> myMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId("myShop"),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: 'your shop',
            snippet: 'latitude =$lat, longitude =$lng',
          ))
    ].toSet();
  }

  Container showMap() {
    LatLng latLng = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 16.0,
    );

    return Container(
      height: 300.0,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: myMarker(),
      ),
    );
  }

  Row groupImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.add_a_photo,
            size: 36.0,
          ),
          onPressed: () => chooseImage(ImageSource.camera),
        ),
        Container(
          width: 250.0,
          child: file == null
              ? Image.asset("images/my_image.png")
              : Image.file(file),
        ),
        IconButton(
          icon: Icon(
            Icons.add_photo_alternate,
            size: 36.0,
          ),
          onPressed: () => chooseImage(ImageSource.gallery),
        )
      ],
    );
  }

  Future<Null> chooseImage(ImageSource imageSource) async {
    try {
      var object = await ImagePicker.pickImage(
        source: imageSource,
        maxHeight: 800.0,
        maxWidth: 800.0,
      );

      setState(() {
        file = object;
      });
    } catch (e) {}
  }

  Widget nameForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => nameShop = value.trim(),
              decoration: InputDecoration(
                labelText: "Name Shop",
                prefixIcon: Icon(Icons.account_box),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );

  Widget addressForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => address = value.trim(),
              decoration: InputDecoration(
                labelText: "Shop address",
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );

  Widget phoneForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => phone = value.trim(),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Contact",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );
}
