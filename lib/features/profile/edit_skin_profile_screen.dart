import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/skin_profile.dart';
import '../../services/local_store.dart';
import '../../widgets/glow_widgets.dart';

class EditSkinProfileScreen extends StatefulWidget {
  final SkinProfile? initial;
  const EditSkinProfileScreen({super.key, this.initial});

  @override
  State<EditSkinProfileScreen> createState() => _EditSkinProfileScreenState();
}

class _EditSkinProfileScreenState extends State<EditSkinProfileScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  String _type = 'Kombinasi';
  String _goal = 'Glowing & Sehat';
  Set<String> _concerns = {};

  static const _types = ['Normal', 'Kering', 'Berminyak', 'Kombinasi', 'Sensitif'];
  static const _allConcerns = ['Jerawat', 'Komedo', 'Kusam', 'Dark Spot', 'Pori Besar', 'Sensitif', 'Anti-aging'];
  static const _goals = ['Glowing & Sehat', 'Bebas Jerawat', 'Anti-aging', 'Cerah Merata', 'Hidrasi Maksimal'];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name.text = p?.name ?? '';
    _age.text = (p?.age ?? 22).toString();
    _type = p?.skinType ?? 'Kombinasi';
    _goal = p?.goal ?? 'Glowing & Sehat';
    _concerns = (p?.concerns ?? const []).toSet();
  }

  Future<void> _save() async {
    final profile = SkinProfile(
      name: _name.text.trim().isEmpty ? null : _name.text.trim(),
      skinType: _type,
      age: int.tryParse(_age.text) ?? 22,
      goal: _goal,
      concerns: _concerns.toList(),
    );
    await LocalStore().saveProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Skin profile tersimpan ✨')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Skin Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Nama panggilan',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(controller: _name, decoration: const InputDecoration(hintText: 'Sarah')),
          const SizedBox(height: 16),
          Text('Usia',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '22'),
          ),
          const SizedBox(height: 16),
          Text('Jenis Kulit',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              for (final t in _types)
                PillChip(
                  label: t,
                  selected: _type == t,
                  onTap: () => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Concern',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              for (final c in _allConcerns)
                PillChip(
                  label: c,
                  selected: _concerns.contains(c),
                  onTap: () => setState(() {
                    if (_concerns.contains(c)) {
                      _concerns.remove(c);
                    } else {
                      _concerns.add(c);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Goal',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              for (final g in _goals)
                PillChip(
                  label: g,
                  selected: _goal == g,
                  onTap: () => setState(() => _goal = g),
                ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
