import 'package:flutter/material.dart';
import 'package:tigidou/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'category_screen.dart';
import 'home_screen.dart';
import '../utils/tool_parser.dart';

class DashboardScreen extends StatelessWidget {
  final Function(Widget) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final provider = Provider.of<TodoProvider>(context);
    final types = provider.activeTypes;
    final tags = provider.activeTags;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '${l10n.itsBrand}Tigidou',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back! What would you like to manage today?',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          // Todos + Categories (tags) together
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 1 + tags.length, // Todos + tags
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildNavCard(
                  context: context,
                  title: l10n.todos,
                  icon: Icons.list_alt_rounded,
                  color: Colors.blueAccent,
                  onTap: () => onNavigate(const HomeScreen()),
                );
              }

              final tag = tags[index - 1];
              IconData icon = Icons.tag_rounded;
              Color color = Colors.tealAccent;

              if (tag.contains('groceries')) {
                icon = Icons.shopping_cart_rounded;
                color = Colors.greenAccent;
              }

              return _buildNavCard(
                context: context,
                title: ToolParser.formatDisplayName(tag),
                icon: icon,
                color: color,
                onTap: () => onNavigate(
                  CategoryScreen(
                    title: ToolParser.formatDisplayName(tag),
                    tagFilter: tag,
                  ),
                ),
              );
            },
          ),
          // Types section (separated by divider)
          if (types.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.white24)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Types',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Colors.white24)),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: types.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final type = types[index];
                IconData icon = Icons.category_rounded;
                Color color = Colors.blueGrey;

                if (type.startsWith('store')) {
                  icon = Icons.store_rounded;
                  color = Colors.purpleAccent;
                } else if (type == 'person') {
                  icon = Icons.people_alt_rounded;
                  color = Colors.orangeAccent;
                }

                return _buildNavCard(
                  context: context,
                  title: ToolParser.formatDisplayName(type),
                  icon: icon,
                  color: color,
                  onTap: () => onNavigate(
                    CategoryScreen(
                      title: ToolParser.formatDisplayName(type),
                      typeFilter: type,
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isPlaceholder)
                          const Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
