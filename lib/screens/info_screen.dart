import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/state/locale_scope.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static final Uri _twitterUri = Uri.parse('https://x.com/docaiapp');
  static final Uri _portfolioUri = Uri.parse('https://oriol.is-a.dev');
  static final Uri _projectSiteUri = Uri.parse('https://oriol.is-a.dev/docai');
  static final Uri _playStoreUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.oriolgds.doky',
  );
  static final Uri _suggestionsUri = Uri.parse('https://forms.gle/azsDBiNcDz4bGDTP9');

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
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0C1324),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          localizations.menuMoreInfo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF009688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0C1324), Color(0xFF061020)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          itemCount: items.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _LanguageSelectorCard(
                selectedLocale: selectedLocale,
                supportedLocales: supportedLocales,
                onLocaleChanged: (locale) {
                  if (locale == null) return;
                  localeController.updateLocale(locale);
                },
              );
            }

            final item = items[index - 1];
            final cardGradient = LinearGradient(
              colors: [item.startColor, item.endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

            return Container(
              decoration: BoxDecoration(
                gradient: cardGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: item.endColor.withValues(alpha: 0.35),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _openUrl(context, item.url),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            item.icon,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.open_in_new,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
    final launched = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );

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

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1DE9B6), Color(0xFF00B8A9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B8A9).withValues(alpha: 0.35),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizations.languageSelectorLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: selectedLocale,
                isExpanded: true,
                dropdownColor: const Color(0xFF0C1324),
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                onChanged: onLocaleChanged,
                items: supportedLocales.map((locale) {
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Text(
                      _languageName(localizations, locale),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
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
