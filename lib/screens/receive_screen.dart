import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transfer_model.dart';
import '../providers/auth_provider.dart';
import '../providers/transfer_provider.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transferProvider = Provider.of<TransferProvider>(context);

    if (authProvider.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Transfers')),
      body: StreamBuilder<List<TransferModel>>(
        stream: transferProvider.incomingTransfers(authProvider.user!.shortCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transfers found.'));
          }

          final transfers = snapshot.data!;
          return ListView.builder(
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final transfer = transfers[index];
              return TransferListItem(transfer: transfer);
            },
          );
        },
      ),
    );
  }
}

class TransferListItem extends StatefulWidget {
  final TransferModel transfer;
  const TransferListItem({super.key, required this.transfer});

  @override
  State<TransferListItem> createState() => _TransferListItemState();
}

class _TransferListItemState extends State<TransferListItem> {
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  Future<void> _downloadFile() async {
    if (widget.transfer.fileUrl == null) return;

    // Permission handling
    if (await Permission.storage.request().isGranted || await Permission.manageExternalStorage.request().isGranted) {
       // Proceed
    }

    setState(() => _isDownloading = true);

    try {
      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${widget.transfer.fileName}';

      await dio.download(
        widget.transfer.fileUrl!,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download Complete!')));
        OpenFilex.open(savePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.file_present, color: Colors.blue),
        title: Text(widget.transfer.fileName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${(widget.transfer.fileSize / 1024).toStringAsFixed(2)} KB'),
            if (_isDownloading) ...[
              const SizedBox(height: 5),
              LinearProgressIndicator(value: _downloadProgress),
            ],
          ],
        ),
        trailing: widget.transfer.status == TransferStatus.completed
            ? IconButton(
                icon: Icon(_isDownloading ? Icons.sync : Icons.download_for_offline),
                onPressed: _isDownloading ? null : _downloadFile,
              )
            : const Icon(Icons.hourglass_empty, color: Colors.orange),
      ),
    );
  }
}
