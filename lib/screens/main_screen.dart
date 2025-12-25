import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'templates_screen.dart';
import 'dashboard_screen.dart';
import 'category_screen.dart';
import '../widgets/template_builder.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:tigidou/l10n/app_localizations.dart';
import '../widgets/gradient_scaffold.dart';
import '../providers/todo_provider.dart';
import '../utils/tool_parser.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final todoProvider = context.watch<TodoProvider>();

    final List<Widget> widgetOptions = <Widget>[
      DashboardScreen(
        onNavigate: (widget) {
          if (widget is HomeScreen) {
            setState(() => _selectedIndex = 1);
          } else if (widget is TemplatesScreen) {
            setState(() => _selectedIndex = 2);
          } else {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => widget));
          }
        },
      ),
      const HomeScreen(),
      const TemplatesScreen(),
    ];

    return GradientScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_banner.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      // Left drawer: Navigation between groups/types
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Navigate',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.dashboard_rounded,
                    color: Colors.white,
                  ),
                  title: Text(
                    l10n.home,
                    style: const TextStyle(color: Colors.white),
                  ),
                  selected: _selectedIndex == 0,
                  selectedTileColor: Colors.white12,
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.list_alt_rounded,
                    color: Colors.white,
                  ),
                  title: Text(
                    l10n.todos,
                    style: const TextStyle(color: Colors.white),
                  ),
                  selected: _selectedIndex == 1,
                  selectedTileColor: Colors.white12,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.format_list_bulleted_rounded,
                    color: Colors.white,
                  ),
                  title: Text(
                    l10n.templates,
                    style: const TextStyle(color: Colors.white),
                  ),
                  selected: _selectedIndex == 2,
                  selectedTileColor: Colors.white12,
                  onTap: () {
                    setState(() => _selectedIndex = 2);
                    Navigator.pop(context);
                  },
                ),
                // Categories (tags) - same group as main navigation
                ...todoProvider.activeTags.map(
                  (tag) => ListTile(
                    leading: Icon(_getIconForTag(tag), color: Colors.white70),
                    title: Text(
                      ToolParser.formatDisplayName(tag),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(
                            title: ToolParser.formatDisplayName(tag),
                            tagFilter: tag,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Divider between main navigation + categories and types
                if (todoProvider.activeTypes.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Divider(color: Colors.white24),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Types',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...todoProvider.activeTypes.map(
                    (type) => ListTile(
                      leading: Icon(
                        _getIconForType(type),
                        color: Colors.white70,
                      ),
                      title: Text(
                        ToolParser.formatDisplayName(type),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CategoryScreen(
                              title: ToolParser.formatDisplayName(type),
                              typeFilter: type,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
      ),
      // Right drawer: Profile/Settings
      endDrawer: Drawer(
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
            ],
          ),
        ),
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _buildFloatingActionButton(context, l10n),
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
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt_rounded),
              label: l10n.todos,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.format_list_bulleted_rounded),
              label: l10n.templates,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'store':
        return Icons.store_rounded;
      case 'person':
        return Icons.person_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  IconData _getIconForTag(String tag) {
    if (tag.contains('groceries')) {
      return Icons.shopping_cart_rounded;
    }
    return Icons.tag_rounded;
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    switch (_selectedIndex) {
      case 2: // Templates
        return FloatingActionButton(
          onPressed: () {
            _showAddTodoDialog(
              context,
              l10n,
              defaultText: '!template {  }',
              title: l10n.addTemplateDialogTitle,
            );
          },
          tooltip: 'Add Template',
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void _showAddTodoDialog(
    BuildContext context,
    AppLocalizations l10n, {
    String defaultText = '',
    String? title,
  }) {
    final TextEditingController controller = TextEditingController(
      text: defaultText,
    );
    showDialog(
      context: context,
      builder: (context) {
        final isTemplate = defaultText.contains('!template');
        return AlertDialog(
          title: Text(title ?? l10n.addTodoDialogTitle),
          content: SingleChildScrollView(
            child: isTemplate
                ? TemplateBuilder(
                    initialValue: controller.text,
                    onChanged: (val) => controller.text = val,
                  )
                : TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: l10n.addTodoHint),
                    autofocus: true,
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Provider.of<TodoProvider>(
                    context,
                    listen: false,
                  ).addTodo(controller.text, null);
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }
}
