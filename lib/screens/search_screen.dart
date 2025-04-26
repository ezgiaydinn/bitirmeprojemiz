import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/screens/search_filter_screen.dart';
import 'package:bitirmeprojesi/components/search_grid_cell.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  List<Map<String, dynamic>> searchArr = [
    {"name": "Fiction", "img": "assets/images/fiction.png"},
    {"name": "Business", "img": "assets/images/business.png"},
    {"name": "Biography", "img": "assets/images/biography.png"},
    {"name": "Children", "img": "assets/images/children.png"},
    {"name": "Education", "img": "assets/images/education.png"},
    {"name": "Science", "img": "assets/images/science.png"},
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: const Color(0xFFA2D9FF),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchFilterScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for books...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: searchArr.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  return SearchGridCell(sObj: searchArr[index], index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
