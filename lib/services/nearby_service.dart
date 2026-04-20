import 'dart:io';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyService {
  final Strategy strategy = Strategy.P2P_STAR;
  final String serviceId = "com.example.file_share_app"; // Explicit service ID
  String? userName;

  Future<bool> checkPermissions() async {
    if (!Platform.isAndroid) return true;

    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> askPermissions() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ].request();
  }

  // Start advertising (to be discovered by others)
  Future<void> startAdvertising(String name, Function(ConnectionInfo) onConnectionInitiated) async {
    userName = name;
    try {
      await Nearby().startAdvertising(
        userName!,
        strategy,
        serviceId: serviceId,
        onConnectionInitiated: (id, info) {
          onConnectionInitiated(info);
          // Auto-accept connection
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: (endpointId, payload) {
               print("Payload received from $endpointId");
            },
            onPayloadTransferUpdate: (endpointId, update) {
               print("Transfer update from $endpointId: ${update.status}");
            },
          );
        },
        onConnectionResult: (id, status) {
          print("Connection Result: $status");
        },
        onDisconnected: (id) {
          print("Disconnected: $id");
        },
      );
    } catch (e) {
      print("Advertising Error: $e");
    }
  }

  // Start discovery (to find others)
  Future<void> startDiscovery(String name, Function(String, String) onDeviceFound) async {
    userName = name;
    try {
      await Nearby().startDiscovery(
        userName!,
        strategy,
        serviceId: serviceId,
        onEndpointFound: (id, name, serviceId) {
          onDeviceFound(id, name);
        },
        onEndpointLost: (id) {
          print("Endpoint lost: $id");
        },
      );
    } catch (e) {
      print("Discovery Error: $e");
    }
  }

  Future<void> stopAllEndpoints() async {
    await Nearby().stopDiscovery();
    await Nearby().stopAdvertising();
    await Nearby().stopAllEndpoints();
  }

  Future<void> sendFile(String endpointId, File file) async {
    await Nearby().sendFilePayload(endpointId, file.path);
  }
}
