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
        '/compte': (context) => CompteScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Mon Application'),
      bottom: TabBar(
        onTap: onTabTapped,
        tabs: [
          Tab(icon: Icon(Icons.list), text: "Annonces"),
          Tab(icon: Icon(Icons.search), text: "Rechercher"),
          Tab(icon: Icon(Icons.add), text: "Ajouter"),
          Tab(icon: Icon(Icons.message), text: "Messages"),
          Tab(icon: Icon(Icons.account_circle), text: "Compte"),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return CurvedNavigationBar(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return DefaultTabController(
      length: _children.length,
      child: Scaffold(
        appBar: isLargeScreen ? _buildAppBar() : null,
        body: _children[_currentIndex],
        bottomNavigationBar: isLargeScreen ? null : _buildBottomNavigationBar(),
      ),
    );
  }
}
