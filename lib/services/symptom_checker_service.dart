import 'package:uuid/uuid.dart';
import '../models/symptom.dart';

class SymptomCheckerService {
  static final SymptomCheckerService _instance = SymptomCheckerService._internal();
  factory SymptomCheckerService() => _instance;
  SymptomCheckerService._internal();

  final List<Symptom> _symptoms = [];
  final List<SymptomCheck> _symptomChecks = [];
  final Uuid _uuid = const Uuid();

  List<Symptom> get symptoms => _symptoms;
  List<SymptomCheck> get symptomChecks => _symptomChecks;

  Future<void> initialize() async {
    if (_symptoms.isEmpty) {
      _loadSymptomDatabase();
    }
  }

  void _loadSymptomDatabase() {
    _symptoms.addAll([
      // General Symptoms
      Symptom(
        id: 'fever',
        name: 'Fever',
        description: 'Elevated body temperature above normal (98.6°F/37°C)',
        category: 'general',
        bodyParts: ['whole_body'],
        severity: 5,
        associatedConditions: ['Common Cold', 'Flu', 'Infection', 'COVID-19'],
        keywords: ['hot', 'temperature', 'chills', 'sweating'],
        isCommon: true,
      ),
      Symptom(
        id: 'fatigue',
        name: 'Fatigue',
        description: 'Extreme tiredness or lack of energy',
        category: 'general',
        bodyParts: ['whole_body'],
        severity: 3,
        associatedConditions: ['Anemia', 'Depression', 'Chronic Fatigue Syndrome'],
        keywords: ['tired', 'exhausted', 'weak', 'sleepy'],
        isCommon: true,
      ),
      Symptom(
        id: 'weight_loss',
        name: 'Unexplained Weight Loss',
        description: 'Significant weight loss without trying',
        category: 'general',
        bodyParts: ['whole_body'],
        severity: 7,
        associatedConditions: ['Cancer', 'Hyperthyroidism', 'Diabetes'],
        keywords: ['losing weight', 'appetite loss', 'thin'],
        isCommon: false,
      ),

      // Head and Neck Symptoms
      Symptom(
        id: 'headache',
        name: 'Headache',
        description: 'Pain in the head or neck area',
        category: 'headAndNeck',
        bodyParts: ['head'],
        severity: 4,
        associatedConditions: ['Tension Headache', 'Migraine', 'Cluster Headache'],
        keywords: ['head pain', 'migraine', 'tension'],
        isCommon: true,
      ),
      Symptom(
        id: 'sore_throat',
        name: 'Sore Throat',
        description: 'Pain or irritation in the throat',
        category: 'headAndNeck',
        bodyParts: ['throat'],
        severity: 3,
        associatedConditions: ['Strep Throat', 'Common Cold', 'Pharyngitis'],
        keywords: ['throat pain', 'swallowing pain', 'scratchy throat'],
        isCommon: true,
      ),
      Symptom(
        id: 'dizziness',
        name: 'Dizziness',
        description: 'Feeling of being lightheaded or unsteady',
        category: 'headAndNeck',
        bodyParts: ['head'],
        severity: 5,
        associatedConditions: ['Vertigo', 'Low Blood Pressure', 'Inner Ear Problems'],
        keywords: ['lightheaded', 'spinning', 'balance problems'],
        isCommon: true,
      ),

      // Respiratory Symptoms
      Symptom(
        id: 'cough',
        name: 'Cough',
        description: 'Forceful expulsion of air from the lungs',
        category: 'respiratory',
        bodyParts: ['chest', 'lungs'],
        severity: 3,
        associatedConditions: ['Common Cold', 'Bronchitis', 'Pneumonia'],
        keywords: ['coughing', 'dry cough', 'productive cough'],
        isCommon: true,
      ),
      Symptom(
        id: 'shortness_of_breath',
        name: 'Shortness of Breath',
        description: 'Difficulty breathing or feeling out of breath',
        category: 'respiratory',
        bodyParts: ['chest', 'lungs'],
        severity: 7,
        associatedConditions: ['Asthma', 'Pneumonia', 'Heart Disease'],
        keywords: ['breathing difficulty', 'can\'t breathe', 'wheezing'],
        isCommon: false,
      ),
      Symptom(
        id: 'chest_pain',
        name: 'Chest Pain',
        description: 'Pain or discomfort in the chest area',
        category: 'respiratory',
        bodyParts: ['chest'],
        severity: 8,
        associatedConditions: ['Heart Attack', 'Angina', 'Pneumonia'],
        keywords: ['chest discomfort', 'heart pain', 'crushing pain'],
        isCommon: false,
      ),

      // Gastrointestinal Symptoms
      Symptom(
        id: 'nausea',
        name: 'Nausea',
        description: 'Feeling of sickness with an urge to vomit',
        category: 'gastrointestinal',
        bodyParts: ['stomach'],
        severity: 4,
        associatedConditions: ['Food Poisoning', 'Gastroenteritis', 'Pregnancy'],
        keywords: ['sick stomach', 'queasy', 'want to vomit'],
        isCommon: true,
      ),
      Symptom(
        id: 'vomiting',
        name: 'Vomiting',
        description: 'Forceful expulsion of stomach contents',
        category: 'gastrointestinal',
        bodyParts: ['stomach'],
        severity: 6,
        associatedConditions: ['Food Poisoning', 'Gastroenteritis', 'Migraine'],
        keywords: ['throwing up', 'puking', 'retching'],
        isCommon: true,
      ),
      Symptom(
        id: 'diarrhea',
        name: 'Diarrhea',
        description: 'Frequent, loose, or watery bowel movements',
        category: 'gastrointestinal',
        bodyParts: ['abdomen'],
        severity: 5,
        associatedConditions: ['Gastroenteritis', 'Food Poisoning', 'IBS'],
        keywords: ['loose stool', 'watery stool', 'frequent bowel movements'],
        isCommon: true,
      ),
      Symptom(
        id: 'abdominal_pain',
        name: 'Abdominal Pain',
        description: 'Pain in the stomach or belly area',
        category: 'gastrointestinal',
        bodyParts: ['abdomen'],
        severity: 5,
        associatedConditions: ['Appendicitis', 'Gastritis', 'Kidney Stones'],
        keywords: ['stomach pain', 'belly pain', 'cramping'],
        isCommon: true,
      ),

      // Musculoskeletal Symptoms
      Symptom(
        id: 'muscle_aches',
        name: 'Muscle Aches',
        description: 'General muscle pain and soreness',
        category: 'musculoskeletal',
        bodyParts: ['muscles'],
        severity: 3,
        associatedConditions: ['Flu', 'Fibromyalgia', 'Overexertion'],
        keywords: ['muscle pain', 'sore muscles', 'body aches'],
        isCommon: true,
      ),
      Symptom(
        id: 'joint_pain',
        name: 'Joint Pain',
        description: 'Pain in one or more joints',
        category: 'musculoskeletal',
        bodyParts: ['joints'],
        severity: 4,
        associatedConditions: ['Arthritis', 'Gout', 'Injury'],
        keywords: ['joint aches', 'stiff joints', 'swollen joints'],
        isCommon: true,
      ),
      Symptom(
        id: 'back_pain',
        name: 'Back Pain',
        description: 'Pain in the back, lower back, or spine',
        category: 'musculoskeletal',
        bodyParts: ['back'],
        severity: 5,
        associatedConditions: ['Muscle Strain', 'Herniated Disc', 'Sciatica'],
        keywords: ['backache', 'lower back pain', 'spine pain'],
        isCommon: true,
      ),

      // Neurological Symptoms
      Symptom(
        id: 'confusion',
        name: 'Confusion',
        description: 'Difficulty thinking clearly or making decisions',
        category: 'neurological',
        bodyParts: ['brain'],
        severity: 7,
        associatedConditions: ['Delirium', 'Dementia', 'Infection'],
        keywords: ['confused', 'disoriented', 'mental fog'],
        isCommon: false,
      ),
      Symptom(
        id: 'numbness',
        name: 'Numbness',
        description: 'Loss of feeling or sensation in part of the body',
        category: 'neurological',
        bodyParts: ['extremities'],
        severity: 6,
        associatedConditions: ['Neuropathy', 'Stroke', 'Pinched Nerve'],
        keywords: ['numb', 'tingling', 'pins and needles'],
        isCommon: false,
      ),

      // Dermatological Symptoms
      Symptom(
        id: 'rash',
        name: 'Rash',
        description: 'Changes in skin color, texture, or appearance',
        category: 'dermatological',
        bodyParts: ['skin'],
        severity: 3,
        associatedConditions: ['Allergic Reaction', 'Eczema', 'Infection'],
        keywords: ['skin rash', 'red spots', 'itchy skin'],
        isCommon: true,
      ),
      Symptom(
        id: 'itching',
        name: 'Itching',
        description: 'Uncomfortable sensation that causes desire to scratch',
        category: 'dermatological',
        bodyParts: ['skin'],
        severity: 2,
        associatedConditions: ['Allergies', 'Dry Skin', 'Eczema'],
        keywords: ['itchy', 'scratchy', 'irritated skin'],
        isCommon: true,
      ),

      // Cardiovascular Symptoms
      Symptom(
        id: 'palpitations',
        name: 'Heart Palpitations',
        description: 'Feeling of irregular, fast, or pounding heartbeat',
        category: 'cardiovascular',
        bodyParts: ['heart'],
        severity: 6,
        associatedConditions: ['Arrhythmia', 'Anxiety', 'Hyperthyroidism'],
        keywords: ['heart racing', 'irregular heartbeat', 'pounding heart'],
        isCommon: false,
      ),
      Symptom(
        id: 'swelling',
        name: 'Swelling',
        description: 'Enlargement or puffiness of body parts',
        category: 'cardiovascular',
        bodyParts: ['extremities'],
        severity: 5,
        associatedConditions: ['Heart Failure', 'Kidney Disease', 'Venous Insufficiency'],
        keywords: ['swollen', 'puffy', 'edema'],
        isCommon: false,
      ),

      // Psychiatric Symptoms
      Symptom(
        id: 'anxiety',
        name: 'Anxiety',
        description: 'Feelings of worry, nervousness, or unease',
        category: 'psychiatric',
        bodyParts: ['mind'],
        severity: 4,
        associatedConditions: ['Anxiety Disorder', 'Panic Disorder', 'PTSD'],
        keywords: ['worried', 'nervous', 'anxious', 'panic'],
        isCommon: true,
      ),
      Symptom(
        id: 'depression',
        name: 'Depression',
        description: 'Persistent feelings of sadness or loss of interest',
        category: 'psychiatric',
        bodyParts: ['mind'],
        severity: 6,
        associatedConditions: ['Major Depression', 'Bipolar Disorder', 'Seasonal Affective Disorder'],
        keywords: ['sad', 'depressed', 'hopeless', 'no interest'],
        isCommon: true,
      ),
    ]);
  }

