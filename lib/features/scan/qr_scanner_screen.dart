import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/drive_providers.dart';
import '../../data/services/qr_share_service.dart';
import '../preview/preview_args.dart';

enum _ScanState { checkingPermission, permissionDenied, scanning, resolving, success, fileNotFound }

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController();
  _ScanState _state = _ScanState.checkingPermission;
  bool _torchOn = false;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _controller.start();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _controller.stop();
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      setState(() => _state = _ScanState.scanning);
    } else if (status.isPermanentlyDenied) {
      setState(() => _state = _ScanState.permissionDenied);
    } else {
      setState(() => _state = _ScanState.permissionDenied);
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_state != _ScanState.scanning) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final data = parseFileShareData(barcode.rawValue!);
    if (data == null) {
      setState(() {
        _feedbackMessage = "This isn't a CS Bouira QR code";
      });
      return;
    }

    setState(() => _state = _ScanState.resolving);

    _controller.stop();

    _resolveFile(data);
  }

  Future<void> _resolveFile(ShareFileData data) async {
    try {
      final api = ref.read(driveApiServiceProvider);
      final folderPath = data.toPathSegments();
      final node = await api.getPath(folderPath);

      if (data.fileIndex < 0 || data.fileIndex >= node.files.length) {
        throw RangeError.index(data.fileIndex, node.files);
      }

      setState(() => _state = _ScanState.success);

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      context.pushReplacement(
        '/preview',
        extra: PreviewArgs(
          files: node.files,
          initialIndex: data.fileIndex,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = _ScanState.fileNotFound);
    }
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_state == _ScanState.checkingPermission)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_state == _ScanState.permissionDenied)
            _PermissionDeniedView(onOpenSettings: _openSettings, theme: theme)
          else
            _buildScanner(theme),
          if (_feedbackMessage != null && _state == _ScanState.scanning)
            Positioned(
              top: 120,
              left: 32,
              right: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _feedbackMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          if (_state == _ScanState.resolving)
            Container(
              color: Colors.black.withAlpha(200),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          if (_state == _ScanState.success)
            Container(
              color: Colors.black.withAlpha(200),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'File found!',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          if (_state == _ScanState.fileNotFound)
            Container(
              color: Colors.black.withAlpha(220),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'File not found',
                        style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This file may have been moved or deleted.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => context.pop(),
                        child: const Text('Back to Home'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white.withAlpha(200)),
              onPressed: () => context.pop(),
            ),
          ),
          if (_state == _ScanState.scanning)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _torchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleTorch,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(30),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanner(ThemeData theme) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          fit: BoxFit.cover,
          errorBuilder: (context, error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Camera error: $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
        _ScanOverlay(),
      ],
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;
    final topOffset = (size.height - scanAreaSize) / 2 - 40;

    return Stack(
      children: [
        // Darkened edges around scan area
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(
                scanRect: Rect.fromLTWH(
                  (size.width - scanAreaSize) / 2,
                  topOffset,
                  scanAreaSize,
                  scanAreaSize,
                ),
              ),
            ),
          ),
        ),
        // Corner brackets
        Positioned(
          left: (size.width - scanAreaSize) / 2,
          top: topOffset,
          child: SizedBox(
            width: scanAreaSize,
            height: scanAreaSize,
            child: CustomPaint(
              painter: _CornerBracketPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Rect scanRect;

  _ScannerOverlayPainter({required this.scanRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha(160);
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect;
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const bracketLen = 28.0;
    const offset = 4.0;

    // Top-left
    canvas.drawLine(Offset(offset, offset + bracketLen), Offset(offset, offset), paint);
    canvas.drawLine(Offset(offset, offset), Offset(offset + bracketLen, offset), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - offset - bracketLen, offset), Offset(size.width - offset, offset), paint);
    canvas.drawLine(Offset(size.width - offset, offset), Offset(size.width - offset, offset + bracketLen), paint);
    // Bottom-left
    canvas.drawLine(Offset(offset, size.height - offset - bracketLen), Offset(offset, size.height - offset), paint);
    canvas.drawLine(Offset(offset, size.height - offset), Offset(offset + bracketLen, size.height - offset), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - offset - bracketLen, size.height - offset), Offset(size.width - offset, size.height - offset), paint);
    canvas.drawLine(Offset(size.width - offset, size.height - offset), Offset(size.width - offset, size.height - offset - bracketLen), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) => false;
}

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final ThemeData theme;

  const _PermissionDeniedView({
    required this.onOpenSettings,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, color: Colors.white.withAlpha(150), size: 64),
            const SizedBox(height: 24),
            Text(
              'Camera Permission Required',
              style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Camera access is needed to scan QR codes. Please enable it in your device settings.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Open Settings'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
