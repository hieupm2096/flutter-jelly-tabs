import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _hexPattern = RegExp(r'^#[0-9a-fA-F]{6}$');

const _sliderActiveColor = Color(0xFF2563EB);
const _sliderTrackColor = Color(0xFFCBD5E1);

/// Formats a number the way the RN example does.
String formatNumber(double value, int decimals) =>
    decimals == 0 ? value.round().toString() : value.toStringAsFixed(decimals);

/// A labeled slider with a monospaced value readout, ported from the RN
/// example's `NumberField`.
class NumberField extends StatelessWidget {
  const NumberField({
    required this.label,
    required this.max,
    required this.min,
    required this.onChange,
    required this.value,
    super.key,
    this.decimals = 2,
    this.step = 0.1,
  });

  final int decimals;
  final String label;
  final double max;
  final double min;
  final ValueChanged<double> onChange;
  final double step;
  final double value;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(min, max);
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Slider(
                value: normalized,
                max: max,
                min: min,
                onChanged: (nextValue) =>
                    onChange(double.parse(nextValue.toStringAsFixed(decimals))),
                activeColor: _sliderActiveColor,
                inactiveColor: _sliderTrackColor,
                thumbColor: _sliderActiveColor,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 40,
              child: Text(
                formatNumber(normalized, decimals),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A hex color input with draft state, ported from the RN example's
/// `ColorHexInputField`.
class ColorHexInput extends StatefulWidget {
  const ColorHexInput({
    required this.label,
    required this.onChange,
    required this.value,
    super.key,
  });

  final String label;
  final ValueChanged<String> onChange;
  final String value;

  @override
  State<ColorHexInput> createState() => _ColorHexInputState();
}

class _ColorHexInputState extends State<ColorHexInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.replaceFirst('#', ''),
    );
  }

  @override
  void didUpdateWidget(ColorHexInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.replaceFirst('#', '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDraft(String draft) {
    final normalized = draft.startsWith('#') ? draft : '#$draft';
    if (_hexPattern.hasMatch(normalized)) {
      widget.onChange(normalized);
    }
  }

  void _commitOrReset() {
    if (!_hexPattern.hasMatch('#${_controller.text}')) {
      _controller.text = widget.value.replaceFirst('#', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('hex-input'),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      maxLength: 7,
      onChanged: _updateDraft,
      onEditingComplete: _commitOrReset,
      onSubmitted: (_) => _commitOrReset(),
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontFamily: 'monospace',
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      textCapitalization: TextCapitalization.characters,
      controller: _controller,
      inputFormatters: const [_HexInputFormatter()],
    );
  }
}

/// Strips a leading `#` and keeps at most 6 hex characters so the field
/// shows a bare `RRGGBB`.
class _HexInputFormatter extends TextInputFormatter {
  const _HexInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('#', '').toUpperCase();
    if (text.length > 6) {
      text = text.substring(0, 6);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// A toggle row ported from the RN example's `ToggleField`.
class ToggleField extends StatelessWidget {
  const ToggleField({
    required this.label,
    required this.onChange,
    required this.value,
    super.key,
  });

  final String label;
  final ValueChanged<bool> onChange;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      toggled: value,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => onChange(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 22,
                width: 38,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: value ? _sliderActiveColor : _sliderTrackColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 150),
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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

/// A titled group of fields, ported from the RN example's `Section`.
class Section extends StatelessWidget {
  const Section({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

/// A collapsible section, ported from the RN example's `AccordionSection`.
class AccordionSection extends StatelessWidget {
  const AccordionSection({
    required this.title,
    required this.expanded,
    required this.onPress,
    required this.children,
    super.key,
  });

  final String title;
  final bool expanded;
  final VoidCallback onPress;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPress,
          child: Container(
            color: expanded ? Colors.white : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: expanded
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 22,
                  color: expanded
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }
}
