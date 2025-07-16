import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:quantum_list/quantum_list.dart';

/// پنل تنظیمات جامع و کامل برای تمام ویژگی‌های بوردر کوانتومی
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
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Center(
            child: Text('تنظیمات بوردر',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 24),

          // --- بخش عمومی ---
          _buildSectionTitle('عمومی'),
          _buildDropdownSetting(
              'نوع بوردر', _border.type, QuantumBorderType.values, (val) {
            if (val != null) _updateBorder(_border.copyWith(type: val));
          }),
          _buildSliderSetting('ضخامت', _border.strokeWidth, 1, 10, (val) {
            _updateBorder(_border.copyWith(strokeWidth: val));
          }),
          _buildSliderSetting(
              'گردی گوشه‌ها', _border.borderRadius.topLeft.x, 0, 50, (val) {
            _updateBorder(
                _border.copyWith(borderRadius: BorderRadius.circular(val)));
          }),

          // --- بخش رنگ و گرادیانت ---
          _buildSectionTitle('رنگ و گرادیانت'),
          _buildColorSetting('رنگ اصلی (برای Solid/Dashed)', _border.color,
              (color) {
            _updateBorder(_border.copyWith(color: color));
          }),
          _buildGradientSettings(),

          // --- بخش خط‌چین ---
          _buildSectionTitle('خط‌چین / نقطه‌چین'),
          _buildDashPatternSetting(),

          // --- بخش سایه ---
          _buildSectionTitle('سایه'),
          SwitchListTile(
            title: const Text('فعال‌سازی سایه'),
            value: _border.shadow != null,
            onChanged: (val) {
              final newShadow = val
                  ? const BoxShadow(color: Colors.black54, blurRadius: 8)
                  : null;
              _updateBorder(_border.copyWith(shadow: newShadow));
            },
          ),
          if (_border.shadow != null) ...[
            _buildColorSetting('رنگ سایه', _border.shadow!.color, (color) {
              _updateBorder(_border.copyWith(
                  shadow: _border.shadow!.copyWith(color: color)));
            }),
            _buildSliderSetting(
                'میزان محوی سایه', _border.shadow!.blurRadius, 0, 20, (val) {
              _updateBorder(_border.copyWith(
                  shadow: _border.shadow!.copyWith(blurRadius: val)));
            }),
          ]
        ],
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
                value: item, child: Text(item.toString().split('.').last)))
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
        Text('$title: ${value.toStringAsFixed(1)}'),
        Slider(
          value: value,
          min: min,
          max: max,
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
          title: const Text('گرادیانت متحرک'),
          value: _border.isGradientAnimated,
          onChanged: (val) =>
              _updateBorder(_border.copyWith(isGradientAnimated: val)),
        ),
        _buildSliderSetting('سرعت انیمیشن (ثانیه)',
            _border.animationDuration.inSeconds.toDouble(), 1, 10, (val) {
          _updateBorder(_border.copyWith(
              animationDuration: Duration(seconds: val.toInt())));
        }),
        const SizedBox(height: 8),
        ..._border.gradientColors.asMap().entries.map((entry) {
          int index = entry.key;
          Color color = entry.value;
          return ListTile(
            title: Text('رنگ گرادیانت ${index + 1}'),
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
            tooltip: 'افزودن رنگ به گرادیانت',
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
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _dashPatternController1,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'طول خط'),
          onChanged: (val) => _updateDashPattern(),
        )),
        const SizedBox(width: 16),
        Expanded(
            child: TextField(
          controller: _dashPatternController2,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'فاصله'),
          onChanged: (val) => _updateDashPattern(),
        )),
      ],
    );
  }

  void _updateDashPattern() {
    final double? val1 = double.tryParse(_dashPatternController1.text);
    final double? val2 = double.tryParse(_dashPatternController2.text);
    if (val1 != null && val2 != null) {
      _updateBorder(_border.copyWith(dashPattern: [val1, val2]));
    }
  }

  void _pickColor(Color initialColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('انتخاب رنگ'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('تایید'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// متد کمکی برای کپی کردن سایه
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
