import 'package:flutter/material.dart';

Future<void> normalDialog(BuildContext context, String massage) async {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(massage),
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Ok', style: TextStyle(color: Colors.blue),)),
          ],
        )
      ],
    ),
  );
}