  List<Symptom> searchSymptoms(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _symptoms.where((symptom) {
      return symptom.name.toLowerCase().contains(lowerQuery) ||
             symptom.description.toLowerCase().contains(lowerQuery) ||
             symptom.keywords.any((keyword) => keyword.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<Symptom> getSymptomsByCategory(String category) {
    return _symptoms.where((symptom) => symptom.category == category).toList();
  }

  List<Symptom> getCommonSymptoms() {
    return _symptoms.where((symptom) => symptom.isCommon).toList();
  }

  String createSymptomCheck({
    String? patientId,
    required List<String> selectedSymptoms,
    required Map<String, int> symptomSeverity,
    required Map<String, String> symptomDetails,
  }) {
    final id = _uuid.v4();
    final symptomCheck = SymptomCheck(
      id: id,
      patientId: patientId,
      selectedSymptoms: selectedSymptoms,
      symptomSeverity: symptomSeverity,
      symptomDetails: symptomDetails,
      createdAt: DateTime.now(),
    );
    
    _symptomChecks.add(symptomCheck);
    return id;
  }

  SymptomCheckResult analyzeSymptoms(List<String> selectedSymptoms, Map<String, int> symptomSeverity) {
    final selectedSymptomObjects = _symptoms.where((s) => selectedSymptoms.contains(s.id)).toList();
    
    // Calculate possible conditions
    final possibleConditions = _calculatePossibleConditions(selectedSymptomObjects);
    
    // Determine urgency level
    final urgencyLevel = _determineUrgencyLevel(selectedSymptomObjects, symptomSeverity);
    
    // Generate recommendation
    final recommendation = _generateRecommendation(urgencyLevel, possibleConditions);
    
    // Identify red flags
    final redFlags = _identifyRedFlags(selectedSymptomObjects, symptomSeverity);
    
    // Generate self-care advice
    final selfCareAdvice = _generateSelfCareAdvice(selectedSymptomObjects);
    
    // Determine if should see doctor
    final shouldSeeDoctor = _shouldSeeDoctor(urgencyLevel, redFlags);
    
    // Specialist recommendation
    final specialistRecommendation = _getSpecialistRecommendation(possibleConditions);

    return SymptomCheckResult(
      possibleConditions: possibleConditions,
      urgencyLevel: urgencyLevel,
      recommendation: recommendation,
      redFlags: redFlags,
      selfCareAdvice: selfCareAdvice,
      shouldSeeDoctor: shouldSeeDoctor,
      specialistRecommendation: specialistRecommendation,
    );
  }

  List<PossibleCondition> _calculatePossibleConditions(List<Symptom> symptoms) {
    final Map<String, List<String>> conditionSymptoms = {};
    
    // Group symptoms by conditions
    for (final symptom in symptoms) {
      for (final condition in symptom.associatedConditions) {
        if (!conditionSymptoms.containsKey(condition)) {
          conditionSymptoms[condition] = [];
        }
        conditionSymptoms[condition]!.add(symptom.name);
      }
    }
    
    // Calculate probabilities and create condition objects
    final conditions = <PossibleCondition>[];
    for (final entry in conditionSymptoms.entries) {
      final conditionName = entry.key;
      final matchingSymptoms = entry.value;
      
      // Simple probability calculation based on number of matching symptoms
      final probability = (matchingSymptoms.length / symptoms.length).clamp(0.0, 1.0);
      
      conditions.add(PossibleCondition(
        name: conditionName,
        description: _getConditionDescription(conditionName),
        probability: probability,
        category: _getConditionCategory(conditionName),
        matchingSymptoms: matchingSymptoms,
        treatmentAdvice: _getTreatmentAdvice(conditionName),
        isSerious: _isConditionSerious(conditionName),
      ));
    }
    
    // Sort by probability (highest first)
    conditions.sort((a, b) => b.probability.compareTo(a.probability));
    
    return conditions.take(5).toList(); // Return top 5 conditions
  }

  String _determineUrgencyLevel(List<Symptom> symptoms, Map<String, int> severityMap) {
    // Check for emergency symptoms
    final emergencySymptoms = ['chest_pain', 'shortness_of_breath', 'confusion'];
    if (symptoms.any((s) => emergencySymptoms.contains(s.id))) {
      return 'emergency';
    }
    
    // Calculate average severity
    final totalSeverity = symptoms.fold<int>(0, (sum, symptom) {
      final userSeverity = severityMap[symptom.id] ?? 5;
      return sum + (symptom.severity + userSeverity) ~/ 2;
    });
    
    final averageSeverity = totalSeverity / symptoms.length;
    
    if (averageSeverity >= 8) return 'emergency';
    if (averageSeverity >= 6) return 'high';
    if (averageSeverity >= 4) return 'medium';
    return 'low';
  }

  String _generateRecommendation(String urgencyLevel, List<PossibleCondition> conditions) {
    switch (urgencyLevel) {
      case 'emergency':
        return 'Seek immediate medical attention. Call emergency services or go to the nearest emergency room.';
      case 'high':
        return 'See a doctor as soon as possible. Consider urgent care if your primary doctor is not available.';
      case 'medium':
        return 'Schedule an appointment with your doctor within the next few days.';
      case 'low':
        return 'Monitor your symptoms. If they persist or worsen, consider seeing a doctor.';
      default:
        return 'Consult with a healthcare professional for proper evaluation.';
    }
  }

  List<String> _identifyRedFlags(List<Symptom> symptoms, Map<String, int> severityMap) {
    final redFlags = <String>[];
    
    // Check for high-severity symptoms
    for (final symptom in symptoms) {
      final userSeverity = severityMap[symptom.id] ?? 5;
      if (symptom.severity >= 7 || userSeverity >= 8) {
        redFlags.add('High severity ${symptom.name.toLowerCase()}');
      }
    }
    
    // Check for specific concerning combinations
    final symptomIds = symptoms.map((s) => s.id).toSet();
    if (symptomIds.contains('chest_pain') && symptomIds.contains('shortness_of_breath')) {
      redFlags.add('Chest pain with breathing difficulty');
    }
    
    if (symptomIds.contains('fever') && symptomIds.contains('confusion')) {
      redFlags.add('Fever with confusion');
    }
    
    return redFlags;
  }

  List<String> _generateSelfCareAdvice(List<Symptom> symptoms) {
    final advice = <String>[];
    final symptomIds = symptoms.map((s) => s.id).toSet();
    
    // General advice
    advice.add('Stay hydrated by drinking plenty of water');
    advice.add('Get adequate rest and sleep');
    
    // Specific advice based on symptoms
    if (symptomIds.contains('fever')) {
      advice.add('Take fever-reducing medication if needed');
      advice.add('Use cool compresses to reduce body temperature');
    }
    
    if (symptomIds.contains('cough')) {
      advice.add('Use a humidifier or breathe steam from a hot shower');
      advice.add('Avoid irritants like smoke');
    }
    
    if (symptomIds.contains('headache')) {
      advice.add('Apply cold or warm compress to head');
      advice.add('Practice relaxation techniques');
    }
    
    if (symptomIds.contains('nausea')) {
      advice.add('Eat small, frequent meals');
      advice.add('Try ginger tea or peppermint');
    }
    
    return advice;
  }

  bool _shouldSeeDoctor(String urgencyLevel, List<String> redFlags) {
    return urgencyLevel == 'emergency' || 
           urgencyLevel == 'high' || 
           redFlags.isNotEmpty;
  }

  String? _getSpecialistRecommendation(List<PossibleCondition> conditions) {
    if (conditions.isEmpty) return null;
    
    final topCondition = conditions.first;
    
    // Map conditions to specialists
    final specialistMap = {
      'Heart Attack': 'Cardiologist',
      'Angina': 'Cardiologist',
      'Asthma': 'Pulmonologist',
      'Pneumonia': 'Pulmonologist',
      'Migraine': 'Neurologist',
      'Stroke': 'Neurologist',
      'Arthritis': 'Rheumatologist',
      'Diabetes': 'Endocrinologist',
      'Depression': 'Psychiatrist',
      'Anxiety Disorder': 'Psychiatrist',
    };
    
    return specialistMap[topCondition.name];
  }

  String _getConditionDescription(String conditionName) {
    final descriptions = {
      'Common Cold': 'A viral infection of the upper respiratory tract',
      'Flu': 'A viral infection that affects the respiratory system',
      'COVID-19': 'A viral infection caused by the SARS-CoV-2 virus',
      'Strep Throat': 'A bacterial infection of the throat and tonsils',
      'Migraine': 'A type of headache characterized by severe throbbing pain',
      'Tension Headache': 'The most common type of headache caused by muscle tension',
      'Pneumonia': 'An infection that inflames air sacs in one or both lungs',
      'Asthma': 'A condition in which airways narrow and swell',
      'Heart Attack': 'A blockage of blood flow to the heart muscle',
      'Angina': 'Chest pain caused by reduced blood flow to the heart',
      'Gastroenteritis': 'Inflammation of the stomach and intestines',
      'Food Poisoning': 'Illness caused by eating contaminated food',
      'Appendicitis': 'Inflammation of the appendix',
      'Arthritis': 'Inflammation of one or more joints',
      'Fibromyalgia': 'A disorder characterized by widespread musculoskeletal pain',
      'Depression': 'A mental health disorder characterized by persistent sadness',
      'Anxiety Disorder': 'A mental health disorder characterized by excessive worry',
    };
    
    return descriptions[conditionName] ?? 'A medical condition that may require professional evaluation';
  }

  String _getConditionCategory(String conditionName) {
    final categories = {
      'Common Cold': 'Respiratory',
      'Flu': 'Respiratory',
      'COVID-19': 'Respiratory',
      'Strep Throat': 'Respiratory',
      'Migraine': 'Neurological',
      'Tension Headache': 'Neurological',
      'Pneumonia': 'Respiratory',
      'Asthma': 'Respiratory',
      'Heart Attack': 'Cardiovascular',
      'Angina': 'Cardiovascular',
      'Gastroenteritis': 'Gastrointestinal',
      'Food Poisoning': 'Gastrointestinal',
      'Appendicitis': 'Gastrointestinal',
      'Arthritis': 'Musculoskeletal',
      'Fibromyalgia': 'Musculoskeletal',
      'Depression': 'Mental Health',
      'Anxiety Disorder': 'Mental Health',
    };
    
    return categories[conditionName] ?? 'General';
  }

  String? _getTreatmentAdvice(String conditionName) {
    final treatments = {
      'Common Cold': 'Rest, fluids, and over-the-counter medications for symptom relief',
      'Flu': 'Rest, fluids, and antiviral medications if prescribed',
      'Strep Throat': 'Antibiotics prescribed by a doctor',
      'Migraine': 'Pain relievers, rest in a dark room, and trigger avoidance',
      'Tension Headache': 'Over-the-counter pain relievers and stress management',
      'Gastroenteritis': 'Rest, fluids, and gradual return to normal diet',
      'Food Poisoning': 'Rest, fluids, and monitoring for severe symptoms',
    };
    
    return treatments[conditionName];
  }

  bool _isConditionSerious(String conditionName) {
    final seriousConditions = {
      'Heart Attack',
      'Stroke',
      'Pneumonia',
      'Appendicitis',
      'COVID-19',
    };
    
    return seriousConditions.contains(conditionName);
  }

  SymptomCheck? getSymptomCheckById(String id) {
    try {
      return _symptomChecks.firstWhere((check) => check.id == id);
    } catch (e) {
      return null;
    }
  }

  List<SymptomCheck> getSymptomChecksByPatientId(String patientId) {
    return _symptomChecks.where((check) => check.patientId == patientId).toList();
  }

  void updateSymptomCheckResult(String id, SymptomCheckResult result) {
    final index = _symptomChecks.indexWhere((check) => check.id == id);
    if (index != -1) {
      final updatedCheck = SymptomCheck(
        id: _symptomChecks[index].id,
        patientId: _symptomChecks[index].patientId,
        selectedSymptoms: _symptomChecks[index].selectedSymptoms,
        symptomSeverity: _symptomChecks[index].symptomSeverity,
        symptomDetails: _symptomChecks[index].symptomDetails,
        createdAt: _symptomChecks[index].createdAt,
        result: result,
      );
      _symptomChecks[index] = updatedCheck;
    }
  }
}
