import 'package:flutter/material.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class Wrw2025Screen extends StatefulWidget {
  const Wrw2025Screen({super.key});

  @override
  State<Wrw2025Screen> createState() => _Wrw2025ScreenState();
}

class _Wrw2025ScreenState extends State<Wrw2025Screen> {
  // FAQ expandable states
  bool faqExpanded1 = false;
  bool faqExpanded2 = false;
  bool faqExpanded3 = false;
  bool faqExpanded4 = false;
  bool faqExpanded5 = false;
  bool faqExpanded6 = false;
  bool faqExpanded7 = false;
  bool faqExpanded8 = false;

  static const List<String> _youtubeUrls = [
    "https://www.youtube.com/watch?v=H2b2HBm4Yik",
    "https://www.youtube.com/watch?v=DN5CQtM5-Lc",
    "https://www.youtube.com/watch?v=EOZN_pS5xy4",
    "https://www.youtube.com/watch?v=tUdc9GoS7_U",
    "https://www.youtube.com/watch?v=VhVhnQO3E2Y",
    "https://www.youtube.com/watch?v=MUguY8KCDIc",
    "https://www.youtube.com/watch?v=a6W8La9KXl8",
    "https://www.youtube.com/watch?v=SM5XonWUBxg",
    "https://www.youtube.com/watch?v=CIU5Ix-etHA",
    "https://www.youtube.com/watch?v=8WDRhcN7AUA",
    "https://www.youtube.com/watch?v=n8u5-AzTlwY",
    "https://www.youtube.com/watch?v=xGN5dz8y7y4",
    "https://www.youtube.com/watch?v=3dNC9KBl_ZY",
    "https://www.youtube.com/watch?v=PHZTEsdV1BA",
    "https://www.youtube.com/watch?v=8HxwqUWvkzM",
    "https://www.youtube.com/watch?v=kBFpsNiduoE",
    "https://www.youtube.com/watch?v=Th6cvWgr7cU",
    "https://www.youtube.com/watch?v=U6ADGRy7vlQ",
  ];

