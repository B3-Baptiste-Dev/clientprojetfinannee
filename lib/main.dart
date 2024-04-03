import 'package:client/views/loginpage_screen.dart';
import 'package:client/views/pages/MyAnnonces.dart';
import 'package:client/views/pages/add_annonce_screen.dart';
import 'package:client/views/register_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'views/compte_screen.dart';
import 'views/liste_screen.dart';
import 'views/message_screen.dart';
import 'views/recherche_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/myannonces': (context) => MyAnnoncesPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    ListeScreen(),
    RechercherScreen(),
    AddAnnonceScreen(),
    MessageScreen(),
    CompteScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        items: const <Widget>[
          Icon(Icons.list, size: 30),
          Icon(Icons.search, size: 30),
          Icon(Icons.add, size: 30),
          Icon(Icons.message, size: 30),
          Icon(Icons.account_circle, size: 30),
        ],
        onTap: onTabTapped,
        backgroundColor: Colors.transparent,
        color: Colors.blue,
        buttonBackgroundColor: Colors.blue,
        height: 70,
      ),
    );
  }
}

