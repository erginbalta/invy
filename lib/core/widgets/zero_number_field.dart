import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZeroNumberField extends StatefulWidget {
  const ZeroNumberField({
    required this.controller,
    required this.labelText,
    this.enabled = true,
    this.helperText,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final String? helperText;
  final String? Function(String?)? validator;

  @override
  State<ZeroNumberField> createState() => _ZeroNumberFieldState();
}

class _ZeroNumberFieldState extends State<ZeroNumberField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!widget.enabled) return;

    if (_focusNode.hasFocus && widget.controller.text.trim() == '0') {
      widget.controller.clear();
      return;
    }

    if (!_focusNode.hasFocus && widget.controller.text.trim().isEmpty) {
      widget.controller.text = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
      ),
      validator: widget.validator,
    );
  }
}
