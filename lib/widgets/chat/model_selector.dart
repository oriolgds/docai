import 'package:flutter/material.dart';
import '../../models/model_profile.dart';

class ModelSelector extends StatefulWidget {
  final ModelProfile selected;
  final ValueChanged<ModelProfile> onSelected;

  const ModelSelector({super.key, required this.selected, required this.onSelected});

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  late BrandName _brand;
  late ModelProfile _profile;
  late final Map<BrandName, List<ModelProfile>> _byBrand;

  @override
  void initState() {
    super.initState();
    _byBrand = ModelProfile.groupedByBrand();
    _profile = widget.selected;
    _brand = _profile.brand;
    // Ensure current brand exists; otherwise pick the first available
    if (!_byBrand.containsKey(_brand) || (_byBrand[_brand]?.isEmpty ?? true)) {
      if (_byBrand.isNotEmpty) {
        _brand = _byBrand.keys.first;
        _profile = _byBrand[_brand]!.first;
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSelected(_profile));
      }
    }
  }

  void _selectBrand(BrandName b) {
    setState(() => _brand = b);
    final list = _byBrand[b] ?? [];
    if (list.isNotEmpty) {
      final p = list.first;
      setState(() => _profile = p);
      widget.onSelected(p);
    }
  }

  void _selectProfile(ModelProfile p) {
    setState(() => _profile = p);
    widget.onSelected(p);
  }

  @override
  Widget build(BuildContext context) {
    final brands = _byBrand.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 4),
              for (final b in brands)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    selected: _brand == b,
                    label: Text(brandDisplayName(b)),
                    selectedColor: brandColor(b).withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: _brand == b ? brandColor(b) : Colors.black,
                      fontWeight: _brand == b ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) => _selectBrand(b),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: brandColor(b).withOpacity(0.35)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in (_byBrand[_brand] ?? []))
              FilterChip(
                label: Text(p.tier),
                selected: _profile.id == p.id,
                onSelected: (_) => _selectProfile(p),
                selectedColor: brandColor(_brand).withOpacity(0.15),
                checkmarkColor: brandColor(_brand),
                labelStyle: TextStyle(
                  color: _profile.id == p.id ? brandColor(_brand) : Colors.black,
                  fontWeight: _profile.id == p.id ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: brandColor(_brand).withOpacity(0.35)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
