import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:docai/l10n/app_localizations.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final articles = [
      _Article(
        title: "Understanding Your Cycle",
        content: """
# The Menstrual Cycle

The menstrual cycle is the monthly series of changes a woman's body goes through in preparation for the possibility of pregnancy. Each month, one of the ovaries releases an egg — a process called ovulation. At the same time, hormonal changes prepare the uterus for pregnancy.

## Phases of the Menstrual Cycle

1. **Menstruation:** The elimination of the thickened lining of the uterus (endometrium) from the body through the vagina.
2. **Follicular Phase:** Starts on the first day of menstruation and ends with ovulation. The pituitary gland releases follicle stimulating hormone (FSH).
3. **Ovulation:** The release of a mature egg from the surface of the ovary. This usually occurs mid-cycle, around day 14 of a 28-day cycle.
4. **Luteal Phase:** After ovulation, the ruptured follicle stays on the surface of the ovary and turns into the corpus luteum, which releases progesterone.
        """,
      ),
      _Article(
        title: "Signs of Ovulation",
        content: """
# Detecting Ovulation

Recognizing the signs of ovulation can help you identify your most fertile days.

## Key Signs

- **Cervical Mucus Changes:** Just before ovulation, you might notice an increase in clear, wet, and stretchy vaginal secretions.
- **Basal Body Temperature (BBT):** Your resting body temperature increases slightly during ovulation.
- **Ovulation Pain:** Some women experience a slight twinge of pain or cramps on one side of the lower abdomen.
        """,
      ),
      _Article(
        title: "Managing PMS Symptoms",
        content: """
# Premenstrual Syndrome (PMS)

PMS has a wide variety of signs and symptoms, including mood swings, tender breasts, food cravings, fatigue, irritability and depression.

## Tips for Relief

- **Exercise:** Regular physical activity can help alleviate symptoms.
- **Diet:** Eat smaller, more frequent meals to reduce bloating. Limit salt and salty foods.
- **Sleep:** Get plenty of sleep.
- **Stress Reduction:** Try yoga or massage to relax and relieve stress.
        """,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            title: Text(
              article.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            leading: Icon(Icons.article_outlined, color: Theme.of(context).primaryColor),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: MarkdownBody(
                  data: article.content,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Article {
  final String title;
  final String content;

  _Article({required this.title, required this.content});
}
