import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/test_icons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucide Icons',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lucide Icons'),
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
  late final Map<IconData, String> iconNamesByIcon = {
    for (var i = 0; i < icons.length; i++) icons[i]: iconNames[i],
  };

  @override
  void initState() {
    super.initState();
    filteredIcons = List.from(icons);
  }

  String normalizeSearchText(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
  }

  String searchTextForIcon(IconData icon) {
    final name = iconNamesByIcon[icon] ?? '';
    return [
      name,
      normalizeSearchText(name),
      icon.codePoint.toString(),
      icon.toString(),
    ].join(' ').toLowerCase();
  }

  void filterIcons(String query) {
    final normalizedQuery = normalizeSearchText(query);
    final lowerCaseQuery = query.toLowerCase();

    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredIcons = List.from(icons);
      } else {
        filteredIcons = icons.where((icon) {
          final searchText = searchTextForIcon(icon);
          return searchText.contains(lowerCaseQuery) ||
              searchText.contains(normalizedQuery);
        }).toList();
      }
    });
  }

  void clearSearch() {
    setState(() {
      searchQuery = '';
      filteredIcons = List.from(icons);
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
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          LucideIcons.x,
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
                  crossAxisCount: 20, childAspectRatio: 3 / 4),
              itemCount: filteredIcons.length,
              itemBuilder: (context, index) {
                final icon = filteredIcons[index];
                final iconName = iconNamesByIcon[icon] ?? icon.toString();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(iconName)),
                        );
                      },
                      icon: Icon(
                        icon,
                        // size: 30,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      iconName,
                      style: const TextStyle(fontSize: 8),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // const Directionality(
                    //     textDirection: TextDirection.rtl,
                    //     child: Icon(LucideIcons.aArrowDown)),
                    // const Directionality(
                    //     textDirection: TextDirection.rtl,
                    //     child: Icon(LucideIcons.aArrowDownDir))
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
          LucideIcons.zoomOut,
          size: 30,
          weight: 50,
          color: Colors.black,
        ),
      ),
    );
  }
}
