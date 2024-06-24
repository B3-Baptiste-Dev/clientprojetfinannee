import 'package:client/views/pages/CategoryDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
      Fluttertoast.showToast(
        msg: 'Échec du chargement des catégories',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void searchCategories(String query) async {
    var response = await http.get(Uri.parse('${Config.API_URL}/api/v1/categories/search?query=$query'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Échec de la recherche de catégories',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isLargeScreen ? null : AppBar(
        title: Text('Rechercher'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Recherche',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) => searchCategories(value),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailsScreen(
                            categoryId: categories[index]['id'],
                            categoryName: categories[index]['name'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 4,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            categories[index]['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
