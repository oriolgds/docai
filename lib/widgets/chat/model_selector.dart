import 'package:flutter/material.dart';
import '../../models/model_profile.dart';
import '../../services/model_service.dart';
import '../../services/supabase_service.dart';
import '../../services/query_limit_service.dart';

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
  int? _remainingQueries;

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
        if (!currentModelExists) {
          // Priorizar modelo marcado como default
          final defaultModel = models.where((m) => m.isDefault).firstOrNull;
          if (defaultModel != null) {
            _profile = defaultModel;
          } else {
            // Fallback: priorizar modelo Doky
            final dokyModels = models.where((m) => m.provider == ModelProvider.doky && m.brand == BrandName.doky);
            _profile = dokyModels.isNotEmpty ? dokyModels.first : models.first;
          }
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
      // Priorizar modelo Doky
      final dokyModels = list.where((m) => m.provider == ModelProvider.doky);
      final p = dokyModels.isNotEmpty ? dokyModels.first : list.first;
      setState(() => _profile = p);
      widget.onSelected(p);
    }
  }

  void _selectProfile(ModelProfile p) {
    setState(() => _profile = p);
    widget.onSelected(p);
    if (p.provider == ModelProvider.modal) {
      _loadRemainingQueries();
    }
  }

  Future<void> _loadRemainingQueries() async {
    try {
      final remaining = await QueryLimitService.getRemainingQueries();
      if (mounted) {
        setState(() => _remainingQueries = remaining);
      }
    } catch (e) {
      // Silently fail
    }
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
    final dokyModels = _byBrand[BrandName.doky]?.where((p) => p.provider != ModelProvider.byok) ?? [];
    final byokBrandModels = _byBrand[BrandName.byok] ?? [];
    final byokModels = _byBrand.values.expand((models) => models.where((p) => p.provider == ModelProvider.byok)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modelos BYOK principales
        if (byokBrandModels.isNotEmpty) ...[
          const Text(
            'Modelos BYOK',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in byokBrandModels)
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
                        Text(p.displayName),
                        if (p.provider == ModelProvider.modal && _profile.id == p.id && _remainingQueries != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _remainingQueries! > 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_remainingQueries',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _remainingQueries! > 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ] else if (p.provider == ModelProvider.openrouter) ...[
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
                      ],
                    ),
                    selected: _profile.id == p.id,
                    onSelected: (_) => _selectProfile(p),
                    selectedColor: Colors.transparent,
                    checkmarkColor: p.primaryColor,
                    labelStyle: TextStyle(
                      color: _profile.id == p.id ? p.primaryColor : Colors.black,
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
          const SizedBox(height: 16),
        ],
        // Modelos Doky principales
        if (dokyModels.isNotEmpty) ...[
          const Text(
            'Modelos Doky',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in dokyModels)
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
                        Text(p.displayName),
                        if (p.provider == ModelProvider.modal && _profile.id == p.id && _remainingQueries != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _remainingQueries! > 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_remainingQueries',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _remainingQueries! > 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ] else if (p.provider == ModelProvider.openrouter) ...[
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
                      ],
                    ),
                    selected: _profile.id == p.id,
                    onSelected: (_) => _selectProfile(p),
                    selectedColor: Colors.transparent,
                    checkmarkColor: p.primaryColor,
                    labelStyle: TextStyle(
                      color: _profile.id == p.id ? p.primaryColor : Colors.black,
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
          const SizedBox(height: 16),
        ],

        // Modelos BYOK en accordion
        if (byokModels.isNotEmpty) ...[
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text(
              'Modelos BYOK',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in byokModels)
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
                            Text(p.displayName),
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
                          color: _profile.id == p.id ? p.primaryColor : Colors.black,
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
          ),
        ],
      ],
    );
  }
}
