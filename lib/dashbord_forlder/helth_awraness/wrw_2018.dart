import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:jin_reflex_new/screens/health_campaign_pdf_screen.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Wrw2018Screen extends StatefulWidget {
  const Wrw2018Screen({super.key});

  @override
  State<Wrw2018Screen> createState() => _Wrw2018ScreenState();

  /// 🟡 Section Header
  static Widget sectionTitle(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFFF6B0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                fontSize: 20,
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
}

class _Wrw2018ScreenState extends State<Wrw2018Screen> {
  bool isExpanded1 = false;
  bool isExpanded2 = false;
  bool isExpanded3 = false;
  
  // FAQ expandable states
  bool faqExpanded1 = false;
  bool faqExpanded2 = false;
  bool faqExpanded3 = false;
  bool faqExpanded4 = false;
  bool faqExpanded5 = false;
  bool faqExpanded6 = false;
  bool faqExpanded7 = false;
  bool faqExpanded8 = false;
  bool faqExpanded9 = false;
  bool faqExpanded10 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "WRW - 2018"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔵 Purple Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF6A3EB5),
              child: const Text(
                "World Reflexology Week - 24th September to 30th September , 2018",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Wrw2018Screen.buildRow("Convenor", "JR Anil Jain"),
            Wrw2018Screen.buildRow(
              "Advisory Member",
              "Prof. P.B. Lohiya, Dr. Sarvdeo Prasad Gupta",
            ),
            Wrw2018Screen.sectionTitle(
              "WRW Inaugural Function - World Reflexology Week Nationwide Free Treatment Mega Event",
            ),
            Wrw2018Screen.buildRow("Date", "24th September 2018"),
            Wrw2018Screen.buildRow(
              "Guest",
              "Hon. Rajendra Babuji Darda (Editor in Chief, Lokmat), ",
            ),
            Wrw2018Screen.buildRow("City", "Aurangabad, Maharashtra, India"),
            Wrw2018Screen.buildRow("Organizer", "International Reflexology JIN Association"),
            Wrw2018Screen.sectionTitle(
              "WRW Concluding Function - 4th National Conference and Award Presentation Ceremony - 2018",
            ),
            Wrw2018Screen.buildRow("Date", "30th September 2018"),
            Wrw2018Screen.buildRow(
              "Guest",
              "Dr. Sachin Lohia and Dr. Bharat Bhushan Sharma",
            ),
            Wrw2018Screen.buildRow("City", "Surat, Gujrat, India"),
            Wrw2018Screen.buildRow("Organizer", "International Reflexology JIN Association"),
            Wrw2018Screen.buildRow("Supported", "JIN Reflexology, Jain Chumbak"),
            Wrw2018Screen.buildRow("Media Partner", "Lokmat (Maharashtra's No.1 Newspaper)"),
          

          
            if (isExpanded1) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Text(
                      "Lokmat News – Aurangabad, September 18. Los Seva",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "International Reflexology Week is celebrated nationwide as a free medical extravaganza. Organized by the Acupressure Training and Research Center and the Nature Care Therapist Association, the week was inaugurated on Monday at the Gajanan Hall at the Gajanan Maharaj Temple. As part of this campaign, all therapists at 33 centers across the city will provide free medical services for two hours each day.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "This massive campaign was launched two years ago under the guidance of Lokmat Editor-in-Chief Rajendra Darda. Under the leadership of leading institutions across the country, acupressure, Sujok, Shiatsu, reflexology, and JIN Reflexology have been promoted and practiced widely.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "MLA Atul Save receives treatment at the inauguration of the International Reflexology Week in Aurangabad on Monday. Also seen are JR Anil Jain, Prabha Desarda, Manju Thole, Harshali Sancheti, Dr. Jayshree Mag, and others.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "With the help of practitioners of medical systems like reflexology, this campaign will continue across the country until September 24. MLA Atul Save, President of the Lions Club of Aurangabad Royal, inaugurated this free service week. Omprakash Agarwal, Manoj Bora, Paras Ostwal, Lalit Gandhi and convener JR Anil Jain were prominently present. MLA Atul Save said that many people suffer side effects from medicines and that reflexology and acupressure treatments prove to be crucial. He urged the city's citizens to take advantage of this week. JR Anil Jain stated that these treatments prove to be important for leading a drug-free life.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Specific pressure is applied to the body's reflex centers, including the hands, feet, ears, and face. This treatment technique has also become popular abroad. It should be adopted as a form of primary care.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "A large number of doctors, including Nilesh Kankaria, Vikas Patni, Anand Duggad, Prabha Desarda, Manoj Bakliwal, and others, were present at the event. Following the inauguration, many people received treatment. A national committee has been established to conduct the free medical campaign. The entire program was organized under the guidance of Dr. P.B. Lohia, Dr. Anant Biradar, Dr. Sarvdev Gupta, and Dr. Kusum Agarwal. Lokmat News is the media partner for the event. JIN Reflexology and the Lions Club of Aurangabad Royal have provided support for the event.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          
            const SizedBox(height: 20),
            /// 📰 Main Article Section
            const ArticleSection(),

            /// ❓ FAQ SECTION
            

            
          ],
        ),
      ),
    );
  }

  /// ❓ FAQ Section Widget
 
}

