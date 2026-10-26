import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:jin_reflex_new/screens/health_campaign_pdf_screen.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class Wrw2020Screen extends ConsumerStatefulWidget {
  const Wrw2020Screen({super.key});

  static const String _conferenceImageUrl =
      "https://jinreflexology.in/wp-content/uploads/2024/10/IRJA-Jain-Conference.jpg";

  static const List<String> _youtubeUrls = [
    "https://www.youtube.com/watch?v=FEaAQsHvbOY",
    "https://www.youtube.com/watch?v=hwWY5sS6LRs",
    "https://www.youtube.com/watch?v=nBX5Rn0bAic&t=1s",
    "https://www.youtube.com/watch?v=THWDNplvlb8",
    "https://www.youtube.com/watch?v=a64ytxY7v_E",
    "https://www.youtube.com/watch?v=DhsnuE7ZAS8",
    "https://www.youtube.com/watch?v=x-0nZ3Nlhw0",
    "https://www.youtube.com/watch?v=j_NTZbxGHyY",
    "https://www.youtube.com/watch?v=j_NTZbxGHyY",
    "https://www.youtube.com/watch?v=Vea9oZd0vjI",
    "https://www.youtube.com/watch?v=aT43C7dCGWo",
    "https://www.youtube.com/watch?v=w9EcQ7yHLJs",
    "https://www.youtube.com/watch?v=aBEosDKToW4",
    "https://www.youtube.com/watch?v=Qj2A-yahPuc",
    "https://www.youtube.com/watch?v=XTWrGo-Vn_E",
    "https://www.youtube.com/watch?v=8Dk-aNdi7YY",
    "https://www.youtube.com/watch?v=1cmtyffjuAs",
    "https://www.youtube.com/watch?v=MiXxrjxtR08",
    "https://www.youtube.com/watch?v=VSN4iPLTiMU",
    "https://www.youtube.com/watch?v=dagajD_XqU0",
    "https://www.youtube.com/watch?v=gceYwxYrc14",
    "https://www.youtube.com/watch?v=Vo1VWDDw4B8",
    "https://www.youtube.com/watch?v=gIcwE6MOF7g",
    "https://www.youtube.com/watch?v=JYDejjO8m8k&t=4s",
    "https://www.youtube.com/watch?v=PREUwuzI6ug",
    "https://www.youtube.com/watch?v=EVsRmeIsaSI",
    "https://www.youtube.com/watch?v=EYJCA8wDr8I",
    "https://www.youtube.com/watch?v=EYJCA8wDr8I",
    "https://www.youtube.com/watch?v=n8K1em0oW2c",
    "https://www.youtube.com/watch?v=jD-DrV-ReKE",
    "https://www.youtube.com/watch?v=vCOdo3TUbzY",
    "https://www.youtube.com/watch?v=WimcT34Dtkg",
    "https://www.youtube.com/watch?v=qRzjDn6tQ2s",
    "https://www.youtube.com/watch?v=sG5KZ5nFeB0",
    "https://www.youtube.com/watch?v=pq9N0Kg9ZKs",
    "https://www.youtube.com/watch?v=pq9N0Kg9ZKs",
    "https://www.youtube.com/watch?v=x8eWfes7A7M",
    "https://www.youtube.com/watch?v=4As9nhRb3Nw",
    "https://www.youtube.com/watch?v=pq_E05oT-aY",
    "https://www.youtube.com/watch?v=ZB76xY0gW9Q",
  ];

  static String? _extractYoutubeId(String url) {
    try {
      final uri = Uri.parse(url);

      if (uri.host.contains("youtu.be")) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }

      if (uri.host.contains("youtube.com")) {
        if (uri.queryParameters.containsKey("v")) {
          return uri.queryParameters["v"];
        }
        if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == "shorts") {
          return uri.pathSegments.length >= 2 ? uri.pathSegments[1] : null;
        }
        if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == "live") {
          return uri.pathSegments.length >= 2 ? uri.pathSegments[1] : null;
        }
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  static String _youtubeThumbnailUrl(String url) {
    final id = _extractYoutubeId(url);
    if (id == null || id.isEmpty) return "";
    return "https://img.youtube.com/vi/$id/hqdefault.jpg";
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Widget sectionTitle(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFFF6B0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  static Widget buildRow(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.all(10),
            color: const Color(0xFFF9F9F9),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ConsumerState<Wrw2020Screen> createState() => _Wrw2020ScreenState();
}

class _Wrw2020ScreenState extends ConsumerState<Wrw2020Screen> {
  // FAQ expandable states
  bool faqExpanded1 = false;
  bool faqExpanded2 = false;
  bool faqExpanded3 = false;
  bool faqExpanded4 = false;

  @override
  Widget build(BuildContext context) {
    // Filter out null/invalid video URLs
    final validUrls =
        Wrw2020Screen._youtubeUrls.where((url) {
          final id = Wrw2020Screen._extractYoutubeId(url);

          // Remove if video ID is null or empty
          if (id == null || id.isEmpty) {
            return false;
          }

          return true;
        }).toList();

    // Debug: Print all valid video IDs
    for (int i = 0; i < validUrls.length; i++) {
      final id = Wrw2020Screen._extractYoutubeId(validUrls[i]);
      debugPrint('Valid Video ${i + 1} => $id');
    }

    return Scaffold(
      appBar: CommonAppBar(title: "WRW - 2020"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// Conference Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () => _openExternal(Wrw2020Screen._conferenceImageUrl),
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    Wrw2020Screen._conferenceImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Text("Image failed to load"),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// FAQ Section
            _buildFAQSection(),

            /// YouTube Videos Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    "YouTube Videos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${validUrls.length})", // Shows only valid videos count
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: validUrls.length, // Use validUrls length
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 15,
                  childAspectRatio: 18 / 15,
                ),
                itemBuilder: (context, index) {
                  final url = validUrls[index]; // Use validUrls
                  final videoId = Wrw2020Screen._extractYoutubeId(url);

                  return InkWell(
                    onTap: () => _openExternal(url),
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: const Color(0xfffff3d6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xfff1cd8f)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    "https://img.youtube.com/vi/$videoId/hqdefault.jpg",
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 34,
                                          ),
                                        ),
                                  ),
                                ),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.45),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                            child: Text(
                              "Video ${index + 1}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            /// Main Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF6A3EB5),
              child: const Text(
                "World Reflexology Week - 21st September to 27th September , 2020",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            Wrw2020Screen.buildRow("Convenor", "JR Anil Jain"),
            Wrw2020Screen.buildRow(
              "Advisory Member",
              "Dr. Cyril Antony, Dr. Arve Fahlvik, Prof. P.B. Lohiya, Dr. Sarvdeo Prasad Gupta, Dr. Eduardo Louis",
            ),
            Wrw2020Screen.sectionTitle(
              "WRW Inaugural Function - World Reflexology Week Nationwide Free Treatment Mega Event",
            ),
            Wrw2020Screen.buildRow("Date", "21st September 2020"),
            Wrw2020Screen.buildRow(
              "Guest",
              "Hon. Rajendra Babuji Darda (Editor in Chief - Lokmat)",
            ),
            Wrw2020Screen.buildRow("City", "Aurangabad, Online"),
            Wrw2020Screen.buildRow(
              "Organizer",
              "International Reflexology JIN Association",
            ),
            Wrw2020Screen.sectionTitle(
              "WRW Concluding Function - National Conference and Award Presentation Ceremony - 2020",
            ),
            Wrw2020Screen.buildRow("Date", "27th September 2020"),
            Wrw2020Screen.buildRow(
              "Guest",
              "Dr. Cyril Antony, Dr. Arve Fahlvik, Prof. P.B. Lohiya",
            ),
            Wrw2020Screen.buildRow("City", "Aurangabad, Maharashtra, India"),
            Wrw2020Screen.buildRow(
              "Organizer",
              "International Reflexology JIN Association",
            ),
            Wrw2020Screen.buildRow(
              "Supported",
              "JIN Reflexology, Jain Chumbak",
            ),
            Wrw2020Screen.buildRow(
              "Media Partner",
              "Lokmat (Maharashtra's No.1 Newspaper)",
            ),
            const SizedBox(height: 20),

            /// PDF Section
            const Text(
              "2020 Glimpses PDF",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 560,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const HealthCampaignScreen(initialYear: 2020),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ❓ FAQ Section Widget
  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          // FAQ Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF6A3EB5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.help_outline, color: Colors.yellow, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Frequently Asked Questions (FAQs) - WRW 2020",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FAQ Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _buildFAQItem(
                  index: 1,
                  question:
                      "JIN REFLEXOLOGY Day Mega Event – Free Online Yoga & Interaction Camp",
                  answer:
                      """21-day yoga camp and discussion session.

Mrs. Neeta Babel Jain, Provincial General Secretary, Rajasthan Women's Branch:

"If the mind loses, it is defeat; if the mind wins, it is victory. If you accept defeat, it is defeat; if you decide to win, it is victory."

Hearty congratulations to everyone on the occasion of 21st June – International Yoga Day.

Currently, we all share one common goal: overcoming the coronavirus pandemic. Yoga has proven to be a powerful tool for physical and mental well-being during this difficult time. Keeping this in mind, the All India Shwetambar Sthanakavasi Jain Conference organized yoga and discussion sessions from International Reflexology Day to International Yoga Day. Millions of people participated in this successful initiative.

Under the leadership of respected Rajendra Babuji Darda, Chief Editor of Lokmat, special thanks to National President Parasji Modi Jain, National Women President Vimal Bafna Jain, and JR Anil Jain, Inventor of JIN Reflexology, for this Healthy India campaign.

Yoga expert Manjuji Thole helped participants remove lethargy and build new energy through simple yet effective yoga sessions. She is a certified yoga teacher from The Fit Way and has been conducting power yoga sessions for the last ten years.

The sessions included:
• Warm-up exercises  
• Sitting exercises using belts and dupattas  
• Lower and upper body exercises  
• Cardio exercises using chairs and props  
• Surya Namaskar variations  
• Walking and jumping exercises  
• Pranayama and clapping therapy  

Participants were advised to clap 100–200 times daily for acupressure benefits. The 21-day session helped strengthen immunity during the COVID-19 pandemic.

JR Anil Jain explained stress-free and drug-free living through JIN Reflexology techniques. Vimalji Bafna Jain explained various mudras including Meditation Mudra, Akash Mudra, Prithvi Mudra, Surya Mudra, and Vayu Mudra.

Experts also shared knowledge on:
• Water therapy  
• Sujok therapy  
• Color therapy  
• Diet and nutrition  
• Acupressure  
• Naturopathy  
• Reiki healing  
• Breath energy and pranayama  
• Mud therapy and Panch Tatva  

The online Zoom meeting held on Yoga Day honored all experts and participants. Dr. Balaji Thambe emphasized environmental purity and healthy living.

National Working President Shri Balchandji Kharvad Jain praised Vimalji Bafna Jain for her dedication and leadership in making the event successful.

The 21-day session became a memorable journey toward health, positivity, and discipline.

"Jai Jinendra."""
                      "",
                  isExpanded: faqExpanded1,
                  onTap: () => setState(() => faqExpanded1 = !faqExpanded1),
                ),
                _buildFAQItem(
                  index: 2,
                  question:
                      "Five and a Half Thousand People Joined Online on the First Day",
                  answer:
                      """Online Yoga Camp on JIN Reflexology Day to International Yoga Day.

Lokmat News – Aurangabad, June 2:

On the very first day of the online yoga camp, more than 5,500 people from across the country joined and benefited from yoga sessions and health guidance.

The program was organized jointly by:
• All India Shwetambar Sthanakavasi Jain Conference Women's Branch, New Delhi  
• International Reflexology Jain Association  

The sessions were conducted daily from June 1st to June 21st.

JR Anil Jain, Inventor of JIN Reflexology, stated that participation increased rapidly. On the second day alone, participation crossed 40,000 people.

The sessions included:
• Yoga practice  
• Water therapy guidance  
• Pulse-based health awareness  
• Immunity improvement techniques  

Yoga expert Dr. Mohan Kalburgi explained:
• Importance of maintaining water balance  
• Drinking water according to body pulse  
• Benefits of Chandra Nadi while drinking water  

The event was broadcast live on:
• YouTube  
• Instagram  

The camp aimed to:
• Increase immunity  
• Spread awareness about yoga  
• Promote healthy living  

Yoga sessions were held daily from 7:00 AM to 8:00 AM for 21 days, followed by health awareness discussions.""",
                  isExpanded: faqExpanded2,
                  onTap: () => setState(() => faqExpanded2 = !faqExpanded2),
                ),
                _buildFAQItem(
                  index: 3,
                  question:
                      "7th National Conference and 2nd International Conference",
                  answer:
                      """International Reflexology Week – Online Discussions and Meetings Organized.

An online meeting of the International Reflexology Week Planning Committee was conducted to organize this year's activities from home.

The major activities included:
• Free treatment campaigns  
• 7th National Conference – September 25  
• 2nd International Conference – September 26  

International Reflexology Week is celebrated every year during the last week of September.

From September 20th to 26th:
• Free treatment camps  
• Training programs  
• Awareness sessions  

were organized across the country.

Therapies included:
• Acupressure  
• Reflexology  
• Sujok  
• Shiatsu  
• JIN Reflexology  
• Neurotherapy  
• Acupuncture  

Doctors and practitioners provided free treatment daily for two hours at their centers.

The campaign was started under the guidance of respected Rajendra Babuji Darda, Chief Editor of Lokmat Group.

Convener JR Anil Jain explained that awareness regarding side-effect-free therapies is now spreading globally.

Participating organizations included:
• Indian Institute of Holistic Science  
• Indian Acupressure Yoga Council  
• Sujok Association  
• Bihar Acupressure Yoga College  
• Heritage Foundation  
• Academy for Acupressure and Acupuncture  

Experts from around the world shared research findings and practical experiences.

The event was broadcast online through Facebook and YouTube.""",
                  isExpanded: faqExpanded3,
                  onTap: () => setState(() => faqExpanded3 = !faqExpanded3),
                ),
                _buildFAQItem(
                  index: 4,
                  question:
                      "International Reflexology Week - Online Discussions and Meetings Organized",
                  answer:
                      """An online meeting of the International Reflexology Week Planning Committee was organized to celebrate the week through online activities while staying at home.

The campaign included:
• Free treatment programs  
• Online awareness sessions  
• National and International conferences  

The International Reflexology Council celebrates the last week of September every year as International Reflexology Week.

From September 20th to 26th:
• Free treatment camps  
• Online discussions  
• Training sessions  

were organized nationwide.

Different therapies promoted included:
• Acupressure  
• Reflexology  
• Sujok  
• Shiatsu  
• Acupuncture  
• Reiki  
• JIN Reflexology  

All practitioners contributed by offering free treatments daily.

The movement was supported by:
• Lokmat Group  
• International Reflexology Jain Association  
• Indian Institute of Holistic Science  
• Indian Acupressure Yoga Council  

JR Anil Jain emphasized the importance of preventive healthcare and immunity improvement through natural therapies.

The International Conference held on September 26th featured experts from around the world who presented their research and experiences.

The entire event was streamed online on Facebook and YouTube.""",
                  isExpanded: faqExpanded4,
                  onTap: () => setState(() => faqExpanded4 = !faqExpanded4),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                answer,
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

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
