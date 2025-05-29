import 'package:flutter/material.dart';

class BottomSheetSelector extends StatelessWidget {
  const BottomSheetSelector(
      {super.key,
      required this.title,
      required this.items,
      required this.onTap});
  final String title;
  final List<Map<String, dynamic>> items;
  final Function(String name, String value) onTap;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        heightFactor: 0.8,
        // title: const Text('Select Legal Entity'),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]['Name']),
                    onTap: () {
                      onTap(items[index]['Name'], items[index]['Value']);
                    },
                  );
                },
              ),
            ),
          ],
        ));
  }
}
