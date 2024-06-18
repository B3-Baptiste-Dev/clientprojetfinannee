import 'package:client/views/pages/CategoryDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

class RechercherScreen extends StatefulWidget {
  const RechercherScreen({super.key});

  @override
  State<RechercherScreen> createState() => _RechercherScreenState();
}

class _RechercherScreenState extends State<RechercherScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    var response = await http.get(Uri.parse('${Config.API_URL}/api/v1/categories'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      print('Failed to load categories');
    }
  }

  void searchCategories(String query) async {
    var response = await http.get(Uri.parse('${Config.API_URL}/api/v1/categories/search?query=$query'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      print('Failed to search categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rechercher')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Recherche',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => searchCategories(value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryDetailsScreen(
                        categoryId: categories[index]['id'],
                        categoryName: categories[index]['name'],
                      )),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(categories[index]['name']),
                      ),
                    ),
                  ),
                );
              },
            ),

          ),
        ],
      ),
    );
  }
}
