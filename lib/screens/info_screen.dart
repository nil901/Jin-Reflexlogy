import 'package:flutter/material.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';

class InfoScreen extends StatelessWidget {
  InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: CommonAppBar(title: "Info"),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/classification.jpg"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            const FAQScreen(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int expandedIndex = -1;

final List<Map<String, String>> faqList = [
  {
    "question": "Reflexology and JIN Reflexology",
    "answer":
        "Among non-drug-based medical methods worldwide, reflexology is considered one of the most effective. JIN Reflexology is an advanced form of reflexology and acupressure.\n\nJR Anil Jain, the researcher behind JIN Reflexology, has dedicated years of hard work, effort, and research to developing this method. His extensive experience has led to a medical practice where, without asking the patient, he can determine their ailments just by pressing reflex points on their hands and feet.\n\nThis method accurately diagnoses current and potential future issues. While reflexology has existed for some time, JIN Reflexology uniquely combines both diagnosis and treatment."
  },

  {
    "question": "What is Acupressure?",
    "answer":
        "Acupressure means: Acu means a special or sharp object, and pressure means applying pressure. The methods of treatment by applying pressure on certain points or reflex centers in the body through fingers or instruments are included under acupressure.\n\nAcupuncture is made up of two words. Acu means special or sharp object, and puncture means piercing. That means the methods of treatment by piercing points or reflex centers in the body with needles are included under acupuncture.\n\nNow we will learn about the medical methods that come under acupressure and acupuncture."
  },

  {
    "question": "What is Reflexology?",
    "answer":
        "Reflexology means reflection. The method of treating body parts and reflex centers by applying pressure or massage through fingers, thumbs, wooden sticks (also called Jimmy), or other tools is called reflexology.\n\nThese reflex centers are located on the hands, feet, face, ears, and other parts of the body. Reflexology helps improve blood circulation, relax the body, and support natural healing."
  },

  {
    "question": "Which is the best therapy of the world?",
    "answer":
        "There are more than two hundred medical systems in the world to prevent diseases. Which is the best among them?\n\nThis is a complex question in itself because every doctor who adopts a particular method considers his medical system the best. The patient is always confused about which medical system should be adopted.\n\nTo remove such confusion, our ancient scholars formulated five health policies.\n\n1. It should help in preventing diseases.\n2. Correct diagnosis of the disease.\n3. Results should be obtained quickly.\n4. There should not be any kind of side effects.\n5. It should be completely natural and not very expensive.\n\nModern health policies:\nA - Access\nB - Best Quality\nC - Cost (Low Cost)\nD - Disparities\nE - Effectiveness (Comparative)\n\nAfter conducting a comparative study of all these health policies, it can be concluded that JIN Reflexology is one of the best therapies in the world."
  },

  {
    "question": "Features of JIN Reflexology",
    "answer":
        "1. Energetic and stress-free life.\n\n2. Reduction in monthly medicine expenses of the family.\n\n3. Painless and safe therapy.\n\n4. Easy to learn and practice.\n\n5. Totally natural and non-violent method of treatment.\n\n6. Self-treatment can be done by oneself.\n\n7. Useful in all types of diseases.\n\n8. Diseases in the body are detected quickly and treatment is also done.\n\n9. Free from all types of harmful side effects.\n\n10. Awakens consciousness power in the body and brings vitality.\n\n11. Essential elements spread properly in the body and flexibility is created in the muscles.\n\n12. Helpful in increasing immunity.\n\n13. Controls the juices secreted by the endocrine glands.\n\n14. Provides instant relief for immediate problems.\n\n15. Equally beneficial for children, youngsters, women, and men."
  },

  {
    "question": "Do not give the treatment in the following conditions.",
    "answer":
        "1. Pregnant women.\n\n2. On swollen parts of the body.\n\n3. Drunk people.\n\n4. Extremely tired people.\n\n5. On the site of operation or injury.\n\n6. On a completely hungry stomach.\n\n7. On the site of fracture.\n\n8. During menstruation."
  },

  {
    "question": "JIN Reflexology - A Unique Method",
    "answer":
        "There are many medical methods in the world, and most of them work on the basis of average results. However, JIN Reflexology works as a unique method.\n\nJIN Reflexology focuses on identifying the root cause of the disease instead of only treating symptoms.\n\nExample:\nA 35-year-old woman had suffered from headaches for six months. Through reflex diagnosis, it was discovered that the actual cause was acid bile and not a head-related issue.\n\nAfter seven days of treatment using reflex pressure and micro magnets, both her acidity and headache problems were completely cured.\n\nThis shows that JIN Reflexology is a unique method focused on root-cause healing."
  },

  {
    "question": "Essential points of JIN Reflexology -",
    "answer":
        "For the Therapist:\n\n1. Give treatment in a calm and favorable environment.\n\n2. Before treatment, make abdominal, spinal, and sciatic lines in the foot.\n\n3. Observe the foot carefully before treatment.\n\n4. Keep nails clean and trimmed.\n\n5. Give pressure according to the patient’s condition.\n\n6. Perform treatment with full concentration.\n\n7. Keep patient information confidential.\n\n8. Do not apply pressure in cases of swelling, redness, or severe pain.\n\nFor the Patient:\n\n1. Feet should be properly washed and clean.\n\n2. Keep at least one hour gap between food and treatment.\n\n3. Follow proper diet restrictions during treatment.\n\n4. Sometimes symptoms may temporarily increase before complete healing."
  },
];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A3EB5),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: faqList.length,
          itemBuilder: (context, index) {
            final item = faqList[index];
            final isExpanded = expandedIndex == index;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isExpanded
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
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? -1 : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item["question"]!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isExpanded
                                        ? const Color(0xFF6A3EB5)
                                        : Colors.black87,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 28,
                              color: Color(0xFF6A3EB5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        item["answer"]!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    crossFadeState:
                        isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
