
import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final Color buttonColor;
  final String onPressRoute;
  final String text;

  MainButton({this.buttonColor, this.onPressRoute, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: buttonColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: () {
            Navigator.pushNamed(context, onPressRoute);
          },
          minWidth: 200.0,
          height: 42.0,
          child: Text(text),
        ),
      ),
    );
  }
}
