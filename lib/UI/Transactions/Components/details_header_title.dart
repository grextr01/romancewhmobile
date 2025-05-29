import 'package:flutter/material.dart';

class DetailsHeaderTitle extends StatelessWidget {
  const DetailsHeaderTitle(
      {super.key, required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(
        text: title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        children: [
          TextSpan(text: text, style: TextStyle(fontWeight: FontWeight.normal))
        ]));
  }
}
