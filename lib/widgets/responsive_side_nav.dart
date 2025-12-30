import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/models/medical_preset.dart';

class ResponsiveSideNav extends StatelessWidget {
  final int currentPageIndex;
  final bool isIncognito;
  final bool hasMessages;
  final bool hasHistory;
  final MedicalPreset selectedPreset;
  final Animation<double> menuRotationAnimation;
  final VoidCallback onNewChat;
  final VoidCallback onHistory;
  final VoidCallback onSettings;
  final VoidCallback onDeleteAll;
  final VoidCallback onPresetTap;
  final VoidCallback onIncognitoToggle;
  final VoidCallback onInfo;
  final VoidCallback onReports;
  final VoidCallback onMedicalProfile;
  final VoidCallback onMenuOpened;
  final VoidCallback onMenuCanceled;

  const ResponsiveSideNav({
    super.key,
    required this.currentPageIndex,
    required this.isIncognito,
    required this.hasMessages,
    required this.hasHistory,
    required this.selectedPreset,
    required this.menuRotationAnimation,
    required this.onNewChat,
    required this.onHistory,
    required this.onSettings,
    required this.onDeleteAll,
    required this.onPresetTap,
    required this.onIncognitoToggle,
    required this.onInfo,
    required this.onReports,
    required this.onMedicalProfile,
    required this.onMenuOpened,
    required this.onMenuCanceled,
  });

  String _getPresetName(BuildContext context, MedicalPreset preset) {
    final loc = AppLocalizations.of(context)!;
    switch (preset.id) {
      case 'general':
        return loc.presetGeneralName;
      case 'diagnostico':
        return loc.presetDiagnosisName;
      case 'sintomas':
        return loc.presetSymptomsName;
      case 'medicacion':
        return loc.presetMedicationName;
      case 'nutricion':
        return loc.presetNutritionName;
      case 'ejercicio':
        return loc.presetExerciseName;
      default:
        return preset.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive width based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isExtended = screenWidth > 900;
    final navWidth = isExtended
        ? 260.0
        : 80.0; // Slightly wider for better breathing room

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: navWidth,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo Area
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.green[400]!, Colors.teal[400]!],
            ).createShader(bounds),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isExtended
                  ? Row(
                      key: const ValueKey('logo_extended'),
                      children: [
                        const SizedBox(width: 24),
                        const Text(
                          'Doky',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          ' AI',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'D',
                      key: ValueKey('logo_compact'),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 32),

          // Primary Action: New Chat
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isExtended ? 16 : 12),
            child: _NewChatButton(
              isExtended: isExtended,
              onTap: onNewChat,
              label: localizations.chatNewConversation,
            ),
          ),

          const SizedBox(height: 24),

