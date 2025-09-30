import 'package:flutter/material.dart';

class ThemeCustomizerWidget extends StatefulWidget {
  const ThemeCustomizerWidget({super.key});

  @override
  State<ThemeCustomizerWidget> createState() => _ThemeCustomizerWidgetState();
}

class _ThemeCustomizerWidgetState extends State<ThemeCustomizerWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool isDarkMode = false;
  bool isCompactMode = true;
  bool showAnimations = true;
  int selectedAccentColor = 0;
  double fontSize = 14.0;
  
  final List<Color> accentColors = [
    const Color(0xFF2E7D32), // Verde médico
    const Color(0xFF6C5CE7), // Púrpura
    const Color(0xFF00B894), // Verde agua
    const Color(0xFFE17055), // Naranja
    const Color(0xFFE84393), // Rosa
    const Color(0xFF00CEC9), // Turquesa
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildThemeOptions(),
                const SizedBox(height: 20),
                _buildAccentColorPicker(),
                const SizedBox(height: 20),
                _buildFontSizeSlider(),
                const SizedBox(height: 20),
                _buildPreferencesToggle(),
                const SizedBox(height: 24),
                _buildPreviewCard(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColors[selectedAccentColor], accentColors[selectedAccentColor].withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.palette_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personalizar tema',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
              ),
              Text(
                'Configura la apariencia de DocAI',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C757D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tema',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildThemeOption(
                'Claro',
                Icons.light_mode,
                !isDarkMode,
                () => setState(() => isDarkMode = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildThemeOption(
                'Oscuro',
                Icons.dark_mode,
                isDarkMode,
                () => setState(() => isDarkMode = true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColors[selectedAccentColor].withOpacity(0.1) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColors[selectedAccentColor] : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? accentColors[selectedAccentColor] : const Color(0xFF6C757D),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? accentColors[selectedAccentColor] : const Color(0xFF6C757D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color principal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: accentColors.asMap().entries.map((entry) {
            final index = entry.key;
            final color = entry.value;
            final isSelected = selectedAccentColor == index;
            
            return GestureDetector(
              onTap: () => setState(() => selectedAccentColor = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: isSelected ? 12 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tamaño de fuente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColors[selectedAccentColor].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${fontSize.toInt()}px',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentColors[selectedAccentColor],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: accentColors[selectedAccentColor],
            inactiveTrackColor: accentColors[selectedAccentColor].withOpacity(0.2),
            thumbColor: accentColors[selectedAccentColor],
            overlayColor: accentColors[selectedAccentColor].withOpacity(0.1),
          ),
          child: Slider(
            value: fontSize,
            min: 12.0,
            max: 18.0,
            divisions: 6,
            onChanged: (value) => setState(() => fontSize = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesToggle() {
    return Column(
      children: [
        _buildToggleItem(
          'Modo compacto',
          'Interfaz más densa con menos espaciado',
          Icons.compress,
          isCompactMode,
          (value) => setState(() => isCompactMode = value),
        ),
        const SizedBox(height: 12),
        _buildToggleItem(
          'Animaciones',
          'Efectos visuales y transiciones',
          Icons.auto_awesome,
          showAnimations,
          (value) => setState(() => showAnimations = value),
        ),
      ],
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: accentColors[selectedAccentColor],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: accentColors[selectedAccentColor],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3436) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColors[selectedAccentColor].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColors[selectedAccentColor],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.preview,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Vista previa',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Así se verá la aplicación con tus configuraciones personalizadas.',
            style: TextStyle(
              fontSize: fontSize - 2,
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.8)
                  : const Color(0xFF6C757D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: accentColors[selectedAccentColor]),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: accentColors[selectedAccentColor],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              // Aquí aplicarías los cambios de tema
              _applyThemeChanges();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColors[selectedAccentColor],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Aplicar cambios',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _applyThemeChanges() {
    // Aquí implementarías la lógica para aplicar los cambios de tema
    // Por ejemplo, guardando en SharedPreferences o notificando al provider de tema
    debugPrint('Aplicando cambios de tema:');
    debugPrint('Modo oscuro: $isDarkMode');
    debugPrint('Color principal: ${accentColors[selectedAccentColor]}');
    debugPrint('Tamaño de fuente: $fontSize');
    debugPrint('Modo compacto: $isCompactMode');
    debugPrint('Animaciones: $showAnimations');
  }
}