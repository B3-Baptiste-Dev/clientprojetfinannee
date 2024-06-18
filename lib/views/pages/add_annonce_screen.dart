import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../../config.dart';

class AddAnnonceScreen extends StatefulWidget {
  @override
  _AddAnnonceScreenState createState() => _AddAnnonceScreenState();
}

class _AddAnnonceScreenState extends State<AddAnnonceScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryIdController = TextEditingController();
  File? _image;

  Future<void> _addAnnonce() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final position = await _determinePosition();

    if (token == null || _image == null || prefs.getInt('userId') == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la préparation de la requête.')));
      return;
    }

    final categoryId = int.tryParse(_categoryIdController.text);
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('L\'ID de catégorie doit être un nombre.')));
      return;
    }

    var objectData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'categoryId': categoryId.toString(),
      'ownerId': prefs.getInt('userId').toString(),
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Annonce ajoutée avec succès.')));
    } else {
      final responseBody = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'annonce. $responseBody')));
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Titre')),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: _categoryIdController, decoration: InputDecoration(labelText: 'ID Catégorie')),
            SizedBox(height: 20),
            _image != null ? Image.file(_image!) : Text('Aucune image sélectionnée.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Sélectionner une image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addAnnonce,
              child: Text('Ajouter l\'annonce'),
            ),
          ],
        ),
      ),
    );
  }
}
