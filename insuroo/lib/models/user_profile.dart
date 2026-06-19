class UserProfile {
  final String name;
  final int age;
  final String gender;
  final String occupation;
  final double annualIncome;
  final bool isFarmer;
  final bool isBelowPovertyLine;
  final bool hasPreexistingConditions;
  final String? location;
  final String? additionalInfo;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.occupation,
    required this.annualIncome,
    this.isFarmer = false,
    this.isBelowPovertyLine = false,
    this.hasPreexistingConditions = false,
    this.location = "Rural India",
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'annual_income': annualIncome,
      'is_farmer': isFarmer,
      'is_below_poverty_line': isBelowPovertyLine,
      'has_preexisting_conditions': hasPreexistingConditions,
      'location': location,
      'additional_info': additionalInfo,
    };
  }
}

class RecommendedPolicy {
  final String policyName;
  final String eligibilityStatus;
  final String reasoning;
  final List<String> benefits;

  RecommendedPolicy({
    required this.policyName,
    required this.eligibilityStatus,
    required this.reasoning,
    required this.benefits,
  });

  factory RecommendedPolicy.fromJson(Map<String, dynamic> json) {
    return RecommendedPolicy(
      policyName: json['policy_name'] as String? ?? 'Unknown Policy',
      eligibilityStatus:
          json['eligibility_status'] as String? ?? 'Unknown Status',
      reasoning: json['reasoning'] as String? ?? 'No reasoning provided',
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class RecommendationResponse {
  final String userName;
  final List<RecommendedPolicy> recommendations;
  final String summary;

  RecommendationResponse({
    required this.userName,
    required this.recommendations,
    required this.summary,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      userName: json['user_name'] as String? ?? 'User',
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map(
                  (e) => RecommendedPolicy.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] as String? ?? 'No summary provided',
    );
  }
}
