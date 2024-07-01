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
  List<dynamic> _allCategories = [];
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    var response = await http.get(Uri.parse('${Config.API_URL}/api/v1/categories'));
    if (response.statusCode == 200) {
      setState(() {
        _allCategories = json.decode(response.body);
        _categories = _allCategories;
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Échec du chargement des catégories',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Config.brightOrange,
      );
    }
  }

  void filterCategories(String query) {
    final results = _allCategories.where((category) {
      final nameLower = category['name'].toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    setState(() {
      _categories = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isLargeScreen ? null : AppBar(
        title: Text('Rechercher'),
        backgroundColor: Config.lightBlue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Recherche',
                prefixIcon: Icon(Icons.search, color: Config.darkGray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Config.lightBlue),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) => filterCategories(value),
            ),
          ),
          Expanded(
            child: MasonryGridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailsScreen(
                          categoryId: _categories[index]['id'],
                          categoryName: _categories[index]['name'],
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
                          _categories[index]['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Config.navyBlue,
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
        ],
      ),
    );
  }
}
