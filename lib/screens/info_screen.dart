import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/state/locale_scope.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:docai/widgets/smooth_scroll.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static final Uri _twitterUri = Uri.parse('https://x.com/docaiapp');
  static final Uri _portfolioUri = Uri.parse('https://oriol.is-a.dev');
  static final Uri _projectSiteUri = Uri.parse('https://oriol.is-a.dev/docai');
  static final Uri _playStoreUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.oriolgds.doky',
  );
  static final Uri _suggestionsUri = Uri.parse(
    'https://forms.gle/azsDBiNcDz4bGDTP9',
  );

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeController = LocaleScope.of(context);
    final supportedLocales = AppLocalizations.supportedLocales;
    final resolvedLocale = _findLocaleMatch(
      localeController.locale ?? Localizations.localeOf(context),
      supportedLocales,
    );
    final selectedLocale = _findLocaleMatch(resolvedLocale, supportedLocales);

    final items = [
      _InfoItem(
        icon: Icons.alternate_email,
        title: localizations.menuTwitter,
        subtitle: localizations.infoTwitterSubtitle,
        url: _twitterUri,
        startColor: const Color(0xFF00C853),
        endColor: const Color(0xFF009688),
      ),
      _InfoItem(
        icon: Icons.work_outline,
        title: localizations.menuPortfolio,
        subtitle: localizations.infoPortfolioSubtitle,
        url: _portfolioUri,
        startColor: const Color(0xFF1DE9B6),
        endColor: const Color(0xFF00B8A9),
      ),
      _InfoItem(
        icon: Icons.public,
        title: localizations.menuProjectSite,
        subtitle: localizations.infoProjectSiteSubtitle,
        url: _projectSiteUri,
        startColor: const Color(0xFF00E5FF),
        endColor: const Color(0xFF00BFA5),
      ),
      if (Theme.of(context).platform != TargetPlatform.windows)
        _InfoItem(
          icon: Icons.shop_outlined,
          title: localizations.menuPlayStore,
          subtitle: localizations.infoPlayStoreSubtitle,
          url: _playStoreUri,
          startColor: const Color(0xFF1DE9B6),
          endColor: const Color(0xFF00C853),
        ),
      _InfoItem(
        icon: Icons.feedback_outlined,
        title: localizations.menuSuggestions,
        subtitle: localizations.infoSuggestionsSubtitle,
        url: _suggestionsUri,
        startColor: const Color(0xFF00E676),
        endColor: const Color(0xFF00C853),
      ),
      if (Theme.of(context).platform == TargetPlatform.android ||
          Theme.of(context).platform == TargetPlatform.iOS)
        _InfoItem(
          icon: Icons.desktop_windows,
          title: localizations.menuWindowsStore,
          subtitle: localizations.infoWindowsStoreSubtitle,
          url: Uri.parse('https://apps.microsoft.com/detail/9NBDMWZFNB6K'),
          startColor: const Color(0xFF0078D7),
          endColor: const Color(0xFF00A4EF),
        ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          localizations.menuMoreInfo,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final crossAxisCount = isWide ? 2 : 1;

              return SmoothScroll(
                controller: _scrollController,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _LanguageSelectorCard(
                          selectedLocale: selectedLocale,
                          supportedLocales: supportedLocales,
                          onLocaleChanged: (locale) {
                            if (locale == null) return;
                            localeController.updateLocale(locale);
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    sliver: isWide
                        ? SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 3.5,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = items[index];
                              return _InfoCard(
                                item: item,
                                onTap: () => _openUrl(context, item.url),
                              );
                            }, childCount: items.length),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = items[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _InfoCard(
                                  item: item,
                                  onTap: () => _openUrl(context, item.url),
                                ),
                              );
                            }, childCount: items.length),
                          ),
                  ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Center(
                          child: FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }
                              final version = snapshot.data!;
                              return Text(
                                localizations.versionDisplay(version.version),
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Locale _findLocaleMatch(Locale target, List<Locale> options) {
    return options.firstWhere(
      (locale) => locale.languageCode == target.languageCode,
      orElse: () => options.first,
    );
  }

  Future<void> _openUrl(BuildContext context, Uri url) async {
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.linkOpenError)),
      );
    }
  }
}

class _LanguageSelectorCard extends StatelessWidget {
  const _LanguageSelectorCard({
    required this.selectedLocale,
    required this.supportedLocales,
    required this.onLocaleChanged,
  });

  final Locale selectedLocale;
  final List<Locale> supportedLocales;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.language, color: borderColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    localizations.languageSelectorLabel,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: supportedLocales.map((locale) {
                final isSelected = locale == selectedLocale;
                return _LanguageChip(
                  label: _languageName(localizations, locale),
                  isSelected: isSelected,
                  onTap: () => onLocaleChanged(locale),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _languageName(AppLocalizations localizations, Locale locale) {
    switch (locale.languageCode) {
      case 'ca':
        return localizations.languageCatalan;
      case 'de':
        return localizations.languageGerman;
      case 'es':
        return localizations.languageSpanish;
      case 'fr':
        return localizations.languageFrench;
      case 'en':
      default:
        return localizations.languageEnglish;
    }
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final backgroundColor = isSelected
        ? primaryColor
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]!);

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.grey[300] : Colors.grey[800]);

    final borderColor = isSelected
        ? primaryColor
        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.startColor,
    required this.endColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Uri url;
  final Color startColor;
  final Color endColor;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item, required this.onTap});

  final _InfoItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final textColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey[200]!,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item.startColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.startColor, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: subtitleColor!.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
