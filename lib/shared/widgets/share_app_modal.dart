import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/theme/app_radius.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

const _qrColor = Color(0xFF1A1A2E);

Future<void> showShareAppModal(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const ShareAppModal(),
  );
}

/// QR code for the app's direct APK download link, plus buttons to send the
/// link as a message or the QR code as an image through the share sheet.
class ShareAppModal extends StatefulWidget {
  const ShareAppModal({super.key});

  @override
  State<ShareAppModal> createState() => _ShareAppModalState();
}

class _ShareAppModalState extends State<ShareAppModal> {
  bool _sharingQr = false;

  Future<void> _shareLink() async {
    final l10n = AppLocalizations.of(context)!;
    await SharePlus.instance.share(ShareParams(
      text: l10n.shareAppMessage(AppLinks.apkDownloadUrl),
      subject: l10n.shareAppTitle,
    ));
  }

  Future<void> _shareQr() async {
    if (_sharingQr) return;
    setState(() => _sharingQr = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _renderQrPng(AppLinks.apkDownloadUrl);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/csbouira-qr.png');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: l10n.shareAppMessage(AppLinks.apkDownloadUrl),
        subject: l10n.shareAppTitle,
      ));
    } finally {
      if (mounted) setState(() => _sharingQr = false);
    }
  }

  Future<void> _copyLink() async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(
      const ClipboardData(text: AppLinks.apkDownloadUrl),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.linkCopied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(77),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      l10n.shareAppTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: QrImageView(
                  data: AppLinks.apkDownloadUrl,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: _qrColor,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: _qrColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.shareAppQrHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _shareLink,
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(l10n.shareAppAction),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: l10n.copyLinkAction,
                    onPressed: _copyLink,
                    icon: const Icon(Icons.link),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _sharingQr ? null : _shareQr,
                  icon: _sharingQr
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.qr_code_2, size: 18),
                  label: Text(l10n.shareAppQrAction),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders [data] as a PNG QR code on a white square with a quiet zone, so it
/// stays scannable when shared into dark-themed chat apps.
Future<List<int>> _renderQrPng(String data) async {
  const qrSize = 720.0;
  const margin = 60.0;
  const total = qrSize + margin * 2;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, total, total),
    Paint()..color = Colors.white,
  );
  canvas.translate(margin, margin);
  QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: true,
    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: _qrColor),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: _qrColor,
    ),
  ).paint(canvas, const Size.square(qrSize));

  final image = await recorder
      .endRecording()
      .toImage(total.toInt(), total.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return byteData!.buffer.asUint8List();
}
