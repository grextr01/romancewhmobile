import 'package:flutter/material.dart';
import 'package:romancewhs/Models/menu_item.dart';
import 'package:romancewhs/UI/import_page.dart';
import 'package:romancewhs/UX/Theme.dart';
import 'package:romancewhs/main.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({
    super.key,
    required this.menus,
    required this.userName,
  });

  final List<MenuItem> menus;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: secondaryColor,
        shadowColor: const Color.fromRGBO(206, 206, 206, 100),
        title: const Text(
          'Menu',
          style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Welcome, $userName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  final menu = menus[index];
                  return _buildMenuButton(context, menu);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, MenuItem menu) {
    // Determine icon and color based on action
    IconData icon = Icons.dashboard;
    Color buttonColor = secondaryColor;

    switch (menu.action) {
      case 'StartCycle':
        icon = Icons.play_circle_outline;
        buttonColor = const Color.fromRGBO(76, 175, 80, 1); // Green
        break;
      case 'ContinueCycle':
        icon = Icons.loop;
        buttonColor = const Color.fromRGBO(33, 150, 243, 1); // Blue
        break;
      case 'ImportData':
        icon = Icons.cloud_download;
        buttonColor = const Color.fromRGBO(255, 152, 0, 1); // Orange
        break;
      case 'ExportData':
        icon = Icons.cloud_upload;
        buttonColor = const Color.fromRGBO(156, 39, 176, 1); // Purple
        break;
      default:
        icon = Icons.widgets;
        break;
    }

    return GestureDetector(
      onTap: () => _handleMenuTap(context, menu),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                buttonColor,
                buttonColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  menu.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuTap(BuildContext context, MenuItem menu) {
    print('Tapped: ${menu.description}');

    // Handle different actions
    switch (menu.action) {
      case 'StartCycle':
        // Navigate to cycle count page
        _navigateToCycleCount(context, 'start');
        break;
      case 'ContinueCycle':
        // Navigate to cycle count page
        _navigateToCycleCount(context, 'continue');
        break;
      case 'ImportData':
        mainNavigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const ImportPage(),
          ),
        );
        break;
      case 'ExportData':
        // Show export dialog (implement later)
        _showExportDialog(context);
        break;
      default:
        // Show generic message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${menu.description} - Coming soon')),
        );
    }
  }

  void _navigateToCycleCount(BuildContext context, String type) {
    // Navigate to cycle count page
    // This is a placeholder - replace with your actual CycleCountPage
    mainNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
                type == 'start' ? 'Start Cycle Count' : 'Continue Cycle Count'),
            backgroundColor: secondaryColor,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'start' ? Icons.play_circle : Icons.loop,
                  size: 80,
                  color: secondaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  type == 'start'
                      ? 'Start Cycle Count'
                      : 'Continue Cycle Count',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    mainNavigatorKey.currentState?.pop();
                  },
                  child: const Text('Go Back'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Database'),
        content: const Text(
            'Export functionality will be implemented in the next phase.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
