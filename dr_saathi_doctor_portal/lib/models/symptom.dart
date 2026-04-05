class Symptom {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> bodyParts;
  final int severity; // 1-10 scale
  final List<String> associatedConditions;
  final List<String> keywords;
  final bool isCommon;

  Symptom({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.bodyParts,
    required this.severity,
    required this.associatedConditions,
    required this.keywords,
    this.isCommon = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'body_parts': bodyParts,
      'severity': severity,
      'associated_conditions': associatedConditions,
      'keywords': keywords,
      'is_common': isCommon,
    };
  }

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      bodyParts: List<String>.from(json['body_parts']),
      severity: json['severity'],
      associatedConditions: List<String>.from(json['associated_conditions']),
      keywords: List<String>.from(json['keywords']),
      isCommon: json['is_common'] ?? false,
    );
  }
}

class SymptomCheck {
  final String id;
  final String? patientId;
  final List<String> selectedSymptoms;
  final Map<String, int> symptomSeverity; // symptom_id -> severity (1-10)
  final Map<String, String> symptomDetails; // symptom_id -> additional details
  final DateTime createdAt;
  final SymptomCheckResult? result;

  SymptomCheck({
    required this.id,
    this.patientId,
    required this.selectedSymptoms,
    required this.symptomSeverity,
    required this.symptomDetails,
    required this.createdAt,
    this.result,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'selected_symptoms': selectedSymptoms,
      'symptom_severity': symptomSeverity,
      'symptom_details': symptomDetails,
      'created_at': createdAt.toIso8601String(),
      'result': result?.toJson(),
    };
  }

  factory SymptomCheck.fromJson(Map<String, dynamic> json) {
    return SymptomCheck(
      id: json['id'],
      patientId: json['patient_id'],
      selectedSymptoms: List<String>.from(json['selected_symptoms']),
      symptomSeverity: Map<String, int>.from(json['symptom_severity']),
      symptomDetails: Map<String, String>.from(json['symptom_details']),
      createdAt: DateTime.parse(json['created_at']),
      result: json['result'] != null 
          ? SymptomCheckResult.fromJson(json['result'])
          : null,
    );
  }
}

class SymptomCheckResult {
  final List<PossibleCondition> possibleConditions;
  final String urgencyLevel; // 'low', 'medium', 'high', 'emergency'
  final String recommendation;
  final List<String> redFlags;
  final List<String> selfCareAdvice;
  final bool shouldSeeDoctor;
  final String? specialistRecommendation;

  SymptomCheckResult({
    required this.possibleConditions,
    required this.urgencyLevel,
    required this.recommendation,
    required this.redFlags,
    required this.selfCareAdvice,
    required this.shouldSeeDoctor,
    this.specialistRecommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'possible_conditions': possibleConditions.map((c) => c.toJson()).toList(),
      'urgency_level': urgencyLevel,
      'recommendation': recommendation,
      'red_flags': redFlags,
      'self_care_advice': selfCareAdvice,
      'should_see_doctor': shouldSeeDoctor,
      'specialist_recommendation': specialistRecommendation,
    };
  }

  factory SymptomCheckResult.fromJson(Map<String, dynamic> json) {
    return SymptomCheckResult(
      possibleConditions: (json['possible_conditions'] as List<dynamic>)
          .map((c) => PossibleCondition.fromJson(c))
          .toList(),
      urgencyLevel: json['urgency_level'],
      recommendation: json['recommendation'],
      redFlags: List<String>.from(json['red_flags']),
      selfCareAdvice: List<String>.from(json['self_care_advice']),
      shouldSeeDoctor: json['should_see_doctor'],
      specialistRecommendation: json['specialist_recommendation'],
    );
  }
}

class PossibleCondition {
  final String name;
  final String description;
  final double probability; // 0.0 to 1.0
  final String category;
  final List<String> matchingSymptoms;
  final String? treatmentAdvice;
  final bool isSerious;

  PossibleCondition({
    required this.name,
    required this.description,
    required this.probability,
    required this.category,
    required this.matchingSymptoms,
    this.treatmentAdvice,
    this.isSerious = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'probability': probability,
      'category': category,
      'matching_symptoms': matchingSymptoms,
      'treatment_advice': treatmentAdvice,
      'is_serious': isSerious,
    };
  }

  factory PossibleCondition.fromJson(Map<String, dynamic> json) {
    return PossibleCondition(
      name: json['name'],
      description: json['description'],
      probability: json['probability'].toDouble(),
      category: json['category'],
      matchingSymptoms: List<String>.from(json['matching_symptoms']),
      treatmentAdvice: json['treatment_advice'],
      isSerious: json['is_serious'] ?? false,
    );
  }
}

enum SymptomCategory {
  general,
  headAndNeck,
  respiratory,
  cardiovascular,
  gastrointestinal,
  musculoskeletal,
  neurological,
  dermatological,
  genitourinary,
  psychiatric,
  endocrine,
  immune,
}

enum UrgencyLevel {
  low,
  medium,
  high,
  emergency,
}

extension UrgencyLevelExtension on UrgencyLevel {
  String get displayName {
    switch (this) {
      case UrgencyLevel.low:
        return 'Low Priority';
      case UrgencyLevel.medium:
        return 'Medium Priority';
      case UrgencyLevel.high:
        return 'High Priority';
      case UrgencyLevel.emergency:
        return 'Emergency';
    }
  }

  String get description {
    switch (this) {
      case UrgencyLevel.low:
        return 'Monitor symptoms and consider seeing a doctor if they persist or worsen.';
      case UrgencyLevel.medium:
        return 'Consider seeing a doctor within a few days.';
      case UrgencyLevel.high:
        return 'See a doctor as soon as possible.';
      case UrgencyLevel.emergency:
        return 'Seek immediate medical attention or call emergency services.';
    }
  }
}
