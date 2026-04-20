import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transfer_provider.dart';
import '../services/nearby_service.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _codeController = TextEditingController();
  final NearbyService _nearbyService = NearbyService();
  List<File> _selectedFiles = [];
  Map<String, String> _nearbyDevices = {}; // ID -> Name (Short Code)
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _startNearbyDiscovery();
  }

  void _startNearbyDiscovery() async {
    setState(() => _isSearching = true);
    bool hasPermissions = await _nearbyService.checkPermissions();
    if (!hasPermissions) {
      await _nearbyService.askPermissions();
    }
    
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      await _nearbyService.startDiscovery(user.shortCode, (id, name) {
        setState(() {
          _nearbyDevices[id] = name;
        });
      });
    }
  }

  @override
  void dispose() {
    _nearbyService.stopAllEndpoints();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        final newFiles = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
        _selectedFiles.addAll(newFiles);
      });
    }
  }

  void _unselectFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _handleSend([String? autoCode]) async {
    final String receiverCode = (autoCode ?? _codeController.text).trim().toUpperCase();
    
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select files')));
      return;
    }
    if (receiverCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid code')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transferProvider = Provider.of<TransferProvider>(context, listen: false);

    try {
      await transferProvider.sendFiles(
        files: _selectedFiles,
        senderId: authProvider.user!.uid,
        senderCode: authProvider.user!.shortCode,
        receiverCode: receiverCode,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfers completed!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transferProvider = Provider.of<TransferProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Send Files')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Enter Receiver Code',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text('Detected Nearby:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                if (_isSearching) const SizedBox(width: 10),
                if (_isSearching) const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 10),
            if (_nearbyDevices.isEmpty) 
               const Text('Searching for nearby devices...', style: TextStyle(fontSize: 12, color: Colors.grey))
            else
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _nearbyDevices.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        avatar: const Icon(Icons.bolt, size: 16, color: Colors.orange),
                        label: Text(entry.value),
                        onPressed: () {
                          setState(() => _codeController.text = entry.value);
                          _handleSend(entry.value);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: transferProvider.isTransferring ? null : _pickFiles,
              icon: const Icon(Icons.copy_all),
              label: Text(_selectedFiles.isEmpty ? 'Select Files' : 'Add More Files'),
            ),
            if (_selectedFiles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(file.path.split('/').last),
                      subtitle: Text('${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (file.lengthSync() > 500 * 1024 * 1024) const Icon(Icons.warning, color: Colors.red),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => _unselectFile(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const Spacer(),
            if (transferProvider.isTransferring) ...[
              LinearProgressIndicator(value: transferProvider.uploadProgress),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: transferProvider.isTransferring ? null : () => _handleSend(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text('Send via Cloud'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
