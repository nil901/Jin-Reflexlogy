import 'package:flutter/material.dart';
import 'package:jin_reflex_new/screens/health_campaign_pdf_screen.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';

class Wrw2022Screen extends StatefulWidget {
  const Wrw2022Screen({super.key});

  @override
  State<Wrw2022Screen> createState() => _Wrw2022ScreenState();
}

class _Wrw2022ScreenState extends State<Wrw2022Screen> {
  bool _expanded = true;
  
  // FAQ expandable states
  bool faqExpanded1 = false;
  bool faqExpanded2 = false;
  bool faqExpanded3 = false;
  bool faqExpanded4 = false;
  bool faqExpanded5 = false;
  bool faqExpanded6 = false;
  bool faqExpanded7 = false;

  Widget _expandableHeader(String title) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              _expanded ? Icons.remove : Icons.add,
              size: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Health Awareness – 2022"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
                if (_expanded) ...[
                  const SizedBox(height: 10),
               
              
                  
                  /// FAQ Section
                  _buildFAQSection(),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    "2022 Glimpses PDF",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 560,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: const HealthCampaignScreen(initialYear: 2022),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// FAQ Section
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
      children: [
       
        /// FAQ Items
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [

             _buildFAQItem(
    index: 1,
    question:
        "Health awareness campaign on the occasion of JIN Reflexology Day",
    answer:
        '''Starting from June 1st: 21 days, 25 seminars in 19 cities

Lokmat News Network, Aurangabad: The International Reflexology JIN Association will celebrate JIN Reflexology Day on June 1. On this occasion, a health awareness campaign will be conducted across the state from June 1 to June 21.

Between JIN Reflexology Day and International Yoga Day, 25 health awareness seminars have been organized in 19 cities during these 21 days. Detailed information on how to prevent serious diseases in the future through JIN Reflexology will be provided in all these campaigns. The media partner of this campaign is Lokmat.

In this campaign, the International Reflexology JIN Association, along with Sudharma Jain Shravak Sangh, Himayatnagar; Bharatiya Jain Sanghatana, Sillod and Lasalgaon; National Institute of Naturopathy, Pune; Pragya Jain Mahila Jain Mandal, Mumbai; Jai Bhagwan Acupressure Center, Mumbai; Digambar Jain Sangh, Bhiwandi; Oswal Social Group and Jain Sangh, Jamner; Shrimunisuvrat Jain Samaj, Paithan; Shantinath Digambar Jain Mandir, Dhule; Balasaheb Community Development Center, Kannada; A. Bha. Terapanth Mahila Mandal; Dakshin Madhya Jain Shravak Sangh; Indian Medical Association; Mahavir International; Metrocity; Aurangabad District Automobiles Association; Marwari Yuva Manch, Jalna; Matsyodari Mahila Midtown, Branch Ambad; Lions Club of Aurangabad Midtown; Parshwanath Brahmachari Ashram, Verul; and other institutions and organizations are making efforts.

The keynote speaker of this program will be JR Anil Jain, Inventor of JIN Reflexology, along with JR Shilpa Jain, JR Anuprita Gandhi, JR Sapna Gandhi, JR Monica Kathed, and JR Mayuri Surana.

The campaign will conclude on June 26 in Aurangabad. The program will be presided over by Rajendra Darda, Editor-in-Chief of Lokmat.

Media Partner:
Lokmat, Lokmat News, Lokmat Times

Starting from Himayatnagar on June 1st:
The health awareness seminar campaign begins in Nanded district. JIN Reflexology Day will be celebrated at Himayatnagar on June 1. The inauguration will be conducted by A. Madhavrao Patil Jalbgaonkar. This seminar has been organized by Sudharma Jain Shravak Sangh.

The 10-member committee for planning the campaign includes:
Rajendra Darda,
Lalit Gandhi,
Dr. Nirmala Pardhi (Mumbai),
Sanjay Mantri,
Dr. Sapna Patni (Dhule),
Naresh Lalwani,
Sandeep Kated,
Vimlesh Gandhi,
Supriya Surana.

Convener JR Anil Jain informed that the seminars in the campaign are free, and to participate, one should use the website given below to watch YouTube and Facebook.''',
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
                        fontSize: 15,
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