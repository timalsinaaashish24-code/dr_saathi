import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import '../utils/nepali_number_utils.dart';

class NipahVirusAlertScreen extends StatelessWidget {
  const NipahVirusAlertScreen({super.key});

  bool _isNepali(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ne';
  }

  @override
  Widget build(BuildContext context) {
    final isNepali = _isNepali(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isNepali ? 'निपाह भाइरस अलर्ट' : 'Nipah Virus Alert'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Critical Alert Banner
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 48,
                          color: Colors.red[700],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isNepali ? 'गम्भीर स्वास्थ्य चेतावनी' : 'Critical Health Alert',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isNepali ? 'जनवरी २०२६ अद्यावधिक' : 'January 2026 Update',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isNepali 
                        ? 'पश्चिम बंगाल, भारतमा निपाह भाइरसको प्रकोप पुष्टि भएको छ। नेपाल उच्च सतर्कतामा छ। नेपाल र भारत बीचको खुल्ला सीमाना र फल चमेरोको उपस्थितिले नेपाललाई जोखिममा राख्छ।'
                        : 'Nipah virus outbreak confirmed in West Bengal, India. Nepal is on high alert. The open border between Nepal and India, along with the presence of fruit bats, puts Nepal at risk.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.red[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Current Situation
            _buildSectionTitle(isNepali ? 'वर्तमान स्थिति (जनवरी २०२६)' : 'Current Situation (January 2026)', Icons.coronavirus),
            _buildInfoCard(
              title: isNepali ? 'भारतमा प्रकोप' : 'Outbreak in India',
              content: isNepali 
                ? '''• पश्चिम बंगालमा ${NepaliNumberUtils.formatNumber('2', true)} पुष्टि केसहरू
• दुबै स्वास्थ्यकर्मी गहन हेरचाह इकाईमा
• ${NepaliNumberUtils.formatNumber('196', true)} सम्पर्कहरू नकारात्मक परीक्षण
• भारत सरकारले प्रकोप नियन्त्रणमा रहेको घोषणा गरेको
• केरलमा ${NepaliNumberUtils.formatNumber('2025', true)} मा ${NepaliNumberUtils.formatNumber('4', true)} केस (${NepaliNumberUtils.formatNumber('2', true)} मृत्यु)'''
                : '''• 2 confirmed cases in West Bengal
• Both healthcare workers in intensive care
• 196 contacts tested negative
• Indian government declared outbreak contained
• Kerala reported 4 cases in 2025 (2 deaths)''',
              color: Colors.red,
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoCard(
              title: isNepali ? 'नेपालमा सतर्कता' : 'Nepal Vigilance',
              content: isNepali 
                ? '''• त्रिभुवन अन्तर्राष्ट्रिय विमानस्थलमा स्क्रिनिङ सुरु
• कोशी प्रदेशमा गहन निगरानी
• सबै भारतीय सीमा बिन्दुहरूमा स्वास्थ्य जाँच
• स्वास्थ्य मन्त्रालयले सचेतना अभियान सुरु गरेको
• देशभर ${NepaliNumberUtils.formatNumber('119', true)} प्रयोगशालाहरू परीक्षण गर्न तयार
• कुनै पनि केस नेपालमा रिपोर्ट गरिएको छैन'''
                : '''• Screening started at Tribhuvan International Airport
• Intensive surveillance in Koshi Province
• Health checks at all Indian border points
• Health Ministry launched awareness campaign
• 119 laboratories across country ready for testing
• No cases reported in Nepal yet''',
              color: Colors.orange,
            ),
            
            const SizedBox(height: 16),
            
            // What is Nipah Virus
            _buildSectionTitle(isNepali ? 'निपाह भाइरस के हो?' : 'What is Nipah Virus?', Icons.biotech),
            _buildInfoCard(
              title: isNepali ? 'आधारभूत जानकारी' : 'Basic Information',
              content: isNepali 
                ? '''• पहिलो पटक ${NepaliNumberUtils.formatNumber('1999', true)} मा मलेसिया र सिंगापुरमा पत्ता लागेको
• जुनोटिक रोग (जनावरबाट मानिसमा फैलिने)
• प्राकृतिक होस्ट: फल चमेरो (Pteropus प्रजाति)
• कुनै खोप वा विशेष उपचार छैन
• मृत्यु दर: ${NepaliNumberUtils.formatNumber('40-75', true)}%
• WHO द्वारा उच्च प्राथमिकता रोगजनक घोषित'''
                : '''• First identified in 1999 in Malaysia and Singapore
• Zoonotic disease (spreads from animals to humans)
• Natural host: Fruit bats (Pteropus species)
• No vaccine or specific treatment available
• Fatality rate: 40-75%
• Designated high-priority pathogen by WHO''',
              color: Colors.blue,
            ),
            
            const SizedBox(height: 16),
            
            // Symptoms
            _buildSectionTitle(isNepali ? 'लक्षणहरू' : 'Symptoms', Icons.medical_information),
            _buildInfoCard(
              title: isNepali ? 'सामान्य लक्षणहरू (${NepaliNumberUtils.formatNumber('3-14', true)} दिन भित्र)' : 'Common Symptoms (Within 3-14 days)',
              content: isNepali 
                ? '''प्रारम्भिक लक्षण:
• उच्च ज्वरो
• टाउको दुख्ने
• मांसपेशी दुख्ने
• घाँटी दुख्ने
• खोकी
• सास फेर्न गाह्रो हुनु

गम्भीर लक्षण (तुरुन्त अस्पताल जानुहोस्):
• भ्रम वा असामान्य व्यवहार
• अत्यधिक निद्रा
• दौरा पर्नु
• बोल्न गाह्रो हुनु
• चेतना घट्नु
• मस्तिष्क सूजन (एन्सेफलाइटिस)'''
                : '''Early Symptoms:
• High fever
• Headache
• Muscle aches
• Sore throat
• Cough
• Difficulty breathing

Severe Symptoms (Seek immediate medical care):
• Confusion or unusual behavior
• Excessive sleepiness
• Seizures
• Difficulty speaking
• Reduced consciousness
• Brain inflammation (encephalitis)''',
              color: Colors.purple,
            ),
            
            const SizedBox(height: 16),
            
            // How It Spreads
            _buildSectionTitle(isNepali ? 'कसरी फैलिन्छ?' : 'How Does It Spread?', Icons.share),
            _buildInfoCard(
              title: isNepali ? 'सङ्क्रमण मार्गहरू' : 'Transmission Routes',
              content: isNepali 
                ? '''जनावरबाट मानिसमा:
• संक्रमित चमेराबाट दूषित फलफूल खाँदा
• चमेराको पिसाब, लार, वा मलले दूषित खाना
• संक्रमित जनावर (सुँगुर, घोडा, बाख्रा) संग सम्पर्क

मानिसबाट मानिसमा:
• संक्रमित व्यक्तिसँग नजिकको सम्पर्क
• शरीरको तरल पदार्थ (रगत, लार, पिसाब)
• स्वास्थ्यकर्मीहरू उच्च जोखिममा
• परिवारका सदस्य र हेरचाह गर्नेहरू जोखिममा'''
                : '''Animal to Human:
• Eating fruit contaminated by infected bats
• Food contaminated with bat urine, saliva, or feces
• Contact with infected animals (pigs, horses, goats)

Human to Human:
• Close contact with infected person
• Body fluids (blood, saliva, urine)
• Healthcare workers at high risk
• Family members and caregivers at risk''',
              color: Colors.teal,
            ),
            
            const SizedBox(height: 16),
            
            // Prevention Measures
            _buildSectionTitle(isNepali ? 'रोकथाम उपायहरू' : 'Prevention Measures', Icons.health_and_safety),
            _buildInfoCard(
              title: isNepali ? 'आफूलाई कसरी बचाउने' : 'How to Protect Yourself',
              content: isNepali 
                ? '''खानेकुराको सुरक्षा:
✓ फलफूल राम्रोसँग धोएर र बोक्रा फुकालेर खानुहोस्
✓ भुइँमा परेको फल नखानुहोस्
✓ आधा खाइएको वा चमेराले छोएको फल नखानुहोस्
✓ कच्चा खजुरको रस नपिउनुहोस् (उमालेर मात्र पिउनुहोस्)

सामान्य सावधानी:
✓ चमेरो र तिनीहरूको बासस्थानबाट टाढा रहनुहोस्
✓ बिरामी जनावरलाई नछुनुहोस्
✓ नियमित रूपमा हात धुनुहोस्
✓ बिरामी व्यक्तिबाट सुरक्षित दूरी राख्नुहोस्
✓ मास्क लगाउनुहोस् यदि बिरामीको हेरचाह गर्दै हुनुहुन्छ

यात्रा सावधानी:
✓ पश्चिम बंगालबाट आउँदा सजग रहनुहोस्
✓ लक्षण देखिएमा तुरुन्त स्वास्थ्य सुविधामा जानुहोस्
✓ आफ्नो यात्रा इतिहास डाक्टरलाई बताउनुहोस्'''
                : '''Food Safety:
✓ Wash fruits thoroughly and peel before eating
✓ Do not eat fruits found on the ground
✓ Avoid fruits that appear partially eaten by animals
✓ Do not drink raw date palm sap (boil first if consuming)

General Precautions:
✓ Avoid contact with bats and their habitats
✓ Do not touch sick animals
✓ Wash hands regularly with soap
✓ Maintain safe distance from sick persons
✓ Wear masks if caring for sick patients

Travel Precautions:
✓ Stay alert if traveling from West Bengal
✓ Seek medical care immediately if symptoms appear
✓ Inform doctor about your travel history''',
              color: Colors.green,
            ),
            
            const SizedBox(height: 16),
            
            // For Healthcare Workers
            _buildSectionTitle(isNepali ? 'स्वास्थ्यकर्मीहरूका लागि' : 'For Healthcare Workers', Icons.local_hospital),
            _buildInfoCard(
              title: isNepali ? 'विशेष सावधानी' : 'Special Precautions',
              content: isNepali 
                ? '''उच्च जोखिम प्रक्रियाहरू:
• इन्ट्युबेशन (वायु मार्ग व्यवस्थापन)
• एयरोसोल उत्पन्न गर्ने प्रक्रियाहरू
• शंकास्पद केससँग प्रत्यक्ष सम्पर्क

आवश्यक व्यक्तिगत सुरक्षा उपकरण:
✓ N95 वा उच्च स्तरको मास्क
✓ फेस शील्ड वा गोगल
✓ गाउन र दस्ताने
✓ एयरबोर्न र ड्रपलेट सावधानी

रिपोर्टिङ:
• अचानक मृत्यु तुरुन्त रिपोर्ट गर्नुहोस्
• निपाह जस्तो लक्षण भएका बिरामीहरू रिपोर्ट गर्नुहोस्
• रोग नियन्त्रण विभागलाई सम्पर्क गर्नुहोस्'''
                : '''High-Risk Procedures:
• Intubation (airway management)
• Aerosol-generating procedures
• Direct contact with suspected cases

Required Personal Protective Equipment:
✓ N95 or higher-grade masks
✓ Face shield or goggles
✓ Gowns and gloves
✓ Airborne and droplet precautions

Reporting:
• Report sudden deaths immediately
• Report patients with Nipah-like symptoms
• Contact Epidemiology and Disease Control Division''',
              color: Colors.indigo,
            ),
            
            const SizedBox(height: 16),
            
            // Emergency Contacts
            _buildSectionTitle(isNepali ? 'आपतकालीन सम्पर्क' : 'Emergency Contacts', Icons.phone),
            _buildContactCard(
              title: isNepali ? 'रोग नियन्त्रण विभाग' : 'Epidemiology and Disease Control Division',
              phone: '01-4261942',
              description: isNepali ? 'संदिग्ध केस रिपोर्ट गर्न' : 'Report suspected cases',
            ),
            
            const SizedBox(height: 12),
            
            _buildContactCard(
              title: isNepali ? 'राष्ट्रिय आपतकालीन नम्बर' : 'National Emergency Number',
              phone: '102',
              description: isNepali ? 'चिकित्सा आपतकालीन र एम्बुलेन्स' : 'Medical emergency and ambulance',
            ),
            
            const SizedBox(height: 12),
            
            _buildContactCard(
              title: isNepali ? 'शुक्रराज ट्रपिकल अस्पताल' : 'Shukraraj Tropical Hospital',
              phone: '01-4253355',
              description: isNepali ? 'संक्रामक रोग विशेषज्ञ' : 'Infectious disease specialists',
            ),
            
            const SizedBox(height: 24),
            
            // Important Notice
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, color: Colors.amber[900]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isNepali ? 'महत्वपूर्ण सूचना' : 'Important Notice',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[900],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isNepali 
                              ? 'यदि तपाईंले ज्वरो, टाउको दुख्ने, र भ्रम जस्ता लक्षणहरू अनुभव गर्नुभयो भने, विशेष गरी यदि तपाईं भारतबाट फर्केर आउनुभएको छ भने, तुरुन्त नजिकको स्वास्थ्य सुविधामा जानुहोस्। आफ्नो यात्रा इतिहास डाक्टरलाई अनिवार्य रूपमा बताउनुहोस्। यो जीवनरक्षक हुन सक्छ।'
                              : 'If you experience fever, headache, and confusion, especially if you have recently returned from India, seek immediate medical care at the nearest health facility. Inform the doctor about your travel history. This could be life-saving.',
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Last Updated
            Center(
              child: Text(
                isNepali 
                  ? 'अन्तिम अद्यावधिक: जनवरी २९, २०२६'
                  : 'Last Updated: January 29, 2026',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactCard({
    required String title,
    required String phone,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
