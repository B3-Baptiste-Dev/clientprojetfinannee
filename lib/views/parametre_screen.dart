import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = 1;

  @override
  void initState() {
    super.initState();
    _loadDistancePreference();
  }

  _loadDistancePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentSliderValue = prefs.getDouble('annonceDistance') ?? 1;
    });
  }

  _saveDistancePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('annonceDistance', _currentSliderValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("Distance pour les annonces (en km): ${_currentSliderValue.toInt()}"),
            Slider(
              value: _currentSliderValue,
              min: 1,
              max: 100,
              divisions: 99,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
              onChangeEnd: (double value) {
                // Sauvegarder la valeur dans les préférences partagées
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setDouble('annonceDistance', value);
                  // Afficher le SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La distance a été mise à jour à $value km.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
