import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../model/Annonce.dart';
import '../annonce.detail_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailsScreen({Key? key, required this.categoryId, required this.categoryName}) : super(key: key);

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  List<Annonce> listings = [];

  @override
  void initState() {
    super.initState();
    fetchListings();
  }

  Future<void> fetchListings() async {
    var categoryId = widget.categoryId;
    var response = await http.get(Uri.parse('${Config.API_URL}/api/v1/annonces/by-category?categoriesId=$categoryId'));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body) as List;
      setState(() {
        listings = jsonResponse.map((data) => Annonce.fromJson(data as Map<String, dynamic>)).toList();
      });
    } else {
      print('Failed to load listings');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: listings.isEmpty
          ? Center(child: Text('No listings available'))
          : ListView.builder(
        itemCount: listings.length,
        itemBuilder: (context, index) {
          Annonce listing = listings[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AnnonceDetailPage(annonce: listing),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                    child: Image.network(
                      listing.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      listing.title,
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      listing.description,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
