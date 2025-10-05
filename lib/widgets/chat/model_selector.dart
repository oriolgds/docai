import 'package:flutter/material.dart';
import '../../models/model_profile.dart';
import '../../services/model_service.dart';
import '../../services/supabase_service.dart';

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
  Map<BrandName, List<ModelProfile>> _byBrand = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasByok = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.selected;
    _brand = _profile.brand;
    _loadModels();
    _checkByokStatus();
  }
  
  Future<void> _loadModels() async {
    try {
      final models = await ModelService.getAvailableModels();
      if (models.isEmpty) {
        setState(() {
          _errorMessage = 'No hay modelos disponibles';
          _isLoading = false;
        });
        return;
      }

      final grouped = <BrandName, List<ModelProfile>>{};
      for (final model in models) {
        grouped.putIfAbsent(model.brand, () => []).add(model);
      }

      setState(() {
        _byBrand = grouped;
        _isLoading = false;
        _errorMessage = null;

        // Verificar si el modelo actual sigue disponible
        final currentModelExists = models.any((m) => m.id == _profile.id);
        if (!currentModelExists && models.isNotEmpty) {
          _profile = models.first;
          _brand = _profile.brand;
          WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSelected(_profile));
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando modelos';
        _isLoading = false;
        _byBrand = ModelProfile.groupedByBrand(); // Fallback
      });
    }
  }

  Future<void> _checkByokStatus() async {
    try {
      final hasByok = await SupabaseService.hasUserApiKey('openrouter');
      if (mounted) {
        setState(() {
          _hasByok = hasByok;
        });
      }
    } catch (e) {
      // Silently fail - not critical
      if (mounted) {
        setState(() {
          _hasByok = false;
        });
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
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadModels();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
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
              Container(
                decoration: BoxDecoration(
                  gradient: _profile.id == p.id ? LinearGradient(
                    colors: [p.primaryColor.withOpacity(0.1), p.secondaryColor.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ) : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_hasByok ? p.displayName : '${p.displayName} (Requiere API Key)'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B894).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.vpn_key,
                              size: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'BYOK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  selected: _profile.id == p.id,
                  onSelected: (_) => _selectProfile(p),
                  selectedColor: Colors.transparent,
                  checkmarkColor: p.primaryColor,
                  labelStyle: TextStyle(
                    color: _profile.id == p.id ? p.primaryColor : (_hasByok ? Colors.black : Colors.grey),
                    fontWeight: _profile.id == p.id ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: p.primaryColor.withOpacity(0.35)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
