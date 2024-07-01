import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config.dart';
import '../../widgets/buildNotAuthenticatedMessage.dart';

class AddAnnonceScreen extends StatefulWidget {
  @override
  _AddAnnonceScreenState createState() => _AddAnnonceScreenState();
}

class _AddAnnonceScreenState extends State<AddAnnonceScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryIdController = TextEditingController();
  File? _image;
  SharedPreferences? prefs;
  String? token;
  bool isAuthenticated = true;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
    _fetchCategories().then((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  Future<void> _loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs?.getString('jwtToken');
    });
    if (token == null) {
      setState(() {
        isAuthenticated = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final response = await http.get(Uri.parse('${Config.API_URL}/api/v1/categories'));

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> categories = List<Map<String, dynamic>>.from(json.decode(response.body));
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> _addAnnonce() async {
    final position = await _determinePosition();
    if (token == null || _image == null || prefs?.getInt('userId') == null) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de la préparation de la requête.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final categoryId = int.tryParse(_categoryIdController.text);
    if (categoryId == null) {
      Fluttertoast.showToast(
        msg: 'L\'ID de catégorie doit être un nombre.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    var objectData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'categoryId': categoryId.toString(),
      'ownerId': prefs?.getInt('userId').toString(),
      'available': true,
    };

    var uri = Uri.parse('${Config.API_URL}/api/v1/annonces');
    var request = http.MultipartRequest('POST', uri)
      ..fields['object'] = json.encode(objectData)
      ..fields['latitude'] = position.latitude.toString()
      ..fields['longitude'] = position.longitude.toString()
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      Fluttertoast.showToast(
        msg: 'Annonce ajoutée avec succès.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _categoryIdController.clear();
        _image = null;
      });
    } else {
      final responseBody = await response.stream.bytesToString();
      Fluttertoast.showToast(
        msg: 'Erreur lors de l\'ajout de l\'annonce. $responseBody',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation sont refusées.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Les permissions de localisation sont définitivement refusées, nous ne pouvons pas demander les permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isLargeScreen ? null : AppBar(
        title: Text('Ajouter une annonce'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isAuthenticated
          ? buildView()
          : buildNotAuthenticatedMessage(),
    );
  }

  Widget buildView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Titre', _titleController),
          const SizedBox(height: 16),
          _buildTextField('Description', _descriptionController, maxLines: 4),
          const SizedBox(height: 16),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          _image != null
              ? Image.file(_image!)
              : Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text('Aucune image sélectionnée.')),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text('Sélectionner une image'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _addAnnonce,
              icon: Icon(Icons.add),
              label: Text('Ajouter l\'annonce'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _categoryIdController.text.isNotEmpty ? int.tryParse(_categoryIdController.text) : null,
          items: _categories.map((category) {
            return DropdownMenuItem<int>(
              value: category['id'],
              child: Text(category['name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _categoryIdController.text = value.toString();
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Entrez $label',
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