/// 📰 Article Section
class ArticleSection extends ConsumerStatefulWidget {
  const ArticleSection({super.key});

  @override
  ConsumerState<ArticleSection> createState() => _ArticleSectionState();
}
class _ArticleSectionState extends ConsumerState<ArticleSection> {
    bool isExpanded1 = false;
  bool isExpanded2 = false;
  bool isExpanded3 = false;
  
  // FAQ expandable states
  bool faqExpanded1 = false;
  bool faqExpanded2 = false;
  bool faqExpanded3 = false;
  bool faqExpanded4 = false;
  bool faqExpanded5 = false;
  bool faqExpanded6 = false;
  bool faqExpanded7 = false;
  bool faqExpanded8 = false;
  bool faqExpanded9 = false;
  bool faqExpanded10 = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "4th National Conference And Award Presentaion Ceremony - Surat",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
           const SizedBox(height: 10),
        
          
         
        
         
        
         
          // const SizedBox(height: 20),

          /// ✅ YOUTUBE VIDEO 1
          const YoutubeVideoPlayer(videoUrl: "https://www.youtube.com/watch?v=4ItVRzDA8mw"),
          
          const SizedBox(height: 20),
          const Text(
            "4th National Conference And Award Presentaion Ceremony - Surat",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          /// ✅ YOUTUBE VIDEO 2
          const YoutubeVideoPlayer(videoUrl: "https://www.youtube.com/watch?v=mo9l8_jM2rU"),
          
          const SizedBox(height: 12),
          
        
          

         
          
         


       _buildFAQSection(),
          const SizedBox(height: 10),
          const Text(
            "Other Glimpses of India's Biggest Health Awareness Campaign – 2018",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 560,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const HealthCampaignScreen(initialYear: 2018),
            ),
          ),
        ],
      ),
    );
  }
   Widget _buildFAQSection() {
    return Container(
    //  margin: const EdgeInsets.all(16),
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
         
          
          // FAQ Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
_buildFAQItem(
  index: 1,
  question:
      "International Reflexology Week - A week-long grand event of free treatments",
  answer:
      """International Reflexology Week is celebrated across the country as a grand festival of free medical treatment and health awareness. The International Reflexology Council observes the last week of September every year as International Reflexology Week. Following this tradition, under the leadership of leading organizations across the country, this campaign was organized from September 24th to 30th with the cooperation of practitioners of various drug-free therapies such as Acupressure, Reflexology, Sujok, Shiatsu, JIN Reflexology, Neurotherapy, and Acupuncture.

As part of this nationwide campaign, free treatment and training camps were organized at different centers. All practitioners provided free treatment for two hours daily at their respective clinics and therapy centers. After the completion of the service week, practitioners were honored with certificates for their contribution to public health awareness and natural healing services.

This grand initiative was started three years ago under the guidance of Lokmat Group’s Chief Editor, Honorable Rajendra Babuji Darda. Convener JR Anil Jain, Inventor of JIN Reflexology, stated that Reflexology and Acupressure are developed forms of the Indian way of life and drug-free healing systems that have now gained recognition from local to international levels.

To create awareness among the public, therapists also organized free workshops at educational institutions, business organizations, and public places during the seven-day event. The campaign was jointly organized by the Acupressure Training and Research Center along with institutions such as the International Naturopathy Organization, Indian Institute of Holistic Science, Bharatiya Acupressure Yoga Council, Bihar Acupressure Yoga College, All India Association of Acupressure Reflexology, Scientific Institute of Alternative Medicine and Paramedical Science Council, National Institute of Acupressure Research Training and Treatment, Heritage Foundation, Vishwa Chaitanya Acupressure Therapy Foundation and Research Center, and Nature Care Organization.

A national-level committee was formed for the successful implementation of all activities. The program was organized under the guidance of Dr. P.B. Lohia, Anant Biradar, Dr. Sarvadev Prasad Gupta, Shri Ashok Kothari, and co-convenor Dr. Dilip Kumar Urankar.

The nationwide launch of International Reflexology Week took place in Aurangabad and was inaugurated on September 24th by Lokmat Group Chief Editor Rajendra Babuji Darda.

The Fourth All India Conference of practitioners of drug-free therapies including Acupressure, Reflexology, Sujok, Shiatsu, JIN Reflexology, Reiki, Mudra Therapy, and Neuro Therapy was organized in Surat on September 30th, marking the conclusion of the week-long celebration. Leading practitioners and experts from across the country presented their research work and shared their experiences during the conference.

Practitioners with more than three years of experience and those who made remarkable contributions in the field of natural healing therapies were honored during the event.

Reflexology Acupressure is a treatment method in which special pressure is applied to the reflex points located on the hands, feet, ears, and face to stimulate the body’s organs and improve overall health naturally.""",
  isExpanded: faqExpanded1,
  onTap: () => setState(() => faqExpanded1 = !faqExpanded1),
),

_buildFAQItem(
  index: 2,
  question:
      "With a resolve to conduct research activities, International Reflexology Week concludes in Surat",
  answer:
      """The Fourth All India Conference of practitioners of drug-free therapies such as Acupressure, Reflexology, Sujok, Shiatsu, JIN Reflexology, Reiki, Mudra Therapy, and Neuro Therapy was successfully organized in Surat on the concluding day of International Reflexology Week.

At the inauguration of the service week, Lokmat Group’s respected Editor-in-Chief Rajendra Ji Darda emphasized the importance of research work in making drug-free therapies more effective and scientifically accepted. Inspired by his guidance, practitioners from across the country resolved to actively conduct research activities and focus on disease diagnosis through natural healing systems.

With the cooperation of therapists and practitioners nationwide, the campaign was conducted across the country from September 24th to 30th. During this period, thousands of therapists provided free treatment and training services to millions of patients through various treatment camps and awareness programs.

The conference began with a prayer presented by JR Harshali Sancheti, Preeti Desarda, and Anuprita Gandhi. In his introductory speech, Convener JR Anil Jain, Inventor of JIN Reflexology, explained the importance of preserving India’s ancient healing systems while presenting them with a scientific perspective for modern society.

He stated that JIN Reflexology, a developed form of the Indian lifestyle and healing system, not only helps in treatment but also assists in identifying problems within the body without the use of machines. Dr. Sachin Lohia, Secretary of the Indian Institute of Holistic Science, encouraged all practitioners to work together for the development of natural healing therapies.

The convenor and therapists from different states expressed heartfelt gratitude to Rajendra Babuji Darda for supporting these side-effect-free medical systems as a guide and media partner through Lokmat Group.

Leading experts from various parts of the country presented research papers and demonstrations on topics such as Acupuncture, Acupressure, JIN Reflexology, Home Therapy, Magnet Therapy, Stress-Free Lifestyle, and Clapping Therapy.

The conference was organized by the Acupressure Training and Research Center and was successfully conducted under the leadership of Convener JR Anil Jain along with co-convenors Dr. Dilip Urankar, Dr. Nanji Bhai (Surat), Santosh Adakul (Solapur), Bharat Bhushan (New Delhi), and Prof. P.B. Lohia.

The program was beautifully anchored by JR Manju Thole and JR Shilpa Jain.""",
  isExpanded: faqExpanded2,
  onTap: () => setState(() => faqExpanded2 = !faqExpanded2),
),
              ],
            ),
          )
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
        color: isExpanded ? const Color(0xFFFFF6B0).withOpacity(0.3) : Colors.white,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isExpanded ? const Color(0xFF6A3EB5) : Colors.black87,
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
}

/// 🎬 YouTube Video Player Widget
class YoutubeVideoPlayer extends StatelessWidget {
  final String videoUrl;
  
  const YoutubeVideoPlayer({super.key, required this.videoUrl});
  
  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    
    if (videoId == null) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(
          child: Text(
            'Invalid YouTube URL',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              isLive: false,
              disableDragSeek: false,
              loop: false,
              showLiveFullscreenButton: false,
            ),
          ),
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blue,
          aspectRatio: 16 / 9,
          onReady: () {
            debugPrint('YouTube Player is ready');
          },
        ),
      ),
    );
  }
}