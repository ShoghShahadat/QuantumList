import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:quantum_list/quantum_list.dart';

/// A comprehensive settings panel for all QuantumBorder properties.
class BorderSettingsPanel extends StatefulWidget {
  final QuantumBorder initialBorder;
  final ValueChanged<QuantumBorder> onBorderChanged;

  const BorderSettingsPanel(
      {Key? key, required this.initialBorder, required this.onBorderChanged})
      : super(key: key);

  @override
  State<BorderSettingsPanel> createState() => _BorderSettingsPanelState();
}

class _BorderSettingsPanelState extends State<BorderSettingsPanel> {
  late QuantumBorder _border;
  final _dashPatternController1 = TextEditingController();
  final _dashPatternController2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _border = widget.initialBorder;
    _dashPatternController1.text =
        _border.dashPattern.elementAtOrNull(0)?.toString() ?? '8';
    _dashPatternController2.text =
        _border.dashPattern.elementAtOrNull(1)?.toString() ?? '4';
  }

  @override
  void dispose() {
    _dashPatternController1.dispose();
    _dashPatternController2.dispose();
    super.dispose();
  }

  void _updateBorder(QuantumBorder newBorder) {
    setState(() {
      _border = newBorder;
    });
    widget.onBorderChanged(_border);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Text('Border Settings',
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
            const Divider(height: 24),

            // --- General Section ---
            _buildSectionTitle('General'),
            _buildDropdownSetting<QuantumBorderType>(
                'Border Type', _border.type, QuantumBorderType.values, (val) {
              if (val != null) _updateBorder(_border.copyWith(type: val));
            }),
            _buildSliderSetting('Stroke Width', _border.strokeWidth, 1, 10,
                (val) {
              _updateBorder(_border.copyWith(strokeWidth: val));
            }),
            _buildSliderSetting(
                'Border Radius', _border.borderRadius.topLeft.x, 0, 50, (val) {
              _updateBorder(
                  _border.copyWith(borderRadius: BorderRadius.circular(val)));
            }),

            // --- Color & Gradient Section ---
            _buildSectionTitle('Color & Gradient'),
            _buildColorSetting('Solid/Dashed Color', _border.color, (color) {
              _updateBorder(_border.copyWith(color: color));
            }),
            _buildGradientSettings(),

            // --- Dashed/Dotted Section ---
            _buildSectionTitle('Dashed / Dotted'),
            _buildDashPatternSetting(),

            // --- Shadow Section ---
            _buildSectionTitle('Shadow'),
            SwitchListTile(
              title: const Text('Enable Shadow'),
              value: _border.shadow != null,
              onChanged: (val) {
                final newShadow = val
                    ? const BoxShadow(color: Colors.black54, blurRadius: 8)
                    : null;
                // copyWith doesn't support setting shadow to null directly, so we use a workaround
                _updateBorder(QuantumBorder(
                  type: _border.type,
                  strokeWidth: _border.strokeWidth,
                  color: _border.color,
                  gradientColors: _border.gradientColors,
                  dashPattern: _border.dashPattern,
                  borderRadius: _border.borderRadius,
                  isGradientAnimated: _border.isGradientAnimated,
                  animationDuration: _border.animationDuration,
                  shadow: newShadow,
                ));
              },
            ),
            if (_border.shadow != null) ...[
              _buildColorSetting('Shadow Color', _border.shadow!.color,
                  (color) {
                _updateBorder(_border.copyWith(
                    shadow: _border.shadow!.copyWith(color: color)));
              }),
              _buildSliderSetting(
                  'Shadow Blur Radius', _border.shadow!.blurRadius, 0, 20,
                  (val) {
                _updateBorder(_border.copyWith(
                    shadow: _border.shadow!.copyWith(blurRadius: val)));
              }),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title,
          style: TextStyle(
              fontSize: 16,
              color: Colors.purple.shade200,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdownSetting<T>(
      String title, T value, List<T> items, ValueChanged<T?> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                value: item,
                child: Text((item as Enum).name.characters.first.toUpperCase() +
                    (item as Enum).name.substring(1))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderSetting(String title, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('$title: ${value.toStringAsFixed(1)}'),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt() * 2,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildColorSetting(
      String title, Color color, ValueChanged<Color> onColorChanged) {
    return ListTile(
      title: Text(title),
      trailing: CircleAvatar(backgroundColor: color, radius: 14),
      onTap: () => _pickColor(color, onColorChanged),
    );
  }

  Widget _buildGradientSettings() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Animate Gradient'),
          value: _border.isGradientAnimated,
          onChanged: (val) =>
              _updateBorder(_border.copyWith(isGradientAnimated: val)),
        ),
        _buildSliderSetting('Animation Speed (seconds)',
            _border.animationDuration.inSeconds.toDouble(), 1, 10, (val) {
          _updateBorder(_border.copyWith(
              animationDuration: Duration(seconds: val.toInt())));
        }),
        const SizedBox(height: 8),
        ..._border.gradientColors.asMap().entries.map((entry) {
          int index = entry.key;
          Color color = entry.value;
          return ListTile(
            title: Text('Gradient Color ${index + 1}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_border.gradientColors.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      final newColors = List<Color>.from(_border.gradientColors)
                        ..removeAt(index);
                      _updateBorder(
                          _border.copyWith(gradientColors: newColors));
                    },
                  ),
                CircleAvatar(backgroundColor: color, radius: 14),
              ],
            ),
            onTap: () => _pickColor(color, (newColor) {
              final newColors = List<Color>.from(_border.gradientColors);
              newColors[index] = newColor;
              _updateBorder(_border.copyWith(gradientColors: newColors));
            }),
          );
        }),
        Center(
          child: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Gradient Color',
            onPressed: () {
              final newColors = List<Color>.from(_border.gradientColors)
                ..add(Colors.white);
              _updateBorder(_border.copyWith(gradientColors: newColors));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashPatternSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _dashPatternController1,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Dash Length'),
            onChanged: (val) => _updateDashPattern(),
          )),
          const SizedBox(width: 16),
          Expanded(
              child: TextField(
            controller: _dashPatternController2,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Gap Length'),
            onChanged: (val) => _updateDashPattern(),
          )),
        ],
      ),
    );
  }

  void _updateDashPattern() {
    final double? val1 = double.tryParse(_dashPatternController1.text);
    final double? val2 = double.tryParse(_dashPatternController2.text);
    if (val1 != null && val2 != null && val1 > 0 && val2 >= 0) {
      _updateBorder(_border.copyWith(dashPattern: [val1, val2]));
    }
  }

  void _pickColor(Color initialColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// Helper extension for copying BoxShadow, as it lacks a built-in one.
extension BoxShadowCopyWith on BoxShadow {
  BoxShadow copyWith({
    Color? color,
    Offset? offset,
    double? blurRadius,
    double? spreadRadius,
  }) {
    return BoxShadow(
      color: color ?? this.color,
      offset: offset ?? this.offset,
      blurRadius: blurRadius ?? this.blurRadius,
      spreadRadius: spreadRadius ?? this.spreadRadius,
    );
  }
}
