import 'package:client/config.dart';
import 'package:client/views/loginpage_screen.dart';
import 'package:client/views/pages/MyAnnonces.dart';
import 'package:client/views/pages/add_annonce_screen.dart';
import 'package:client/views/register_screen.dart';
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
      theme: ThemeData(
        primaryColor: Config.lightBlue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Config.darkGray),
          bodyMedium: TextStyle(color: Config.darkGray),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Config.lightBlue,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
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
      title: Text('BricoPartage'),
      backgroundColor: Config.lightBlue,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          height: 1,
          color: Config.darkGray,
        ),
        TabBar(
          onTap: onTabTapped,
          indicatorColor: Config.brightOrange,
          tabs: [
            Tab(icon: Icon(Icons.list, color: _currentIndex == 0 ? Config.brightOrange : Config.darkGray), text: "Annonces"),
            Tab(icon: Icon(Icons.search, color: _currentIndex == 1 ? Config.brightOrange : Config.darkGray), text: "Rechercher"),
            Tab(icon: Icon(Icons.add, color: _currentIndex == 2 ? Config.brightOrange : Config.darkGray), text: "Ajouter"),
            Tab(icon: Icon(Icons.message, color: _currentIndex == 3 ? Config.brightOrange : Config.darkGray), text: "Messages"),
            Tab(icon: Icon(Icons.account_circle, color: _currentIndex == 4 ? Config.brightOrange : Config.darkGray), text: "Compte"),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return DefaultTabController(
      length: _children.length,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: IndexedStack(
          index: _currentIndex,
          children: _children,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }
}
