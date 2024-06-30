import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildNotAuthenticatedMessage() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Text(
          "Vous n'êtes pas connecté.",
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 10),
        Text(
          "Veuillez vous connecter pour accéder à cette page",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    ),
  );
}