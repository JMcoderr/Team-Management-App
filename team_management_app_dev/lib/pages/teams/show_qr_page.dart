import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';
import 'package:team_management_app_dev/data/services/teams_service.dart';

// Shows the QR code that allows members to scan it and join the team.
class ShowQrPage extends StatefulWidget {
  const ShowQrPage({super.key, required this.teamId});

  final String teamId;

  @override
  State<ShowQrPage> createState() => _ShowQrPage();
}

class _ShowQrPage extends State<ShowQrPage> {
  late QrImage qrImage;
  bool isLoading = true;
  String? errorMessage;
  final teamsService = TeamsService();

  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  Future<void> _generateQrCode() async {
    final teamIdInt = int.parse(widget.teamId);
    final qrData = await teamsService.generateInviteQrCode(teamIdInt);
    final qrCode = QrCode(
      8,
      QrErrorCorrectLevel.H,
    )..addData(qrData);
    
    setState(() {
      qrImage = QrImage(qrCode);
      isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show QR Code for invite'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : Center(child: PrettyQrView(qrImage: qrImage)),
      ),
    );
  }
}