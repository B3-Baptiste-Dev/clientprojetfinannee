import 'package:flutter/material.dart';
import '../model/Annonce.dart';

class AnnonceDetailPage extends StatelessWidget {
  final Annonce annonce;

  const AnnonceDetailPage({Key? key, required this.annonce}) : super(key: key);

  void _navigateAndDisplayMessageScreen(BuildContext context) {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(annonce.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(annonce.imageUrl),
            SizedBox(height: 8),
            Text(
              annonce.title,
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 8),
            Text(
              '${annonce.km.toStringAsFixed(1)} km',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            ElevatedButton(
              onPressed: () => _navigateAndDisplayMessageScreen(context),
              child: Text('Contacter et Louer'),
            )
          ],
        ),
      ),
    );
  }
}
