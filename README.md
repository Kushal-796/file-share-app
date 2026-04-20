# 🚀 NeoShare: Real-Time Hybrid File Sharing

NeoShare is a professional, high-performance mobile application built with Flutter that enables users to transfer files seamlessly using either local Peer-to-Peer (P2P) connections or a high-speed Cloud fallback. Inspired by the Neo 1 wearable ecosystem, it prioritizes proximity-based sharing while ensuring reliability through global cloud infrastructure.

---

## 🏗 Architecture & Tech Stack

The project follows a **Clean Architecture** pattern to ensure scalability and maintainability:

- **Frontend**: Flutter (Null Safety, Provider State Management)
- **Identity**: Firebase Auth (Anonymous Session Management)
- **Metadata/Handshaking**: Cloud Firestore (Real-time signaling)
- **File Storage**: Supabase Storage (S3-compatible, high-bandwidth)
- **Local P2P**: Nearby Connections (Wi-Fi Direct, BLE, Local Subnet)
- **Networking**: Dio (Progress tracking, resilient downloads)

---

## ✨ Key Features

### 1. Hybrid Transfer Engine
- **Proximity Discovery**: Automatically detects nearby devices using Bluetooth Low Energy and Wi-Fi Direct.
- **Auto-Handshake**: Tapping a detected device instantly exchanges 6-digit codes to establish a secure tunnel.
- **Cloud Fallback**: If devices aren't physically nearby, the app automatically routes the transfer through Supabase's global edge network.

### 2. Intelligent File Management
- **Multi-File Support**: Select and queue multiple files for a single session.
- **Resilient Queue**: If one file in a batch fails (network drop), the app continues with the rest of the queue.
- **Selective Removal**: Real-time UI controls to unselect files before initiating transfer.
- **Safety Blocks**: 
    - **Self-Send Blocking**: Prevents users from sending files to their own unique code.
    - **Existence Verification**: Queries Firestore to ensure the recipient code is active before starting an upload.
    - **500MB Limit**: Enforces a strict per-file limit to prevent device memory exhaustion.

### 3. User Experience
- **Unique Short Codes**: Automatically generates human-readable 6-character codes (e.g., `A1B2C3`).
- **Real-Time Progress**: Granular upload/download progress bars for every file.
- **One-Tap Open**: Uses `open_filex` to let users launch received files directly from the app.

---

## 🛠 Project Evolution & Issue Resolution

During development, we navigated several complex engineering hurdles:

| Problem | Resolution |
| :--- | :--- |
| **Android SDK Mismatch** | Standardized on **SDK 35** to accommodate the latest `app_links` and `path_provider` requirements. |
| **Java 21 Compatibility** | Upgraded **AGP to 8.2.1** and Gradle to 8.3 to fix `jlink` image transformation errors. |
| **API Version Conflicts** | Downgraded `nearby_connections` to **4.3.0** and refactored the service layer to match its specific callback signatures (`onPayLoadRecieved`). |
| **Storage RLS Issues** | Configured custom Supabase **Storage Policies** to allow `anon` uploads while bypassing standard auth-sync bottlenecks. |
| **Notification Versions** | Stripped heavy FCM dependencies that caused language version mismatches, prioritizing core transfer stability. |

---

## 🚀 Setup Instructions

### Firebase Configuration
1. Enable **Anonymous Auth** in Firebase Console.
2. Create a Firestore Database in **Test Mode**.
3. Create a composite index for the `transfers` collection: `receiverCode (Asc) + timestamp (Desc)`.

### Supabase Configuration
1. Create a public bucket named `transfers`.
2. Apply the following Storage Policy (SQL):
   ```sql
   bucket_id = 'transfers'
   ```
3. Update `lib/main.dart` with your `PROJECT_URL` and `ANON_KEY`.

### Android Permissions
The app requires these core permissions (already in manifest):
- `ACCESS_FINE_LOCATION` / `BLUETOOTH_SCAN` (Discovery)
- `NEARBY_WIFI_DEVICES` (Local Transfer)
- `MANAGE_EXTERNAL_STORAGE` (File Access)

---

## 🔮 Roadmap (Future Additions)

- [ ] **End-to-End Encryption**: Implement AES-256 encryption on files before they hit Supabase.
- [ ] **Transfer History**: A persistent log of all sent/received files stored locally in Hive.
- [ ] **Wearable Sync**: Extension for Neo 1 wearable to allow "Wrist-to-Phone" handoffs.
- [ ] **Dynamic Compression**: On-the-fly image/video compression to speed up transfers.
- [ ] **QR Code Pairing**: Scan to share for even faster pairing in noisy RF environments.

---

## 👨‍💻 Engineering Team
Developed with a focus on high-speed data throughput and resilient P2P connectivity.
