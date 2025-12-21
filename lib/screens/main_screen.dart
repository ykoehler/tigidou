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
        title: Image.asset(
          'assets/images/logo_banner.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                tooltip: l10n.profile,
                onSelected: (value) {
                  if (value == 'logout') {
                    auth.signOut();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      auth.user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  if (auth.isBiometricAvailable)
                    PopupMenuItem<String>(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return SwitchListTile(
                            title: Text(l10n.enableBiometrics),
                            value: auth.isBiometricEnabled,
                            onChanged: (bool value) {
                              auth.setBiometricEnabled(value);
                              setState(() {});
                            },
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                    ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(l10n.logout),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          unselectedItemColor: Colors.white54,
          selectedItemColor: Colors.blueAccent,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
        ),
      ),
    );
  }
}
