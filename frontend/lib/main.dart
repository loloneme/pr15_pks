import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/pages/cart_page.dart';
import 'package:frontend/pages/drinks_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'pages/profile_page.dart';
import 'pages/favorites_page.dart';
import '../models/drink.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ПР15 ПКС',
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromRGBO(44, 32, 17, 1.0),
          selectedItemColor: Color.fromRGBO(181, 139, 80, 1.0),
          unselectedItemColor: Color.fromRGBO(255, 238, 205, 1.0),
        ),
      ),
      home: const HomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Drink>> _drinksFuture;
  String? _userID;

  // @override
  // void initState(){
  //   super.initState();
  //
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     setState(() {
  //       _userID = user.uid;
  //     });
  //     _drinksFuture = ApiService().getDrinks(_userID);
  //   } else {
  //     _drinksFuture = ApiService().getDrinks();
  //   }
  //
  // }

  int _selectedPage = 0;

  void _addNewDrink(Drink drink) async {
    try {
      final id = await ApiService().createDrink(drink);
      setState(() {
        _drinksFuture = ApiService().getDrinks(_userID);
      });
    } catch (e) {
      print('Ошибка: $e');
    }
  }

  void _removeDrink(index) async {
    try {
      List<Drink> drinks = await _drinksFuture;

      final id = drinks[index].id;
      await ApiService().deleteDrink(id);

      setState(() {
        _drinksFuture = ApiService().getDrinks(_userID);
      });
    } catch (e) {
      print('Ошибка: $e');
    }
  }

  void _toggleFavorite(index) async {
    try {
      List<Drink> drinks = await _drinksFuture;

      if (_userID != ""){
        await ApiService().toggleFavorite(drinks[index].id, _userID!);

        setState(() {
          _drinksFuture = ApiService().getDrinks(_userID);
        });
      }
    } catch (e) {
      print('Ошибка: $e');
    }

  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(),),
            );
          }

          final user = snapshot.data;
          final isLoggedIn = user != null;

          if (isLoggedIn) {
            _userID = user!.uid;
            _drinksFuture = ApiService().getDrinks(_userID!);
          } else {
            _drinksFuture = ApiService().getDrinks();
          }

          return Scaffold(
            backgroundColor: const Color.fromRGBO(44, 32, 17, 1.0),
            body: FutureBuilder<List<Drink>>(
              future: _drinksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Нет доступных напитков'));
                } else {
                  final drinks = snapshot.data!;

                  List<Widget> pageOptions = isLoggedIn
                      ? [
                    DrinksPage(
                      userID: _userID!,
                      drinks: drinks,
                      addNewDrink: _addNewDrink,
                      toggleFavorite: _toggleFavorite,
                      removeDrink: _removeDrink,
                    ),
                    FavoritesPage(
                      userID: _userID!,
                      drinks: drinks,
                      toggleFavorite: _toggleFavorite,
                    ),
                    CartPage(userID: _userID!),
                    ProfilePage(
                        userID: _userID!
                    ),
                  ]
                      : [
                    DrinksPage(
                      userID: "",
                      drinks: drinks,
                      addNewDrink: (){},
                      toggleFavorite: (){},
                      removeDrink: (){},
                    ),
                    const LoginPage(),
                  ];

                  return pageOptions.elementAt(_selectedPage % pageOptions.length);
                }
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: isLoggedIn
                  ? const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.coffee_rounded), label: "Напитки"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_rounded), label: 'Избранное'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_rounded), label: 'Корзина'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Профиль'),
              ]
                  : const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.coffee_rounded), label: "Напитки"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Профиль'),
              ],
              currentIndex: isLoggedIn ? _selectedPage % 4 : _selectedPage % 2,
                selectedItemColor: const Color.fromRGBO(181, 139, 80, 1.0),
              unselectedItemColor: const Color.fromRGBO(255, 238, 205, 1.0),
              backgroundColor: const Color.fromRGBO(44, 32, 17, 1.0),
              selectedLabelStyle:
              GoogleFonts.sourceSerif4(textStyle: const TextStyle()),
              unselectedLabelStyle:
              GoogleFonts.sourceSerif4(textStyle: const TextStyle()),
              onTap: _onItemTapped,
            ),
          );
        }
        );
  }
}
