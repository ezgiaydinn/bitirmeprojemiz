import 'package:flutter/material.dart';

class SearchGridCell extends StatelessWidget {
  final Map<String, dynamic> sObj;
  final int index;

  const SearchGridCell({super.key, required this.sObj, required this.index});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    List<Color> backgroundColors = [
      const Color(0xFF90CAF9),
      const Color(0xFF81D4FA),
      const Color(0xFFB39DDB),
      const Color(0xFFA5D6A7),
      const Color(0xFFFFAB91),
    ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColors[index % backgroundColors.length],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
      child: Column(
        children: [
          Text(
            sObj["name"].toString(),
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              sObj["img"].toString(),
              width: media.width * 0.23,
              height: media.width * 0.23 * 1.6,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}
