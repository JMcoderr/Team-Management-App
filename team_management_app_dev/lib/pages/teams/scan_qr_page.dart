import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:team_management_app_dev/data/services/teams_service.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  bool isLoading = true;
  final teamsService = TeamsService();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code invite'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates
        ),
        onDetect: (capture) {
          // Check if it actually scans
          print('IT WORKS!');   
          // print all the data
          print('Capture: $capture');
          // Get the scanned data
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            print('Scanned code: $code');

            // Use the scanned data to join the team
            if (code != null) {
              teamsService.useQRJoin(code).then((_) {
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully joined the team!'),
                    backgroundColor: Colors.green,
                  ),
                );
                if (mounted) {
                  Navigator.pop(context);
                }
              }).catchError((e) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to join team: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            }
          }
        },
      ),
    );
  }
}