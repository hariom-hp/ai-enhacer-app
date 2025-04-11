import 'package:flutter/material.dart';

class EnhancementSettings extends StatefulWidget {
  final double scaleFactor;
  final double creativity;
  final double resemblance;
  final Function(double, double, double) onSettingsChanged;

  const EnhancementSettings({
    Key? key,
    this.scaleFactor = 2.0,
    this.creativity = 0.35,
    this.resemblance = 0.6,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<EnhancementSettings> createState() => _EnhancementSettingsState();
}

class _EnhancementSettingsState extends State<EnhancementSettings> {
  late double _scaleFactor;
  late double _creativity;
  late double _resemblance;

  @override
  void initState() {
    super.initState();
    _scaleFactor = widget.scaleFactor;
    _creativity = widget.creativity;
    _resemblance = widget.resemblance;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enhancement Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSlider(
              label: 'Scale Factor',
              value: _scaleFactor,
              min: 1.0,
              max: 4.0,
              divisions: 6,
              onChanged: (value) {
                setState(() {
                  _scaleFactor = value;
                });
                _notifySettingsChanged();
              },
            ),
            _buildSlider(
              label: 'Creativity',
              value: _creativity,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _creativity = value;
                });
                _notifySettingsChanged();
              },
            ),
            _buildSlider(
              label: 'Resemblance',
              value: _resemblance,
              min: 0.3,
              max: 1.6,
              divisions: 13,
              onChanged: (value) {
                setState(() {
                  _resemblance = value;
                });
                _notifySettingsChanged();
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _scaleFactor = 2.0;
                      _creativity = 0.35;
                      _resemblance = 0.6;
                    });
                    _notifySettingsChanged();
                  },
                  child: const Text('Reset to Default'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _notifySettingsChanged() {
    widget.onSettingsChanged(_scaleFactor, _creativity, _resemblance);
  }
}
