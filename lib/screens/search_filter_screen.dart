import 'package:flutter/material.dart';

class SearchFilterScreen extends StatelessWidget {
  const SearchFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filters"),
        backgroundColor: const Color(0xFFA2D9FF),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Sort By", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const ListTile(
            title: Text("Relevance"),
            leading: Radio(value: true, groupValue: true, onChanged: null),
          ),
          const ListTile(
            title: Text("Newest First"),
            leading: Radio(value: false, groupValue: true, onChanged: null),
          ),
          const Divider(),
          const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 10,
            children: ["Fiction", "Business", "Science", "Children"]
                .map((e) => Chip(label: Text(e)))
                .toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Apply Filters"),
          )
        ],
      ),
    );
  }
}
