import 'package:flutter/material.dart';
import 'package:tigidou/l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildNavCard(
                context: context,
                title: l10n.todos,
                icon: Icons.list_alt_rounded,
                color: Colors.blueAccent,
                onTap: () => onNavigate(1), // Index 1 is Todos
              ),
              _buildNavCard(
                context: context,
                title: l10n.people,
                icon: Icons.people_alt_rounded,
                color: Colors.orangeAccent,
                onTap: () => onNavigate(2), // Index 2 is People
              ),
              _buildNavCard(
                context: context,
                title: 'Groceries',
                icon: Icons.shopping_cart_rounded,
                color: Colors.greenAccent,
                isPlaceholder: true,
                onTap: () {},
              ),
              _buildNavCard(
                context: context,
                title: 'Store',
                icon: Icons.store_rounded,
                color: Colors.purpleAccent,
                isPlaceholder: true,
                onTap: () {},
              ),
            ],
          ),
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
