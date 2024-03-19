import 'package:flutter/material.dart';
import '../model/Annonce.dart';

class MonWidgetImage extends StatelessWidget {
  final Annonce annonce;

  const MonWidgetImage({super.key, required this.annonce});

  @override
  Widget build(BuildContext context) {
    return Image(image: annonce.getImageProvider());
  }
}
