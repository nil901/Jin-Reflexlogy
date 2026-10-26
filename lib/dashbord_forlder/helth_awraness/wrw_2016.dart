import 'package:flutter/material.dart';
import 'package:jin_reflex_new/screens/health_campaign_pdf_screen.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';

class Wrw2016Screen extends StatelessWidget {
  const Wrw2016Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "WRW - 2016"),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔵 Purple Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF6A3EB5),
              child: const Text(
                "World Reflexology Week - 19th September to 25th September, 2016",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

            buildRow("Convenor", "JR Anil Jain"),
            buildRow(
              "Advisory Member",
              "Prof. P.B. Lohiya, Dr. Sarvdeo Prasad Gupta",
            ),

            sectionTitle(
              "WRW Inaugural Function - World Reflexology Week Nationwide Free Treatment Mega Event",
            ),

            buildRow("Date", "19th September 2016"),
            buildRow(
              "Guest",
              "Hon. Rajendra Babuji Darda (Editor in Chief, Lokmat), "
                  "Hon. Prashant Bamb (MLA), Hon. Atul Save (MLA)",
            ),
            buildRow("City", "Aurangabad, Maharashtra, India"),
            buildRow("Organizer", "International Reflexology JIN Association"),

            sectionTitle(
              "WRW Concluding Function - 2nd National Conference and Award Presentation Ceremony - 2016",
            ),

            buildRow("Date", "25th September 2016"),
            buildRow(
              "Guest",
              "Hon. Deepak Kesarkar (Minister of State), "
                  "Hon. Shrikant Shinde (MP)",
            ),
            buildRow("City", "Mumbai, Maharashtra, India"),
            buildRow("Organizer", "International Reflexology JIN Association"),
            buildRow("Supported", "JIN Reflexology, Jain Chumbak"),
            buildRow("Media Partner", "Lokmat (Maharashtra's No.1 Newspaper)"),

            const SizedBox(height: 20),

            /// ✅ ARTICLE SECTION ADDED BELOW
            articleSection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 🟡 Section Header
  static Widget sectionTitle(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFFF6B0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 📋 Table Row
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

  /// 📰 Article Section
  static Widget articleSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
       
 Hedings(),
          SizedBox(
            height: 560,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const HealthCampaignScreen(initialYear: 2016),
            ),
          ),
         
        ],
      ),
    );
  }
}

