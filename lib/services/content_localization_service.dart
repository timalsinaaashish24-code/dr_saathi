import 'package:flutter/material.dart';
import '../models/emergency_service.dart';

class ContentLocalizationService {
  static String getCurrentLanguage(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  // Localized Emergency Services
  static List<EmergencyService> getLocalizedEmergencyServices(BuildContext context) {
    final isNepali = getCurrentLanguage(context) == 'ne';
    
    return [
      // National Emergency Numbers
      EmergencyService(
        id: 'gov_100',
        name: isNepali ? 'नेपाल प्रहरी सेवा' : 'Nepal Police Emergency',
        type: isNepali ? 'प्रहरी' : 'Police',
        phoneNumber: '100',
        address: isNepali ? 'राष्ट्रव्यापी' : 'Nationwide',
        city: isNepali ? 'सबै शहरहरू' : 'All Cities',
        province: isNepali ? 'सबै प्रदेशहरू' : 'All Provinces',
        services: isNepali 
            ? ['प्रहरी सेवा', 'अपराध रिपोर्टिंग', 'सेवा प्रतिक्रिया']
            : ['Police Emergency', 'Crime Reporting', 'Emergency Response'],
        isAvailable24x7: true,
        isGovernment: true,
        vehicleTypes: isNepali ? ['प्रहरी गाडी'] : ['Police Vehicle'],
        emergencyCode: '100',
        description: isNepali 
            ? 'सबै प्रकारका सेवा अवस्थाहरूको लागि नेपाल प्रहरीको सेवा हटलाइन'
            : 'Nepal Police emergency hotline for all types of emergencies',
      ),
      EmergencyService(
        id: 'gov_102',
        name: isNepali ? 'नेपाल चिकित्सा सेवा' : 'Nepal Medical Emergency',
        type: isNepali ? 'चिकित्सा सेवा' : 'Medical Emergency',
        phoneNumber: '102',
        address: isNepali ? 'राष्ट्रव्यापी' : 'Nationwide',
        city: isNepali ? 'सबै शहरहरू' : 'All Cities',
        province: isNepali ? 'सबै प्रदेशहरू' : 'All Provinces',
        services: isNepali 
            ? ['चिकित्सा सेवा', 'एम्बुलेन्स सेवा', 'सेवा चिकित्सा हेरचाह']
            : ['Medical Emergency', 'Ambulance Service', 'Emergency Medical Care'],
        isAvailable24x7: true,
        isGovernment: true,
        vehicleTypes: isNepali ? ['एम्बुलेन्स'] : ['Ambulance'],
        emergencyCode: '102',
        description: isNepali 
            ? 'राष्ट्रिय चिकित्सा सेवा र एम्बुलेन्स सेवा'
            : 'National medical emergency and ambulance service',
      ),
      EmergencyService(
        id: 'gov_103',
        name: isNepali ? 'नेपाल दमकल सेवा' : 'Nepal Fire Service',
        type: isNepali ? 'दमकल सेवा' : 'Fire Service',
        phoneNumber: '103',
        address: isNepali ? 'राष्ट्रव्यापी' : 'Nationwide',
        city: isNepali ? 'सबै शहरहरू' : 'All Cities',
        province: isNepali ? 'सबै प्रदेशहरू' : 'All Provinces',
        services: isNepali 
            ? ['आगो सेवा', 'उद्धार कार्यहरू', 'विपद् प्रतिक्रिया']
            : ['Fire Emergency', 'Rescue Operations', 'Disaster Response'],
        isAvailable24x7: true,
        isGovernment: true,
        vehicleTypes: isNepali ? ['दमकल गाडी', 'उद्धार गाडी'] : ['Fire Truck', 'Rescue Vehicle'],
        emergencyCode: '103',
        description: isNepali 
            ? 'आगो सेवा र उद्धार कार्यहरूको लागि नेपाल दमकल सेवा'
            : 'Nepal Fire Service for fire emergencies and rescue operations',
      ),

      // Kathmandu Valley Ambulance Services
      EmergencyService(
        id: 'ktm_001',
        name: isNepali ? 'वीर अस्पताल एम्बुलेन्स' : 'Bir Hospital Ambulance',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-1-422-1119',
        alternatePhone: '+977-1-422-3807',
        address: isNepali ? 'महाबौद्ध, काठमाडौं' : 'Mahaboudha, Kathmandu',
        city: isNepali ? 'काठमाडौं' : 'Kathmandu',
        province: isNepali ? 'बागमती' : 'Bagmati',
        latitude: 27.7019,
        longitude: 85.3137,
        services: isNepali 
            ? ['आधारभूत जीवन सहयोग', 'उन्नत जीवन सहयोग', 'आपातकालीन यातायात']
            : ['Basic Life Support', 'Advanced Life Support', 'Emergency Transport'],
        isAvailable24x7: true,
        isGovernment: true,
        vehicleTypes: isNepali ? ['आधारभूत एम्बुलेन्स', 'उन्नत एम्बुलेन्स'] : ['Basic Ambulance', 'Advanced Ambulance'],
        description: isNepali 
            ? 'सरकारी अस्पतालको एम्बुलेन्स सेवा'
            : 'Government hospital ambulance service',
        rating: 4.2,
      ),
      EmergencyService(
        id: 'ktm_002',
        name: isNepali ? 'त्रि.वि. शिक्षण अस्पताल एम्बुलेन्स' : 'TU Teaching Hospital Ambulance',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-1-441-2505',
        alternatePhone: '+977-1-441-4142',
        address: isNepali ? 'महाराजगञ्ज, काठमाडौं' : 'Maharajgunj, Kathmandu',
        city: isNepali ? 'काठमाडौं' : 'Kathmandu',
        province: isNepali ? 'बागमती' : 'Bagmati',
        latitude: 27.7394,
        longitude: 85.3336,
        services: isNepali 
            ? ['उन्नत जीवन सहयोग', 'आघात हेरचाह', 'आईसीयू यातायात']
            : ['Advanced Life Support', 'Trauma Care', 'ICU Transport'],
        isAvailable24x7: true,
        isGovernment: true,
        vehicleTypes: isNepali ? ['आईसीयू एम्बुलेन्स', 'उन्नत एम्बुलेन्स'] : ['ICU Ambulance', 'Advanced Ambulance'],
        description: isNepali 
            ? 'शिक्षण अस्पतालको विशेषज्ञ एम्बुलेन्स सेवा'
            : 'Teaching hospital specialized ambulance service',
        rating: 4.5,
      ),
      EmergencyService(
        id: 'ktm_003',
        name: isNepali ? 'नेपाल रेडक्रस एम्बुलेन्स' : 'Nepal Red Cross Ambulance',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-1-427-0650',
        alternatePhone: '+977-1-427-0867',
        address: isNepali ? 'कालीमाटी, काठमाडौं' : 'Kalimati, Kathmandu',
        city: isNepali ? 'काठमाडौं' : 'Kathmandu',
        province: isNepali ? 'बागमती' : 'Bagmati',
        latitude: 27.6966,
        longitude: 85.2938,
        services: isNepali 
            ? ['आधारभूत जीवन सहयोग', 'आपातकालीन यातायात', 'विपद् प्रतिक्रिया']
            : ['Basic Life Support', 'Emergency Transport', 'Disaster Response'],
        isAvailable24x7: true,
        isGovernment: false,
        isPrivate: false,
        vehicleTypes: isNepali ? ['आधारभूत एम्बुलेन्स', 'आपातकालीन भ्यान'] : ['Basic Ambulance', 'Emergency Van'],
        description: isNepali 
            ? 'रेडक्रस एम्बुलेन्स सेवा'
            : 'Red Cross ambulance service',
        rating: 4.0,
      ),
      EmergencyService(
        id: 'ktm_004',
        name: isNepali ? 'नर्भिक अस्पताल एम्बुलेन्स' : 'Norvic Hospital Ambulance',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-1-425-8554',
        alternatePhone: '+977-1-425-8555',
        address: isNepali ? 'थापाथली, काठमाडौं' : 'Thapathali, Kathmandu',
        city: isNepali ? 'काठमाडौं' : 'Kathmandu',
        province: isNepali ? 'बागमती' : 'Bagmati',
        latitude: 27.6942,
        longitude: 85.3222,
        services: isNepali 
            ? ['उन्नत जीवन सहयोग', 'आईसीयू यातायात', 'मुटु आपातकाल']
            : ['Advanced Life Support', 'ICU Transport', 'Cardiac Emergency'],
        isAvailable24x7: true,
        isPrivate: true,
        vehicleTypes: isNepali ? ['आईसीयू एम्बुलेन्स', 'मुटु एम्बुलेन्स'] : ['ICU Ambulance', 'Cardiac Ambulance'],
        description: isNepali 
            ? 'निजी अस्पतालको विशेषज्ञ एम्बुलेन्स'
            : 'Private hospital specialized ambulance',
        rating: 4.6,
      ),
      EmergencyService(
        id: 'ktm_005',
        name: isNepali ? 'ग्रान्डे अस्पताल एम्बुलेन्स' : 'Grande Hospital Ambulance',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-1-510-0190',
        address: isNepali ? 'धापासी, काठमाडौं' : 'Dhapasi, Kathmandu',
        city: isNepali ? 'काठमाडौं' : 'Kathmandu',
        province: isNepali ? 'बागमती' : 'Bagmati',
        latitude: 27.7500,
        longitude: 85.3500,
        services: isNepali 
            ? ['उन्नत जीवन सहयोग', 'आपातकालीन शल्यक्रिया यातायात']
            : ['Advanced Life Support', 'Emergency Surgery Transport'],
        isAvailable24x7: true,
        isPrivate: true,
        vehicleTypes: isNepali ? ['उन्नत एम्बुलेन्स'] : ['Advanced Ambulance'],
        description: isNepali 
            ? 'निजी अस्पतालको एम्बुलेन्स सेवा'
            : 'Private hospital ambulance service',
        rating: 4.4,
      ),

      // Lalitpur/Patan Ambulance Services
      EmergencyService(
        id: 'ltp_001',
        name: isNepali ? 'पाटन अस्पताल एम्बुलेन्स' : 'Patan Hospital Ambulance',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-1-552-2266',
        alternatePhone: '+977-1-552-1048',
        address: isNepali ? 'लगनखेल, ललितपुर' : 'Lagankhel, Lalitpur',
        city: isNepali ? 'ललितपुर' : 'Lalitpur',
        province: isNepali ? 'बागमती' : 'Bagmati',
        latitude: 27.6662,
        longitude: 85.3149,
        services: isNepali 
            ? ['उन्नत जीवन सहयोग', 'आघात हेरचाह', 'बाल आपातकाल']
            : ['Advanced Life Support', 'Trauma Care', 'Pediatric Emergency'],
        isAvailable24x7: true,
        isGovernment: true,
        vehicleTypes: isNepali ? ['उन्नत एम्बुलेन्स', 'बाल एम्बुलेन्स'] : ['Advanced Ambulance', 'Pediatric Ambulance'],
        description: isNepali 
            ? 'पाटन स्वास्थ्य विज्ञान प्रतिष्ठानको एम्बुलेन्स'
            : 'Patan Academy of Health Sciences ambulance',
        rating: 4.3,
      ),
      EmergencyService(
        id: 'ltp_002',
        name: isNepali ? 'अल्का अस्पताल एम्बुलेन्स' : 'Alka Hospital Ambulance',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-1-553-3266',
        address: isNepali ? 'जावलाखेल, ललितपुर' : 'Jawalakhel, Lalitpur',
        city: isNepali ? 'ललितपुर' : 'Lalitpur',
        province: isNepali ? 'बागमती' : 'Bagmati',
        latitude: 27.6736,
        longitude: 85.3088,
        services: isNepali 
            ? ['आधारभूत जीवन सहयोग', 'आपातकालीन यातायात']
            : ['Basic Life Support', 'Emergency Transport'],
        isAvailable24x7: true,
        isPrivate: true,
        vehicleTypes: isNepali ? ['आधारभूत एम्बुलेन्स'] : ['Basic Ambulance'],
        description: isNepali 
            ? 'निजी अस्पतालको एम्बुलेन्स सेवा'
            : 'Private hospital ambulance service',
        rating: 4.1,
      ),

      // Bhaktapur Ambulance Services
      EmergencyService(
        id: 'bkt_001',
        name: isNepali ? 'भक्तपुर अस्पताल एम्बुलेन्स' : 'Bhaktapur Hospital Ambulance',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-1-661-0798',
        address: isNepali ? 'भक्तपुर नगरपालिका' : 'Bhaktapur Municipality',
        city: isNepali ? 'भक्तपुर' : 'Bhaktapur',
        province: isNepali ? 'बागमती' : 'Bagmati',
        latitude: 27.6710,
        longitude: 85.4298,
        services: isNepali 
            ? ['आधारभूत जीवन सहयोग', 'आपातकालीन यातायात']
            : ['Basic Life Support', 'Emergency Transport'],
        isAvailable24x7: true,
        isGovernment: true,
        vehicleTypes: isNepali ? ['आधारभूत एम्बुलेन्स'] : ['Basic Ambulance'],
        description: isNepali 
            ? 'जिल्ला अस्पतालको एम्बुलेन्स सेवा'
            : 'District hospital ambulance service',
        rating: 3.9,
      ),

      // Pokhara Ambulance Services
      EmergencyService(
        id: 'pkr_001',
        name: isNepali ? 'पोखरा एकेडेमी एम्बुलेन्स' : 'Pokhara Academy Ambulance',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-61-504040',
        alternatePhone: '+977-61-504041',
        address: isNepali ? 'धुङगेपाटन, पोखरा' : 'Dhungepatan, Pokhara',
        city: isNepali ? 'पोखरा' : 'Pokhara',
        province: isNepali ? 'गण्डकी' : 'Gandaki',
        latitude: 28.2096,
        longitude: 83.9856,
        services: isNepali 
            ? ['उन्नत जीवन सहयोग', 'आघात हेरचाह']
            : ['Advanced Life Support', 'Trauma Care'],
        isAvailable24x7: true,
        isGovernment: true,
        vehicleTypes: isNepali ? ['उन्नत एम्बुलेन्स'] : ['Advanced Ambulance'],
        description: isNepali 
            ? 'पोखरा स्वास्थ्य विज्ञान प्रतिष्ठानको एम्बुलेन्स'
            : 'Pokhara Academy of Health Sciences ambulance',
        rating: 4.2,
      ),
      EmergencyService(
        id: 'pkr_002',
        name: isNepali ? 'मणिपाल अस्पताल पोखरा' : 'Manipal Hospital Pokhara',
        type: isNepali ? 'एम्बुलेन्स' : 'Ambulance',
        phoneNumber: '+977-61-526416',
        address: isNepali ? 'फुलबारी, पोखरा' : 'Phulbari, Pokhara',
        city: isNepali ? 'पोखरा' : 'Pokhara',
        province: isNepali ? 'गण्डकी' : 'Gandaki',
        latitude: 28.2380,
        longitude: 83.9956,
        services: isNepali 
            ? ['उन्नत जीवन सहयोग', 'आईसीयू यातायात']
            : ['Advanced Life Support', 'ICU Transport'],
        isAvailable24x7: true,
        isPrivate: true,
        vehicleTypes: isNepali ? ['आईसीयू एम्बुलेन्स'] : ['ICU Ambulance'],
        description: isNepali 
            ? 'आईसीयू सुविधासहितको निजी अस्पतालको एम्बुलेन्स'
            : 'Private hospital ambulance with ICU facilities',
        rating: 4.5,
      ),
    ];
  }

  // Localized Emergency Contacts
  static List<EmergencyContact> getLocalizedEmergencyContacts(BuildContext context) {
    final isNepali = getCurrentLanguage(context) == 'ne';
    
    return [
      EmergencyContact(
        name: isNepali ? 'नेपाल प्रहरी' : 'Nepal Police',
        phoneNumber: '100',
        type: isNepali ? 'प्रहरी आपातकाल' : 'Police Emergency',
        description: isNepali 
            ? 'अपराध, दुर्घटना, र सामान्य आपतकालका लागि'
            : 'For crime, accidents, and general emergencies',
      ),
      EmergencyContact(
        name: isNepali ? 'चिकित्सा आपातकाल' : 'Medical Emergency',
        phoneNumber: '102',
        type: isNepali ? 'चिकित्सा आपातकाल' : 'Medical Emergency',
        description: isNepali 
            ? 'चिकित्सा आपतकाल र एम्बुलेन्सको लागि'
            : 'For medical emergencies and ambulance',
      ),
      EmergencyContact(
        name: isNepali ? 'दमकल सेवा' : 'Fire Service',
        phoneNumber: '103',
        type: isNepali ? 'आगो आपातकाल' : 'Fire Emergency',
        description: isNepali 
            ? 'आगो आपतकाल र उद्धार कार्यहरूको लागि'
            : 'For fire emergencies and rescue operations',
      ),
      EmergencyContact(
        name: isNepali ? 'पर्यटक हेल्पलाइन' : 'Tourist Helpline',
        phoneNumber: '1144',
        type: isNepali ? 'पर्यटक आपातकाल' : 'Tourist Emergency',
        description: isNepali 
            ? 'पर्यटक सम्बन्धी आपतकालका लागि'
            : 'For tourist-related emergencies',
      ),
    ];
  }
}

// Emergency Contact model (if not already defined)
class EmergencyContact {
  final String name;
  final String phoneNumber;
  final String type;
  final String description;

  EmergencyContact({
    required this.name,
    required this.phoneNumber,
    required this.type,
    required this.description,
  });
}
