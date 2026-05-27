import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Primary color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _ColorChip(Colors.blue),
                _ColorChip(Colors.green),
                _ColorChip(Colors.orange),
                _ColorChip(Colors.purple),
                _ColorChip(Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Font size'),
            Slider(
              value: theme.textScale,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              label: '${(theme.textScale * 100).round()}%',
              onChanged: (v) => theme.updateTextScale(v),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final Color color;
  const _ColorChip(this.color);

  @override
  Widget build(BuildContext context) {
    final theme = context.read<AppTheme>();
    return ChoiceChip(
      label: const SizedBox(width: 24, height: 12),
      selected: theme.primary == color,
      selectedColor: color,
      onSelected: (_) => theme.updatePrimary(color),
      backgroundColor: color.withOpacity(0.6),
    );
  }
}
