import 'package:flutter/material.dart';
import 'package:jin_reflex_new/screens/health_campaign_pdf_screen.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';

class HealthCampaign2026Screen extends StatefulWidget {
  const HealthCampaign2026Screen({super.key});

  @override
  State<HealthCampaign2026Screen> createState() =>
      _HealthCampaign2026ScreenState();
}

class _HealthCampaign2026ScreenState
    extends State<HealthCampaign2026Screen> {

  int expandedIndex = -1;

  final List<Map<String, String>> faqList = [
    {
      "question":
          "JIN Reflexology Day to International Yoga Day – India’s Biggest Health Awareness Campaign 2026",
      "answer":
          "India’s Biggest Health Awareness Campaign – on the occasion of JIN Reflexology Day.\n\nStarting from June 1st (JIN Reflexology Day): 21 days, 21 seminars in 21 cities.\n\nLokmat News Network, Aurangabad: The International Reflexology JIN Association will celebrate JIN Reflexology Day on June 1. On this occasion, a health awareness campaign will be conducted across the state from June 1 to June 21.\n\nBetween JIN Reflexology Day and International Yoga Day, 21 health awareness campaigns have been organized in 21 cities during these 21 days. Detailed information on how to prevent serious diseases in the future through JIN Reflexology will be provided in all these campaigns. The media partner of this campaign is Lokmat.\n\nIn this campaign, the International Reflexology JIN Association, along with Shuddham Jain Shravak Sangh, Himayatanagar; Bharatiya Jain Sanghatana, Sillod and Lasalgaon; National Institute of Naturopathy, Pune; Pragya Jain Mahila Jain Mandal, Mumbai; Jai Bhagwan Acupressure Center, Mumbai; Digambar Jain Sangh, Bhiwandi; Oswal Social Group and Jain Sangh, Jamner; Shrimunisuvrat Jain Samaj, Paithan; Shantinath Digambar Jain Mandir, Dhule; Balasaheb Community Development Center, Kannad; A. Bha. Terapanth Mahila Mandal; Dakshin Madhya Jain Shravak Sangh; Indian Medical Association; Mahavir International; Metrocity; Aurangabad District Automobiles Association; Marwari Yuva Manch, Jalna; Matsyodari Mahila Midtown, Branch Ambad; Lions Club of Aurangabad-Midtown; Parshwanath Brahmachari Ashram, Verul; and many other institutions and organizations are making efforts.\n\nThe keynote speaker of this program will be JR Anil Jain, Inventor of JIN Reflexology.\n\nThe campaign will conclude on June 21 in Shirdi. The program will be presided over by Rajendra Darda, Editor-in-Chief of Lokmat.\n\nMedia Partner:\nLokmat, Lokmat News, Lokmat Times.\n\nStarting from Prayagraj from June 1st, the health awareness seminar campaign begins in Uttar Pradesh. JIN Reflexology Day will be celebrated at Prayagraj on June 1. This seminar has been organized by Acupressure Shodh avm Upchar Sansthan, Prayagraj.\n\nThe 10-member committee for planning the campaign includes Rajendra Darda, Lalit Gandhi, Dr. Nirmala Pardhi (Mumbai), Dr. Sapna Patni (Dhule), JP Shilpa Jain, JP Agrawal, and others.\n\nConvener JR Anil Jain informed that the seminars in the campaign are free, and to participate, people should use the official website along with YouTube and Facebook platforms.\n\nJIN Reflexology Day to International Yoga Day – India’s Biggest Health Awareness Campaign 2026."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
        appBar: CommonAppBar(title: "Health Awareness – 2026"),
      // appBar: AppBar(
      //   backgroundColor: const Color(0xFF6A3EB5),
      //   centerTitle: true,
      //   title: const Text(
      //     "Health Awareness Campaign 2026",
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      // ),
      
      body: SingleChildScrollView(
        child: Column(
          children: [
             ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
                     padding: const EdgeInsets.all(16),
                     itemCount: faqList.length,
                     itemBuilder: (context, index) {
                       final item = faqList[index];
                       final isExpanded = expandedIndex == index;
             
                       return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isExpanded
                      ? const Color(0xFF6A3EB5)
                      : Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
             
                  /// HEADER
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() {
                        expandedIndex =
                            isExpanded ? -1 : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
             
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6A3EB5),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
             
                          const SizedBox(width: 12),
             
                          Expanded(
                            child: Text(
                              item["question"]!,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.bold,
                                color: isExpanded
                                    ? const Color(0xFF6A3EB5)
                                    : Colors.black87,
                              ),
                            ),
                          ),
             
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration:
                                const Duration(milliseconds: 300),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                              color: Color(0xFF6A3EB5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
             
                  /// ANSWER
                  AnimatedCrossFade(
                    firstChild: const SizedBox(),
                    secondChild: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 16),
                      child: Text(
                        item["answer"]!,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.8,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration:
                        const Duration(milliseconds: 350),
                  ),
                ],
              ),
                       );
                     },
                   ),
               SizedBox(
                    height: 560,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: const HealthCampaignScreen(initialYear: 2026),
                    ),
                  ),
          ],
        ),
      )
    );
  }
}