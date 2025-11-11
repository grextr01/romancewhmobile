import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item});
  final Map<String, dynamic> item;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: const Color.fromRGBO(206, 206, 206, 100),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[400]!,
              offset: const Offset(4, 4), // Right and Bottom shadow
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.entries.map((entry) {
                if (entry.key == 'BARCODE') {
                  return Container();
                }
                return Container(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text.rich(TextSpan(
                      text: entry.key.replaceAll('_', ' '),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                            text: ': ',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        TextSpan(
                            text: entry.value.toString(),
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ])),
                );
              }).toList()),
        ),
      ),
    );
  }
}
