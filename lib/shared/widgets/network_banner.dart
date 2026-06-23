import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/connectivity_provider.dart';

class NetworkBanner extends ConsumerStatefulWidget {
  const NetworkBanner({super.key});

  @override
  ConsumerState<NetworkBanner> createState() => _NetworkBannerState();
}

class _NetworkBannerState extends ConsumerState<NetworkBanner> {
  bool _visible = false;
  bool _isGreen = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final connected = ref.read(connectivityProvider).value ?? true;
      if (!connected) setState(() { _visible = true; _isGreen = false; });
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
      final wasConnected = prev?.value ?? true;
      final isConnected = next.value ?? true;

      if (!wasConnected && isConnected) {
        _hideTimer?.cancel();
        setState(() { _visible = true; _isGreen = true; });
        _hideTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _visible = false);
        });
      } else if (wasConnected && !isConnected) {
        _hideTimer?.cancel();
        setState(() { _visible = true; _isGreen = false; });
      }
    });

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _visible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Material(
        color: _isGreen ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  _isGreen ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isGreen ? 'Back online' : 'No internet connection',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                if (!_isGreen)
                  GestureDetector(
                    onTap: () => context.push('/downloads'),
                    child: const Text(
                      'Downloads',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      secondChild: const SizedBox.shrink(),
    );
  }
}
