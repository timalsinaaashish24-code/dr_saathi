import 'package:flutter/material.dart';

class NutritionalAdviceScreen extends StatelessWidget {
  const NutritionalAdviceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutritional Advice'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[700]!, Colors.green[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text(
                  'Healthy Eating for Nepali Families',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'स्वस्थ खानपान नेपाली परिवारका लागि',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Balanced Diet Section
          _buildSectionCard(
            title: 'Balanced Diet / सन्तुलित आहार',
            icon: Icons.balance,
            color: Colors.orange,
            items: [
              _buildAdviceItem(
                'Eat dal-bhat-tarkari daily',
                'दैनिक दाल-भात-तरकारी खानुहोस्',
                Icons.rice_bowl,
              ),
              _buildAdviceItem(
                'Include seasonal fruits and vegetables',
                'मौसमी फलफूल र तरकारी समावेश गर्नुहोस्',
                Icons.agriculture,
              ),
              _buildAdviceItem(
                'Add protein: lentils, eggs, fish, meat',
                'प्रोटिन थप्नुहोस्: दाल, अण्डा, माछा, मासु',
                Icons.egg,
              ),
              _buildAdviceItem(
                'Use whole grains: brown rice, millet',
                'पूर्ण अन्न प्रयोग गर्नुहोस्: रातो चामल, कोदो',
                Icons.grass,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Vitamins & Minerals Section
          _buildSectionCard(
            title: 'Essential Vitamins & Minerals',
            icon: Icons.medication,
            color: Colors.blue,
            items: [
              _buildAdviceItem(
                'Iron: Spinach, meat, pomegranate',
                'फलाम: पालुङ्गो, मासु, अनार',
                Icons.bloodtype,
              ),
              _buildAdviceItem(
                'Calcium: Milk, yogurt, cheese, leafy greens',
                'क्याल्सियम: दूध, दही, पनीर, हरियो साग',
                Icons.water_drop,
              ),
              _buildAdviceItem(
                'Vitamin C: Citrus fruits, tomatoes, peppers',
                'भिटामिन सी: सुन्तला, गोलभेडा, खुर्सानी',
                Icons.local_drink,
              ),
              _buildAdviceItem(
                'Vitamin D: Sunlight, eggs, fortified milk',
                'भिटामिन डी: घाम, अण्डा, फोर्टिफाइड दूध',
                Icons.wb_sunny,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Hydration Section
          _buildSectionCard(
            title: 'Hydration / पानी सेवन',
            icon: Icons.water_drop,
            color: Colors.cyan,
            items: [
              _buildAdviceItem(
                'Drink 8-10 glasses of water daily',
                'दैनिक ८-१० गिलास पानी पिउनुहोस्',
                Icons.local_drink,
              ),
              _buildAdviceItem(
                'Drink boiled or filtered water',
                'उमालेको वा फिल्टर गरिएको पानी पिउनुहोस्',
                Icons.filter_alt,
              ),
              _buildAdviceItem(
                'Limit sugary drinks and soda',
                'चिनी र सोडा कम गर्नुहोस्',
                Icons.do_not_disturb,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Foods to Limit Section
          _buildSectionCard(
            title: 'Foods to Limit / सीमित गर्नुपर्ने खाना',
            icon: Icons.warning_amber,
            color: Colors.red,
            items: [
              _buildAdviceItem(
                'Reduce salt intake (avoid pickles, snacks)',
                'नुन कम गर्नुहोस् (अचार, स्न्याक्स बेवास्ता)',
                Icons.do_not_disturb_on,
              ),
              _buildAdviceItem(
                'Limit fried and oily foods',
                'भुटेको र तेलको खाना कम गर्नुहोस्',
                Icons.no_food,
              ),
              _buildAdviceItem(
                'Avoid excessive sugar and sweets',
                'अत्यधिक चिनी र मिठाई बेवास्ता गर्नुहोस्',
                Icons.cancel,
              ),
              _buildAdviceItem(
                'Limit processed and packaged foods',
                'प्रशोधित र प्याकेज गरिएको खाना कम गर्नुहोस्',
                Icons.shopping_bag,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Child Nutrition Section
          _buildSectionCard(
            title: 'Child Nutrition / बालपोषण',
            icon: Icons.child_care,
            color: Colors.pink,
            items: [
              _buildAdviceItem(
                'Breastfeed exclusively for 6 months',
                '६ महिनासम्म स्तनपान मात्र गर्नुहोस्',
                Icons.baby_changing_station,
              ),
              _buildAdviceItem(
                'Start complementary foods at 6 months',
                '६ महिनामा पूरक आहार सुरु गर्नुहोस्',
                Icons.lunch_dining,
              ),
              _buildAdviceItem(
                'Give iron supplements if advised',
                'सल्लाह भए फलामको औषधि दिनुहोस्',
                Icons.medication_liquid,
              ),
              _buildAdviceItem(
                'Ensure variety in child meals',
                'बालकको खानामा विविधता सुनिश्चित गर्नुहोस्',
                Icons.diversity_3,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Pregnant Women Nutrition
          _buildSectionCard(
            title: 'Pregnancy Nutrition / गर्भावस्था पोषण',
            icon: Icons.pregnant_woman,
            color: Colors.purple,
            items: [
              _buildAdviceItem(
                'Eat for health, not for two',
                'दुईको लागि होइन, स्वास्थ्यको लागि खानुहोस्',
                Icons.favorite,
              ),
              _buildAdviceItem(
                'Take iron and folic acid daily',
                'दैनिक फलाम र फोलिक एसिड लिनुहोस्',
                Icons.medication,
              ),
              _buildAdviceItem(
                'Eat frequent small meals',
                'बारम्बार थोरै खाना खानुहोस्',
                Icons.restaurant,
              ),
              _buildAdviceItem(
                'Avoid raw/undercooked foods',
                'काँचो/अधपकेको खाना नखानुहोस्',
                Icons.dangerous,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Diabetic Diet
          _buildSectionCard(
            title: 'Diabetic Diet / मधुमेह आहार',
            icon: Icons.bloodtype,
            color: Colors.indigo,
            items: [
              _buildAdviceItem(
                'Control portion sizes',
                'खानाको मात्रा नियन्त्रण गर्नुहोस्',
                Icons.straighten,
              ),
              _buildAdviceItem(
                'Choose whole grains over white rice',
                'सेतो चामल भन्दा रातो चामल रोज्नुहोस्',
                Icons.rice_bowl,
              ),
              _buildAdviceItem(
                'Eat vegetables with every meal',
                'हरेक खानामा तरकारी खानुहोस्',
                Icons.set_meal,
              ),
              _buildAdviceItem(
                'Limit sweet fruits and sweets',
                'मीठो फल र मिठाई सीमित गर्नुहोस्',
                Icons.apple,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Nepali Superfoods
          _buildSectionCard(
            title: 'Nepali Superfoods / नेपाली सुपरफूड',
            icon: Icons.star,
            color: Colors.amber,
            items: [
              _buildAdviceItem(
                'Timur (Sichuan pepper) - Rich in antioxidants',
                'टिमुर - एन्टिअक्सिडेन्टले भरपूर',
                Icons.spa,
              ),
              _buildAdviceItem(
                'Gundruk - Fermented, probiotic-rich',
                'गुन्द्रुक - किण्वित, प्रोबायोटिकयुक्त',
                Icons.eco,
              ),
              _buildAdviceItem(
                'Buckwheat (Phapar) - Gluten-free, protein',
                'फापर - ग्लुटेन-मुक्त, प्रोटिनयुक्त',
                Icons.grain,
              ),
              _buildAdviceItem(
                'Lapsi (Hog Plum) - Vitamin C rich',
                'लप्सी - भिटामिन सीले भरपूर',
                Icons.nature,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Healthy Eating Tips
          _buildTipsCard(),
          
          const SizedBox(height: 16),
          
          // Contact Information
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceItem(String english, String nepali, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  english,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nepali,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 2,
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.green[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  'Quick Tips / छिटो सुझाव',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem('Eat colorful foods for diverse nutrients'),
            _buildTipItem('रङ्गीन खाना खानुहोस् विविध पोषणको लागि'),
            const Divider(height: 20),
            _buildTipItem('Chew slowly and enjoy your meals'),
            _buildTipItem('बिस्तारै चपाउनुहोस् र खानाको मजा लिनुहोस्'),
            const Divider(height: 20),
            _buildTipItem('Cook at home more often'),
            _buildTipItem('घरमा धेरै पकाउनुहोस्'),
            const Divider(height: 20),
            _buildTipItem('Read food labels when buying packaged items'),
            _buildTipItem('प्याकेज खाना किन्दा लेबल पढ्नुहोस्'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  'Need Help? / सहयोग चाहिन्छ?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'For personalized nutrition advice, consult:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'व्यक्तिगत पोषण सल्लाहको लागि परामर्श गर्नुहोस्:',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            _buildContactItem(Icons.local_hospital, 'Nearest Health Post / स्वास्थ्य चौकी'),
            _buildContactItem(Icons.phone, 'Nutrition Helpline: 1660'),
            _buildContactItem(Icons.medical_services, 'Registered Dietitian / दर्ता पोषण विशेषज्ञ'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
