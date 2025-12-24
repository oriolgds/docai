import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/state/locale_scope.dart';
import 'package:docai/services/app_haptics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

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

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
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
        onTap: () {
          AppHaptics.selectionClick(context);
          onTap();
        },
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
