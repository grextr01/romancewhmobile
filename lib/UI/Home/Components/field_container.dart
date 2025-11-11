import 'package:flutter/material.dart';

class FieldContainer extends StatelessWidget {
  const FieldContainer({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          // Padding(padding: const EdgeInsets.only(top: 5)),
          child
        ],
      ),
    );
  }
}
