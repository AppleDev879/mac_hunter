
# MAC Hunter

A Flutter desktop application for scanning and displaying local network devices by reading the ARP table. Includes a sleek Matrix-style binary background animation. Built with Flutter and Riverpod for state management.

---

## Features

- **Local Devices IP Scan:** Reads the ARP cache to list IP addresses of devices on the local network.
- **Search:** Search for specific IP addresses in the list.
- **MAC Address Lookup:** Look up the MAC address of a specific IP address.
- **Vendor Lookup:** Look up the vendor information of a specific MAC address.
- **DNS Lookup:** Look up the DNS name of a specific IP address.
- **Primary IP Address:** Display the primary IP address of the running machine.

### Plus:
- **Cross-platform:** Supports Windows, macOS, and Linux by invoking platform-specific ARP commands.
- **Matrix-style animated background:** Falling binary digits rendered via `CustomPainter`.
- **Refresh button:** Dynamically refresh the device list with visual loading indicator.
- **Copy local IP to clipboard:** Quickly copy your machine's local IP address from the app bar.
- **Responsive UI:** Uses Flutter's built-in widgets and animations, designed for desktop window resizing.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.x)
- Desktop support enabled:
  - For macOS, Windows, Linux as applicable.
- Dart SDK compatible with your Flutter version.
- `riverpod` and `riverpod_annotation` dependencies configured.

### Running

1. Clone this repo:

   ```bash
   git clone https://github.com/yourusername/mac_hunter.git
   cd mac_hunter
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Run the app on your desktop platform:

   ```bash
   flutter run -d macos
   # or -d windows, -d linux as appropriate
   ```

---

## Future Improvements

- Implement theme toggle (dark/light).

---

## License

MIT License © Andrew Barrett

---

## Contact

For questions or feedback, reach out at abarrett879 at gmail dot com
