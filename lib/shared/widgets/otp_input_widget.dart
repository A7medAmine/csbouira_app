import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_radius.dart';

class OtpInputWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final VoidCallback? onResend;

  const OtpInputWidget({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onResend,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _selfUpdating = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (_selfUpdating) return;

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      if (index > 0) _focusNodes[index - 1].requestFocus();
      return;
    }

    if (digitsOnly.length > 1) {
      _selfUpdating = true;
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digitsOnly.length ? digitsOnly[i] : '';
      }
      _selfUpdating = false;

      if (digitsOnly.length >= widget.length) {
        _focusNodes[widget.length - 1].unfocus();
        _emitCode();
      } else {
        _focusNodes[digitsOnly.length].requestFocus();
      }
      return;
    }

    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
      _emitCode();
    }
  }

  void _emitCode() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < widget.length - 1 ? 8 : 0,
              ),
              child: SizedBox(
                width: 44,
                height: 52,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainer,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant.withAlpha(77),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant.withAlpha(77),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (v) => _onChanged(v, index),
                  onTapOutside: (_) => _focusNodes[index].unfocus(),
                ),
              ),
            );
          }),
        ),
        if (widget.onResend != null) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onResend,
            child: Text(
              'Resend code',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
