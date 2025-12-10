import 'package:flutter/material.dart';
import 'package:remix_icons_flutter/remixicon_ids.dart';
import 'package:remix_icons_flutter/remixicon_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remix Icons',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Remix Icons'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchQuery = '';
  List<IconData> filteredIcons = [];

  @override
  void initState() {
    super.initState();
    filteredIcons = List.from(allIcons);
  }

  void filterIcons(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredIcons = List.from(allIcons);
      } else {
        filteredIcons = allIcons.where((icon) {
          final iconName =
              icon.codePoint.toString() + icon.toString().toLowerCase();
          return iconName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void clearSearch() {
    setState(() {
      searchQuery = '';
      filteredIcons = List.from(allIcons);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm icon...',
                prefixIcon: const Icon(RemixIcon.searchLine),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          RemixIcon.closeLine,
                        ),
                        onPressed: clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: filterIcons,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
              ),
              itemCount: filteredIcons.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        final iconName = filteredIcons[index].toString();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(iconName)),
                        );
                      },
                      icon: Icon(
                        filteredIcons[index],
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      filteredIcons[index].codePoint.toString(),
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Directionality(
                        textDirection: TextDirection.rtl,
                        child: Icon(RemixIcon.sortAsc)),
                    Directionality(
                        textDirection: TextDirection.rtl,
                        child: Icon(
                            RemixIcon.sortAsc.dir(matchTextDirection: true)))
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Zoom Out',
        child: const Icon(
          RemixIcon.zoomOutLine,
          size: 30,
          weight: 50,
          color: Colors.black,
        ),
      ),
    );
  }
}

extension IconDataX on IconData {
  /// Tạo Icon có matchTextDirection = true (tự động flip khi RTL)
  IconData dir({
    bool matchTextDirection = true,
  }) {
    return IconData(
      codePoint,
      fontFamily: fontFamily,
      fontPackage: fontPackage,
      matchTextDirection: matchTextDirection,
    );
  }
}
