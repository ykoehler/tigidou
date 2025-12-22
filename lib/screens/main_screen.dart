import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'people_screen.dart';
import 'dashboard_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    final List<Widget> widgetOptions = <Widget>[
      DashboardScreen(
        onNavigate: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const HomeScreen(),
      const PeopleScreen(),
    ];

    return GradientScaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_banner.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            ),
          ),
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),
                accountName: const Text('User'),
                accountEmail: Text(auth.user?.email ?? ''),
              ),
              if (auth.isBiometricAvailable)
                SwitchListTile(
                  title: Text(l10n.enableBiometrics),
                  secondary: const Icon(Icons.fingerprint, color: Colors.white),
                  value: auth.isBiometricEnabled,
                  onChanged: (bool value) async {
                    final success = await auth.setBiometricEnabled(
                      value,
                      l10n.biometricEnrollmentReason,
                    );

                    if (context.mounted) {
                      if (value && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.biometricEnrollmentSuccess),
                          ),
                        );
                      } else if (value && !success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.biometricEnrollmentFailed),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.biometricDisabled)),
                        );
                      }
                    }
                  },
                ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: Text(l10n.logout),
                onTap: () {
                  auth.signOut();
                },
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'v0.1.0',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),
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
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt_rounded),
              label: l10n.todos,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_alt_rounded),
              label: l10n.people,
            ),
          ],
        ),
      ),
    );
  }
}