  static String? _extractYoutubeId(String url) {
    try {
      final uri = Uri.parse(url);

      if (uri.host.contains("youtu.be")) {
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        return (id != null && id.length > 11) ? id.substring(0, 11) : id;
      }

      if (uri.host.contains("youtube.com")) {
        final v = uri.queryParameters["v"];
        if (v != null && v.isNotEmpty) {
          return v.length > 11 ? v.substring(0, 11) : v;
        }

        if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == "shorts") {
          final id = uri.pathSegments.length >= 2 ? uri.pathSegments[1] : null;
          return (id != null && id.length > 11) ? id.substring(0, 11) : id;
        }

        if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == "live") {
          final id = uri.pathSegments.length >= 2 ? uri.pathSegments[1] : null;
          return (id != null && id.length > 11) ? id.substring(0, 11) : id;
        }
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  static List<String> _dedupeYoutubeUrls(List<String> urls) {
    final seen = <String>{};
    final out = <String>[];
    for (final url in urls) {
      final id = _extractYoutubeId(url);
      if (id == null || id.isEmpty) continue;
      if (seen.add(id)) out.add(url);
    }
    return out;
  }

  static String _youtubeThumbnailUrl(String url) {
    final id = _extractYoutubeId(url);
    if (id == null || id.isEmpty) return "";
    return "https://img.youtube.com/vi/$id/hqdefault.jpg";
  }

  // Responsive method to get crossAxisCount based on screen width
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) {
      return 2; // Mobile portrait
    } else if (screenWidth < 900) {
      return 3; // Tablet portrait
    } else if (screenWidth < 1200) {
      return 4; //tt Tablet landscape / Small desktop
    } else {
      return 5; // Large desktop
    }
  }

  // Responsive method to get aspect ratio
  double _getAspectRatio(double screenWidth) {
    if (screenWidth < 600) {
      return 16 / 11; // Mobile
    } else if (screenWidth < 900) {
      return 16 / 10; // Tablet
    } else {
      return 16 / 9; // Desktop
    }
  }

  // Responsive spacing
  double _getMainAxisSpacing(double screenWidth) {
    if (screenWidth < 600) {
      return 4;
    } else if (screenWidth < 900) {
      return 8;
    } else {
      return 12;
    }
  }

  double _getCrossAxisSpacing(double screenWidth) {
    if (screenWidth < 600) {
      return 4;
    } else if (screenWidth < 900) {
      return 8;
    } else {
      return 12;
    }
  }

  Widget _youtubeThumbCard({
    required String title,
    required String url,
    required double screenWidth,
  }) {
    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xfffff3d6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xfff1cd8f)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _getAspectRatio(screenWidth),
                    child: Image.network(
                      _youtubeThumbnailUrl(url),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image, size: 34),
                          ),
                    ),
                  ),
                  Container(
                    width: screenWidth < 600 ? 44 : 50,
                    height: screenWidth < 600 ? 44 : 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.45),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: screenWidth < 600 ? 28 : 32,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth < 600 ? 10 : 12,
                8,
                screenWidth < 600 ? 10 : 12,
                screenWidth < 600 ? 10 : 12,
              ),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth < 600 ? 14 : 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: "Health Awareness – 2025"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                articleSection(screenWidth),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 📰 Article Section
  Widget articleSection(double screenWidth) {
    final youtubeUrls = _dedupeYoutubeUrls(_youtubeUrls);
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final mainAxisSpacing = _getMainAxisSpacing(screenWidth);
    final crossAxisSpacing = _getCrossAxisSpacing(screenWidth);

    return Padding(
      padding: EdgeInsets.all(screenWidth < 600 ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFAQSection(),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: youtubeUrls.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              crossAxisCount: crossAxisCount,
              childAspectRatio: _getAspectRatio(screenWidth),
            ),
            itemBuilder: (context, index) {
              final url = youtubeUrls[index];
              return _youtubeThumbCard(
                title: "Session ${index + 1}",
                url: url,
                screenWidth: screenWidth,
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // FAQ Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFAQItem(
                  index: 1,
                  question:
                      "JIN Reflexology Day to International Yoga Day\n\nIndia's Biggest Health Awareness Campaign",
                  answer:
                      '''Lokmat News – Health awareness seminars conclude. Seminars organized in 9 cities across 7 states, training provided in self-treatment.

Health Awareness + Self Treatment Training Program theoretical and practical supported by Arihant North Town Owners and Residents Welfare Association, International Reflexology JIN Association in the closing ceremony of JIN Reflexology Day every year, JR Anil Jain, Inventor of JIN Reflexology, JR Harshit Jain, JR Rishabh Jain, Vice President of Mahavir International Vir Ghyanchand Kothari and others.

Lokmat News Service, Chhatrapati Sambhajinagar: International Reflexology JIN Association organizes various health awareness programs every year from JIN Reflexology Day on June 1 to International Yoga Day on June 21, which has become India's biggest health awareness campaign.

In the same series, this year, from June 1 to June 21, in these 21 days, 20 highly inspiring health awareness and life-changing seminars were organized in 19 cities, which concluded on June 29.

Mahavir International North Town Center organized a two-day health awareness and self-treatment training camp through JIN Reflexology in the clubhouse premises, which concluded with great joy.

Coordinator of this campaign and keynote speaker JR Anil Jain, Inventor of JIN Reflexology, while explaining the specialty of JIN Reflexology, said that there are more than 200 medical systems available in the world. Among them, after Ayurveda, which accurately diagnoses diseases, reflexology is the only medical system in the world in which the patient is not asked a single question and the patient is informed about all his or her problems.

There is a great need for health awareness seminars these days. Non-communicable diseases account for 61 percent of deaths in India each year. No such work is being done nationwide to prevent them.

After conducting research on thousands of patients, it was concluded that the root cause of any major illness, whether it's a heart attack, kidney failure, spondylitis or Parkinson's, is a chaotic lifestyle.

These seminars were organized to prevent future serious illnesses and bring beautiful smiles to people's faces. All attendees at these two-hour seminars were given the opportunity to practice healthy eating habits.

It was explained in a very simple and effective manner that by making some necessary changes in our daily lifestyle, we can not only achieve good health but can also live a mentally calm and stress-free life.

Over the past five years, 144 seminars in this series of health seminars have been organized through major institutions across the country. Reflexology, a healthy lifestyle, and the key life-changing factors were explained through computerized power presentations, and questions were also addressed. This has already brought positive change to the lives of millions of people.

This massive campaign was launched five years ago under the guidance of Lokmat Group Editor-in-Chief Rajendra Darda. Lokmat, as the media partner, is playing a crucial role in disseminating it to the masses. Rajendra Darda was instrumental in making the 21-day program a success and systematically implementing all the initiatives.

JIN REFLEXOLOGY DAY 1st JUNE HEALTHY & NATURAL LIFE

Media Partner:
Lokmat, Lokmat Samachar, Lokmat Times

Along with Honorable Rajendra Babuji Darda, Prof. PB Lohia, Vimal Bafna, JR Harshit Jain, JR Rishabh Jain, JR Anand Chopra, Mahavir Banthia, Lalit Gandhi etc. had important contributions.

Mahavir International's International Vice President Ghyanchand Kothari, Mahavir Sabdada, Shantilal Chaudhary, Ramesh Nahata, and Budhprakash Doshi contributed to the successful closing ceremony.

This year, for 21 days, every day from 8 to 9 pm, speeches from experts on various health-related topics were also presented on the JIN Reflexology YouTube and Facebook channels.

Based on those speeches, on July 11th, a "Gyan Badhao" contest has also been organized, in which five questions will be asked. The first three contestants to answer correctly will be awarded prizes.

Use the following link to join this campaign.

Your Healthy Life Is Our Priority.''',
                  isExpanded: faqExpanded1,
                  onTap: () => setState(() => faqExpanded1 = !faqExpanded1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// FAQ Item Builder
  Widget _buildFAQItem({
    required int index,
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color:
            isExpanded
                ? const Color(0xFFFFF6B0).withOpacity(0.3)
                : Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A3EB5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        index.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            isExpanded
                                ? const Color(0xFF6A3EB5)
                                : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF6A3EB5),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                answer,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
        ],
      ),
    );
  }
}