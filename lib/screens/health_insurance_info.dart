import 'package:flutter/material.dart';
import 'package:dr_saathi/generated/l10n/app_localizations.dart';
import '../utils/nepali_number_utils.dart';

class HealthInsuranceInfoScreen extends StatelessWidget {
  const HealthInsuranceInfoScreen({super.key});

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
        title: Text(isNepali ? 'नेपालमा स्वास्थ्य बीमा' : 'Health Insurance in Nepal'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              color: Colors.lightBlue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 48,
                      color: Colors.lightBlue[700],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isNepali ? 'स्वास्थ्य बीमा जानकारी' : 'Health Insurance Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isNepali ? 'नवीनतम जानकारी (२०२६)' : 'Latest updates (2026)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.lightBlue[700],
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
            
            // 2026 Updates Card
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.update, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          isNepali ? '२०२६ मा नयाँ घोषणाहरू' : '2026 New Announcements',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isNepali ? '''✓ ${NepaliNumberUtils.formatNumber('1', true)} करोड भन्दा बढी मानिसहरू अब बीमाद्वारा सुरक्षित
✓ दैनिक लगभग ${NepaliNumberUtils.formatNumber('50,000', true)} मानिसहरूले सेवा प्रयोग गर्दै
✓ आर्थिक वर्ष ${NepaliNumberUtils.formatNumber('2025-26', true)} को लागि रू. ${NepaliNumberUtils.formatNumber('10', true)} अर्ब बजेट
✓ कार्यक्रम पुनर्संरचना र सुधार जारी
✓ लाभ सीमा क्रमिक रूपमा बढाइने योजना''' : '''✓ Over 10 million people now covered by insurance
✓ Approximately 50,000 people use services daily
✓ Rs. 10 billion budget allocated for fiscal year 2025-26
✓ Program restructuring and reforms underway
✓ Plans to gradually increase benefit caps''',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.8,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Current Program Status
            _buildSectionTitle(isNepali ? 'वर्तमान स्थिति र चुनौतीहरू' : 'Current Status & Challenges'),
            _buildInfoCard(
              title: isNepali ? 'कार्यान्वयन अद्यावधिक' : 'Implementation Update',
              content: isNepali ? '''राष्ट्रिय स्वास्थ्य बीमा कार्यक्रम स्थिरता चुनौतीहरूको सामना गर्दै:

• अस्पतालहरूलाई रू. ${NepaliNumberUtils.formatNumber('40', true)} करोड बकाया भुक्तानी
• केही अस्पतालहरूले कार्यक्रमबाट बाहिरिने चेतावनी
• सरकारले ${NepaliNumberUtils.formatNumber('2025-26', true)} मा सुधार प्रतिबद्धता व्यक्त गरेको
• औपचारिक क्षेत्रबाट अनिवार्य दर्ता सुरु गर्ने योजना
• असुविधाग्रस्त समूहका लागि नि:शुल्क कभरेज जारी रहने''' : '''National Health Insurance Program facing sustainability challenges:

• Rs. 400 million in unpaid dues to hospitals
• Some hospitals threatening to opt out of the program
• Government committed to reforms in 2025-26
• Plans for mandatory enrollment starting from formal sector
• Free coverage to continue for disadvantaged groups''',
              color: Colors.orange,
            ),
            
            const SizedBox(height: 16),
            
            // Government Health Insurance Program
            _buildSectionTitle(isNepali ? 'सरकारी स्वास्थ्य बीमा कार्यक्रम' : 'Government Health Insurance Program'),
            _buildInfoCard(
              title: isNepali ? 'स्वास्थ्य बीमा बोर्ड नेपाल' : 'Health Insurance Board Nepal',
              content: isNepali ? '''स्वास्थ्य बीमा बोर्ड ${NepaliNumberUtils.formatNumber('2016', true)} मा स्वास्थ्य बीमा ऐन ${NepaliNumberUtils.formatNumber('2017', true)} अन्तर्गत नेपालमा स्वास्थ्य बीमा योजनाहरू लागू र नियमन गर्न स्थापना गरिएको थियो।

मुख्य विशेषताहरू (${NepaliNumberUtils.formatNumber('2026', true)}):
• प्रिमियम: रू. ${NepaliNumberUtils.formatNumber('3,500', true)} प्रति परिवार प्रति वर्ष
• कभरेज: रू. ${NepaliNumberUtils.formatNumber('100,000', true)} सम्म प्रति परिवार प्रति वर्ष
• समावेश: आन्तरिक रोगी, बाह्य रोगी, आकस्मिक सेवाहरू
• नेपालका सबै ${NepaliNumberUtils.formatNumber('77', true)} जिल्लामा उपलब्ध
• ${NepaliNumberUtils.formatNumber('1', true)} करोड+ बीमाकृत व्यक्तिहरू

योग्य सेवाहरू:
✓ अस्पताल खर्च
✓ शल्यक्रिया प्रक्रियाहरू
✓ मातृत्व सेवा
✓ आवश्यक औषधिहरू
✓ निदान परीक्षणहरू
✓ आकस्मिक उपचार''' : '''The Health Insurance Board was established in 2016 under the Health Insurance Act 2017 to implement and regulate health insurance schemes in Nepal.

Key Features (2026):
• Premium: Rs. 3,500 per family per year
• Coverage: Up to Rs. 100,000 per family per year
• Covers: Inpatient, outpatient, emergency services
• Available in all 77 districts of Nepal
• 10+ million insured individuals

Eligible Services:
✓ Hospitalization costs
✓ Surgical procedures
✓ Maternity care
✓ Essential medicines
✓ Diagnostic tests
✓ Emergency treatment''',
              color: Colors.blue,
            ),
            
            const SizedBox(height: 16),
            
            // Social Health Security Program
            _buildSectionTitle(isNepali ? 'सामाजिक स्वास्थ्य सुरक्षा कार्यक्रम (SHSP)' : 'Social Health Security Program (SHSP)'),
            _buildInfoCard(
              title: isNepali ? 'औपचारिक क्षेत्रका लागि अनिवार्य' : 'Mandatory for Formal Sector',
              content: isNepali ? '''संगठित क्षेत्रका कर्मचारीहरूका लागि सामाजिक सुरक्षा कोष द्वारा लागू गरिएको।

योगदान:
• कर्मचारी: मूल तलबको ${NepaliNumberUtils.formatNumber('2.5', true)}%
• रोजगारदाता: मूल तलबको ${NepaliNumberUtils.formatNumber('2.5', true)}%
• जम्मा: मूल तलबको ${NepaliNumberUtils.formatNumber('5', true)}%

कभरेज लाभहरू:
• आन्तरिक रोगी सेवा रू. ${NepaliNumberUtils.formatNumber('100,000', true)}/वर्ष सम्म
• बाह्य रोगी सेवाहरू
• मातृत्व लाभहरू
• गम्भीर रोग कभरेज
• शल्यक्रिया प्रक्रियाहरू
• औषधि र निदान

सुविधाहरू: नेपालभरिका सूचीकृत अस्पतालहरूमा उपलब्ध''' : '''Implemented by the Social Security Fund for employees in the organized sector.

Contribution:
• Employee: 2.5% of basic salary
• Employer: 2.5% of basic salary
• Total: 5% of basic salary

Coverage Benefits:
• Inpatient care up to Rs. 100,000/year
• Outpatient services
• Maternity benefits
• Critical illness coverage
• Surgical procedures
• Medicines and diagnostics

Facilities: Available at empaneled hospitals across Nepal''',
              color: Colors.green,
            ),
            
            const SizedBox(height: 16),
            
            // Private Health Insurance
            _buildSectionTitle(isNepali ? 'निजी स्वास्थ्य बीमा प्रदायकहरू' : 'Private Health Insurance Providers'),
            _buildInfoCard(
              title: isNepali ? 'प्रमुख बीमा कम्पनीहरू' : 'Major Insurance Companies',
              content: isNepali ? '''नेपालका प्रमुख निजी स्वास्थ्य बीमा प्रदायकहरू:

${NepaliNumberUtils.formatNumber('1', true)}. नेपाल लाइफ इन्सुरेन्स कम्पनी
   • व्यक्तिगत र पारिवारिक योजनाहरू
   • नेटवर्क अस्पतालहरूमा नगद रहित उपचार
   • कभरेज: रू. ${NepaliNumberUtils.formatNumber('50,000', true)} - रू. ${NepaliNumberUtils.formatNumber('5,00,000', true)}

${NepaliNumberUtils.formatNumber('2', true)}. एसियन लाइफ इन्सुरेन्स कम्पनी
   • गम्भीर रोग कभरेज
   • मातृत्व लाभहरू
   • अन्तर्राष्ट्रिय कभरेज विकल्पहरू

${NepaliNumberUtils.formatNumber('3', true)}. राष्ट्रिय जीवन बीमा कम्पनी
   • स्वास्थ्य र जीवन बीमा
   • ज्येष्ठ नागरिक योजनाहरू
   • रोकथाम स्वास्थ्य जाँच

${NepaliNumberUtils.formatNumber('4', true)}. रिलायन्स लाइफ इन्सुरेन्स
   • व्यापक स्वास्थ्य योजनाहरू
   • दन्त र नेत्र कभरेज
   • वार्षिक स्वास्थ्य जाँच''' : '''Leading private health insurance providers in Nepal:

1. Nepal Life Insurance Company
   • Individual and family plans
   • Cashless treatment at network hospitals
   • Coverage: Rs. 50,000 - Rs. 5,00,000

2. Asian Life Insurance Company
   • Critical illness coverage
   • Maternity benefits
   • International coverage options

3. National Life Insurance Company
   • Health plus life insurance
   • Senior citizen plans
   • Preventive health checkups

4. Reliance Life Insurance
   • Comprehensive health plans
   • Dental and optical coverage
   • Annual health screening''',
              color: Colors.purple,
            ),
            
            const SizedBox(height: 16),
            
            // Free Healthcare Services
            _buildSectionTitle(isNepali ? 'नि:शुल्क स्वास्थ्य सेवाहरू' : 'Free Healthcare Services'),
            _buildInfoCard(
              title: isNepali ? 'सरकारी नि:शुल्क सेवाहरू' : 'Government Free Services',
              content: isNepali ? '''नेपाल सरकारले प्रदान गरेको नि:शुल्क स्वास्थ्य सेवाहरू:

प्राथमिक स्वास्थ्य सेवा:
✓ स्वास्थ्य चौकीहरूमा नि:शुल्क सेवाहरू
✓ आधारभूत स्वास्थ्य जाँच
✓ खोप कार्यक्रमहरू
✓ परिवार नियोजन सेवाहरू

मातृ स्वास्थ्य:
✓ नि:शुल्क प्रसव सेवाहरू
✓ प्रसवपूर्व र प्रसवपछि सेवा
✓ सुरक्षित मातृत्व कार्यक्रमहरू
• प्रोत्साहन: संस्थागत प्रसवका लागि रू. ${NepaliNumberUtils.formatNumber('2,000', true)}-${NepaliNumberUtils.formatNumber('3,000', true)}

ज्येष्ठ नागरिकहरू (${NepaliNumberUtils.formatNumber('75', true)}+ वर्ष):
✓ सरकारी सुविधाहरूमा नि:शुल्क स्वास्थ्य सेवा
✓ नि:शुल्क आवश्यक औषधिहरू
✓ प्राथमिकता उपचार

बालबालिकाहरू (${NepaliNumberUtils.formatNumber('5', true)} वर्ष मुनि):
✓ सरकारी अस्पतालहरूमा नि:शुल्क उपचार
✓ नि:शुल्क खोप र पोषण कार्यक्रमहरू''' : '''Free healthcare services provided by the Government of Nepal:

Primary Healthcare:
✓ Free services at health posts
✓ Basic health checkups
✓ Immunization programs
✓ Family planning services

Maternal Health:
✓ Free delivery services
✓ Antenatal and postnatal care
✓ Safe motherhood programs
✓ Incentives: Rs. 2,000-3,000 for institutional delivery

Senior Citizens (75+ years):
✓ Free healthcare at government facilities
✓ Free essential medicines
✓ Priority treatment

Children (Under 5):
✓ Free treatment at government hospitals
✓ Free vaccines and nutrition programs''',
              color: Colors.teal,
            ),
            
            const SizedBox(height: 16),
            
            // How to Enroll
            _buildSectionTitle(isNepali ? 'कसरी दर्ता गर्ने' : 'How to Enroll'),
            _buildInfoCard(
              title: isNepali ? 'दर्ता प्रक्रिया' : 'Enrollment Process',
              content: isNepali ? '''सरकारी स्वास्थ्य बीमाका लागि:

चरण ${NepaliNumberUtils.formatNumber('1', true)}: नजिकको स्वास्थ्य सुविधा वा वडा कार्यालयमा जानुहोस्
चरण ${NepaliNumberUtils.formatNumber('2', true)}: पारिवारिक विवरणसहित दर्ता फारम भर्नुहोस्
चरण ${NepaliNumberUtils.formatNumber('3', true)}: आवश्यक कागजातहरू बुझाउनुहोस्:
   • नागरिकता प्रमाणपत्र
   • परिवारका सदस्यहरूको तस्बिर
   • सम्पर्क जानकारी

चरण ${NepaliNumberUtils.formatNumber('4', true)}: वार्षिक प्रिमियम तिर्नुहोस् (रू. ${NepaliNumberUtils.formatNumber('3,500', true)})
चरण ${NepaliNumberUtils.formatNumber('5', true)}: स्वास्थ्य बीमा कार्ड प्राप्त गर्नुहोस्

अनलाइन दर्ता:
भेट गर्नुहोस्: www.hib.gov.np
वा डाउनलोड गर्नुहोस्: स्वास्थ्य बीमा बोर्ड मोबाइल एप

SHSP का लागि:
• औपचारिक क्षेत्रका कर्मचारीहरूको लागि स्वचालित दर्ता
• भेट गर्नुहोस्: www.ssf.gov.np
• रोजगारदाताको मानव संसाधन विभागलाई सम्पर्क गर्नुहोस्''' : '''For Government Health Insurance:

Step 1: Visit nearest health facility or ward office
Step 2: Fill enrollment form with family details
Step 3: Submit required documents:
   • Citizenship certificate
   • Family member photos
   • Contact information

Step 4: Pay annual premium (Rs. 3,500)
Step 5: Receive health insurance card

Online Enrollment:
Visit: www.hib.gov.np
Or download: Health Insurance Board mobile app

For SHSP:
• Automatic enrollment for formal sector employees
• Visit: www.ssf.gov.np
• Contact employer's HR department''',
              color: Colors.orange,
            ),
            
            const SizedBox(height: 16),
            
            // Contact Information
            _buildSectionTitle(isNepali ? 'सम्पर्क जानकारी' : 'Contact Information'),
            _buildContactCard(
              title: isNepali ? 'स्वास्थ्य बीमा बोर्ड' : 'Health Insurance Board',
              phone: '01-5970180, 01-5970181',
              email: 'info@hib.gov.np',
              website: 'www.hib.gov.np',
              address: 'Teku, Kathmandu',
            ),
            
            const SizedBox(height: 12),
            
            _buildContactCard(
              title: isNepali ? 'सामाजिक सुरक्षा कोष' : 'Social Security Fund',
              phone: '01-5340804',
              email: 'info@ssf.gov.np',
              website: 'www.ssf.gov.np',
              address: 'Babarmahal, Kathmandu',
            ),
            
            const SizedBox(height: 12),
            
            _buildContactCard(
              title: isNepali ? 'स्वास्थ्य मन्त्रालय' : 'Ministry of Health',
              phone: '01-4262802',
              email: 'info@mohp.gov.np',
              website: 'www.mohp.gov.np',
              address: 'Ramshah Path, Kathmandu',
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
                            isNepali ? 'जानकारी परिवर्तन हुन सक्छ। कृपया सबैभन्दा हालको विवरण र योग्यता मापदण्डका लागि सम्बन्धित संस्थाहरूसँग प्रमाणित गर्नुहोस्। सरकारले ${NepaliNumberUtils.formatNumber('2025-26', true)} मा कार्यक्रम पुनर्संरचना गर्दैछ। अद्यावधिक जानकारीका लागि www.hib.gov.np भेट गर्नुहोस्।' : 'Information is subject to change. Please verify with respective organizations for the most current details and eligibility criteria. The government is restructuring the program in 2025-26. Visit www.hib.gov.np for the latest updates.',
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
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
    required String email,
    required String website,
    required String address,
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
            const SizedBox(height: 12),
            _buildContactRow(Icons.phone, phone),
            const SizedBox(height: 8),
            _buildContactRow(Icons.email, email),
            const SizedBox(height: 8),
            _buildContactRow(Icons.language, website),
            const SizedBox(height: 8),
            _buildContactRow(Icons.location_on, address),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