class Hedings extends StatelessWidget {
  const Hedings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          faqTile(
            title:
                "International Reflexology Week from September 19th - A grand celebration of therapy to be held across the country",
            content:
                """Aurangabad: The International Reflexology Week will be celebrated across the country as a grand festival of free therapy. Under the leadership of all major institutions in the country, this campaign will run from September 19th to 25th across the country with the cooperation of therapists of various treatment methods such as Acupressure, Sujok, Shiatsu, Reflexology, and JIN Reflexology. Under this initiative, all therapists will provide free treatment for two hours every day at their centers. The campaign will be launched under the guidance of Lokmat Group's Editor-in-Chief, Honorable Rajendra Darda.

Convener JR Anil, Inventor of JIN Reflexology, said that in the context of Reflexology Acupressure, a developed form of the Indian way of life, a grand event of free treatment for two hours every day for a week will be organized from the local to the global level with the cooperation of institutions such as: Indian Acupressure Yoga Council, Bihar Acupressure Yoga College (Patna), Scientific Institute of Alternative Medicine and Paramedical Science Council (New Delhi), National Institute of Acupressure Research Training and Treatment (Chandigarh), Vishwa Chaitanya Acupressure Therapy Foundation and Research Center, Acupressure Research Training and Treatment Center (Jodhpur), International Naturopathy Organization (New Delhi), Nature Care Reflexology Therapists Association (Aurangabad), and others.

World Reflexology Week: For A Healthier World – International Council of Reflexology. The last full week of September, during these seven days, free workshops are being organized at the local level in acupressure therapy specialist educational institutions and professional organizations. Poster for this occasion: 2nd National Conference and Award Presentation Ceremony in Mumbai. The second All India Conference on 'Acupressure, Reflexology, Sujok, Shiatsu, JIN Reflexology' is being organized in Mumbai. Along with giving shape to the international research center's development plan, leading medical specialists from across the country will present their research work. On this occasion, practitioners with more than three years of experience will be felicitated. Practitioners will participate in the ceremony and expand their knowledge.

An exhibition will also be organized. A national-level committee has been formed for all these programs. The Indian Board of Alternative Medicine is the main organizer.

It is being organized in the last week of September through the International Reflexology Conference. Awareness campaigns are being conducted through this week. Through the Acupressure Training & Research Center, Acupressure Research, Training and Treatment Institute (Allahabad), Indian Board of Alternative Medicine (Kolkata), Indian Institute of Holistic Science, All India Association of Acupressure Reflexology (Delhi), Dr. Suresh Agarwal (President, Kolkata), Dr. P. B. Lohia (President of the Indian Institute of Holistic Science), Dr. Sarvadev Prasad Gupta (President of the Indian Acupressure Yoga Council), Dr. Kusum Agarwal (All India Association of Acupressure Reflexology, Delhi), Anant Biradar (President of the International Naturopathy Organization), and others. This entire program is being organized under their guidance.

What is Reflexology Acupressure Therapy?
Reflexology Acupressure means: Acu means sharp, Pressure means pressure, and Reflex means reflection. The method of treating by applying special pressure to the reflection centers of the body's organs, which are located on the hands, feet, ears, and face, is called Reflexology Acupressure.""",
          ),
          faqTile(
            title: "Free Mega Campaign",
            content:
                """The Seva Week Camp will continue from September 19th to 25th. Patients will be examined at the free treatment camp. The incredible importance of the Indian medical system Reflexology in a healthy life.

Aurangabad, September 19th: Two hours of free service daily to commemorate World Reflexology Week. A free treatment camp was inaugurated today by the Acupressure Training and Research Center.

The camp was inaugurated by Lokmat Editor-in-Chief Rajendra Babuji Darda at the Gajanan Maharaj Temple Trust's 'Gajanan Maharaj Bhavan'. Prominent attendees on the occasion included MLA Prashant Bamba, Paras Ostwal of the Lions Club of Aurangabad Royal, Secretary Vishal Dargad, President of the Gajanan Maharaj Temple Trust, and JR Anil Jain, Inventor of JIN Reflexology and President of the Acupressure Training and Research Center.

The guests unanimously declared, "Starting today and for the next seven days, 60 therapists will provide free treatment for two hours daily at forty centers across the city. People suffering from various diseases have been urged to take advantage of this program." This free medical campaign will conclude in Mumbai on September 25th. Medical Education Minister Girish Mahajan will be present on this occasion.

He stated that the importance of reflexology (acupressure) for a healthy life is incomparable. This treatment method is a form of living. People have been relieved of many ailments through this treatment; this is the second year of the camp.

Rajendra Darda stated that this is a type of natural medicine. Acupressure originated in India. This treatment method existed in India thousands of years ago. People like Anil Jain are promoting this treatment method in India. Darda said that if the tongue is controlled, all the nerves of the body can be controlled.""",
          ),
          faqTile(
            title:
                "Promoting Alternative Medicine System Like Yoga: Honorable Deepak Kesarkar",
            content:
                """Aurangabad | September 26: Lokmat Seva – Maharashtra's Minister of State for Home, Finance and Planning, Deepak Kesarkar, said that efforts will be made to promote alternative medicine systems like Yoga. This will enable more and more people to learn about its benefits.

He was addressing the Second All India Conference held in Mumbai on Sunday on the conclusion of World Reflexology Week. Presiding over the program, he congratulated the organizers for the successful organization of Reflexology Week.

It is noteworthy that an awareness campaign was conducted across the country through all the institutions associated with these medical systems. Lokmat is Media Partner for this entire event: World Reflexology Week.

2nd National Conference & Awards Presentation Ceremony under the Presidentship of Maharashtra's Minister of State for Home, Finance and Planning, Deepak Kesarkar, Shrikant Ji Shinde (M.P.), Convenor JR Anil Jain, Inventor of JIN Reflexology, addressing the program held in Mumbai on Sunday.

Organized By: Acupressure Training & Research Centre. The 'Lokmat Group' played a significant role. Under the week-long program held from September 19 to 25, more than 25,000 doctors from all corners of the country provided services for 2 hours daily. During this time, millions of patients benefited from it.""",
          ),
          faqTile(
            title:
                "Health Awareness & Life Changing Seminars: Change lifestyle to enjoy life – JR Anil Jain's Appeal",
            content:
                """Our lifestyle should be in harmony with nature. In today's hectic life, despite running around a lot, we face stress and depression. To avoid that, we can benefit from a happy life by changing our daily routine a little, asserted JR Anil Jain, Inventor of JIN Reflexology.

JR Anil Jain further said, "Our ancestors used to say that early to bed and early to rise brings good health. It is true and has a scientific basis. We must wake up before sunrise. Only if we sleep for 6 to 8 hours continuously can we experience the joy of being refreshed.

It is a situation where the body of highly educated people who sit still does not get any sun. One must walk barefoot on the ground or on the grass for some time every day. Being in the open air allows one to get plenty of oxygen. Light exercises and yoga should be done regularly.

Moments do not come back. Always be happy, smiling, and cheerful. Positive thinking changes your lifestyle and doubles the joy of living," said JR Anil Jain.

Life is precious, health plays an important role: JR Anil Jain
A workshop was organized at the Senior Citizen Forum to control uncontrolled lifestyle and make people aware about health.""",
          ),
        ],
      ),
    );
  }

  Widget faqTile({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: Colors.red,
          collapsedIconColor: Colors.red,
          backgroundColor: const Color(0xfff5f5f5),
          collapsedBackgroundColor: const Color(0xfff5f5f5),
          shape: Border.all(color: Colors.transparent),
          collapsedShape: Border.all(color: Colors.transparent),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.keyboard_double_arrow_right,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.7,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}