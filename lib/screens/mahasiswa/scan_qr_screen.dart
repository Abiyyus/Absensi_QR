import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/absensi_service.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/live_clock.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final _service = AbsensiService();
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _processing = false;
  bool _senter = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || capture.barcodes.isEmpty) return;
    final token = capture.barcodes.first.rawValue;
    if (token == null || token.isEmpty) return;

    setState(() => _processing = true);
    final user = context.read<AuthProvider>().user!;
    final hasil = await _service.prosesScanQR(token, user);

    if (hasil.sukses) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
    }
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => AbsensiResultSheet(
        hasil: hasil,
        onClose: () => Navigator.pop(ctx),
      ),
    );

    if (!mounted) return;
    if (hasil.sukses) {
      Navigator.pop(context, true);
    } else {
      setState(() => _processing = false);
    }
  }

  Future<void> _toggleSenter() async {
    try {
      await _controller.toggleTorch();
      if (mounted) setState(() => _senter = !_senter);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Senter',
            icon: Icon(_senter ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleSenter,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sesi aktif',
                          style: TextStyle(color: Colors.white70)),
                      Text('Pindai QR dari dosen',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const LiveClock(
                  color: Colors.white,
                  fontSize: 24,
                  showDate: false,
                  align: CrossAxisAlignment.end,
                ),
              ],
            ),
          ),
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              overlayBuilder: (context, _) => Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: _processing ? AppColors.success : Colors.white,
                        width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(28),
            child: Text('Arahkan kamera ke QR di layar dosen',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
