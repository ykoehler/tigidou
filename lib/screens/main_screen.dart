import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'people_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:tigidou/l10n/app_localizations.dart';
import '../widgets/gradient_scaffold.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    PeopleScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GradientScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icon/app_icon.png', height: 32),
            const SizedBox(width: 12),
            Text(l10n.appTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors
            .transparent, // Transparent for gradient effect? Or semi-transparent?
        // Actually BottomNavigationBar needs a background usually or it blends weirdly if body renders behind it.
        // But GradientScaffold body has the gradient.
        // Let's use a semi-transparent background for nav bar.
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        unselectedItemColor: Colors.white60,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: AppLocalizations.of(context)!.todos,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: AppLocalizations.of(context)!.people,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
