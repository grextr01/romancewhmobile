import 'package:flutter/material.dart';

import '../../UX/Theme.dart';

class CustomMainButton extends StatelessWidget {
  const CustomMainButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.textColor = primaryColor,
      this.backgroundColor = const Color.fromRGBO(245, 245, 245, 1),
      this.borderColor = secondaryColor,
      this.height = 50,
      this.width = 350,
      this.borderRadius = 23,
      this.enabled = true,
      this.fontSize = 16,
      this.loading = false});

  final String text;
  final Function() onPressed;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double height;
  final double width;
  final double fontSize;
  final bool loading;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        !loading && enabled ? onPressed() : null;
      },
      child: InkWell(
        child: Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: enabled ? backgroundColor : Colors.grey,
              border: Border.all(
                  color: enabled ? borderColor : Colors.grey, width: 1.3),
              borderRadius: BorderRadius.circular(borderRadius)),
          child: !loading
              ? Text(
                  text,
                  style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: textColor),
                )
              : CircularProgressIndicator(
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
