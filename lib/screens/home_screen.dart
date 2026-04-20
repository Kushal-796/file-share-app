import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/nearby_service.dart';
import 'send_screen.dart';
import 'receive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NearbyService _nearbyService = NearbyService();
  bool _isDiscoverable = false;

  @override
  void initState() {
    super.initState();
    _setupNearby();
  }

  void _setupNearby() async {
    bool hasPermissions = await _nearbyService.checkPermissions();
    if (!hasPermissions) {
      await _nearbyService.askPermissions();
    }
  }

  void _toggleDiscoverable(String shortCode) async {
    if (_isDiscoverable) {
      await _nearbyService.stopAllEndpoints();
      setState(() => _isDiscoverable = false);
    } else {
      await _nearbyService.startAdvertising(shortCode, (connectionInfo) {
        // Handle incoming connection requests
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nearby connection request received'))
        );
      });
      setState(() => _isDiscoverable = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time File Share'),
        actions: [
          IconButton(
            icon: Icon(_isDiscoverable ? Icons.visibility : Icons.visibility_off, 
                 color: _isDiscoverable ? Colors.green : Colors.grey),
            onPressed: user != null ? () => _toggleDiscoverable(user.shortCode) : null,
            tooltip: 'Toggle Nearby Visibility',
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Unique Code:',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              user?.shortCode ?? '...',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isDiscoverable ? 'Visible to nearby devices' : 'Nearby visibility off',
              style: TextStyle(color: _isDiscoverable ? Colors.green : Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.send,
                  label: 'Send',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SendScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.download,
                  label: 'Receive',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReceiveScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