          // Presets Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isExtended ? 16 : 12),
            child: _PresetSelector(
              isExtended: isExtended,
              selectedPreset: selectedPreset,
              onTap: onPresetTap,
              presetName: _getPresetName(context, selectedPreset),
            ),
          ),

          const SizedBox(height: 24),

          // Navigation Items
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isExtended ? 16 : 12),
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.history_rounded,
                    label: localizations.menuHistory,
                    isExtended: isExtended,
                    isSelected: currentPageIndex == 1,
                    onTap: onHistory,
                  ),
                  const SizedBox(height: 8),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: localizations.menuSettings,
                    isExtended: isExtended,
                    isSelected: currentPageIndex == 2,
                    onTap: onSettings,
                  ),
                  if (currentPageIndex == 1 && hasHistory) ...[
                    const SizedBox(height: 24),
                    Divider(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    _NavItem(
                      icon: Icons.delete_outline_rounded,
                      label: localizations.deleteDialogConfirm,
                      isExtended: isExtended,
                      onTap: onDeleteAll,
                      textColor: Colors.red[400],
                      iconColor: Colors.red[400],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Actions
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isExtended ? 16 : 12,
              vertical: 16,
            ),
            child: Column(
              children: [
                if (currentPageIndex == 0)
                  _NavItem(
                    icon: isIncognito
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    label: isIncognito
                        ? localizations.incognitoOnTooltip
                        : localizations.incognitoOffTooltip,
                    isExtended: isExtended,
                    isSelected: isIncognito,
                    onTap: (!hasMessages) ? onIncognitoToggle : () {},
                    iconColor: isIncognito ? Colors.amber[700] : null,
                    textColor: isIncognito ? Colors.amber[700] : null,
                    tooltip: hasMessages
                        ? localizations.incognitoLockedTooltip
                        : (isIncognito
                              ? localizations.incognitoOnTooltip
                              : localizations.incognitoOffTooltip),
                  ),
                const SizedBox(height: 8),

                // Menu Button
                Align(
                  alignment: isExtended
                      ? Alignment.centerLeft
                      : Alignment.center,
                  child: PopupMenuButton<String>(
                    offset: const Offset(230, -100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    tooltip: localizations.menuTooltip,
                    onOpened: onMenuOpened,
                    onCanceled: onMenuCanceled,
                    onSelected: (value) async {
                      onMenuCanceled();
                      switch (value) {
                        case 'info':
                          onInfo();
                          break;
                        case 'settings':
                          onSettings();
                          break;
                        case 'reports':
                          onReports();
                          break;
                        case 'medical_profile':
                          onMedicalProfile();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'medical_profile',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.assignment_ind_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(localizations.medicalPreferencesTitle),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'settings',
                          child: Row(
                            children: [
                              const Icon(Icons.settings_outlined, size: 20),
                              const SizedBox(width: 12),
                              Text(localizations.menuSettings),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'info',
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, size: 20),
                              SizedBox(width: 12),
                              Text('Info'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'reports',
                          child: Row(
                            children: [
                              const Icon(Icons.flag_outlined, size: 20),
                              const SizedBox(width: 12),
                              Text(localizations.menuMyReports),
                            ],
                          ),
                        ),
                      ];
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: isExtended
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 12),
                          RotationTransition(
                            turns: menuRotationAnimation,
                            child: Icon(
                              Icons.more_vert_rounded,
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withValues(alpha: 0.7),
                            ),
                          ),
                          if (isExtended) ...[
                            const SizedBox(width: 12),
                            Text(
                              localizations.menuTooltip,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewChatButton extends StatefulWidget {
  final bool isExtended;
  final VoidCallback onTap;
  final String label;

  const _NewChatButton({
    required this.isExtended,
    required this.onTap,
    required this.label,
  });

  @override
  State<_NewChatButton> createState() => _NewChatButtonState();
}

class _NewChatButtonState extends State<_NewChatButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[500]!, Colors.teal[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: _isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: widget.isExtended
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: widget.isExtended ? 20 : 0),
                child: const Icon(
                  Icons.add_comment_rounded,
                  color: Colors.white,
                ),
              ),
              if (widget.isExtended) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetSelector extends StatelessWidget {
  final bool isExtended;
  final MedicalPreset selectedPreset;
  final VoidCallback onTap;
  final String presetName;

  const _PresetSelector({
    required this.isExtended,
    required this.selectedPreset,
    required this.onTap,
    required this.presetName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isExtended ? 64 : 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.15),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: isExtended
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Text(selectedPreset.emoji, style: const TextStyle(fontSize: 24)),
            if (isExtended) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Preset',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      presetName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Theme.of(context).disabledColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isExtended;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final String? tooltip;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isExtended,
    this.isSelected = false,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.tooltip,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveIconColor =
        widget.iconColor ??
        (widget.isSelected
            ? theme.colorScheme.primary
            : (isDark ? Colors.white70 : Colors.grey[600]));

    final effectiveTextColor =
        widget.textColor ??
        (widget.isSelected
            ? theme.colorScheme.primary
            : (isDark ? Colors.white : Colors.grey[800]));

    final bgColor = widget.isSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
        : (_isHovered
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100])
              : Colors.transparent);

    return Tooltip(
      message: widget.isExtended ? '' : (widget.tooltip ?? widget.label),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: widget.isExtended
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: effectiveIconColor, size: 24),
                if (widget.isExtended) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: effectiveTextColor,
                        fontWeight: widget.isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
