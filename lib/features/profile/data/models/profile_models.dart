class ProfileResponse {
  final UserProfileFull userProfile;
  final PersonalDetails personalDetails;
  final Address address;
  final int forumPostsCount;
  final int helpfulResponsesCount;
  final LoginDetails? loginDetails;

  ProfileResponse({
    required this.userProfile,
    required this.personalDetails,
    required this.address,
    required this.forumPostsCount,
    required this.helpfulResponsesCount,
    this.loginDetails,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      userProfile: UserProfileFull.fromJson(json['userProfile']),
      personalDetails: PersonalDetails.fromJson(json['personalDetails']),
      address: Address.fromJson(json['address']),
      forumPostsCount: json['forumPostsCount'] ?? 0,
      helpfulResponsesCount: json['helpfulResponsesCount'] ?? 0,
      loginDetails: json['loginDetails'] != null ? LoginDetails.fromJson(json['loginDetails']) : null,
    );
  }
}

class UserProfileFull {
  final int profileId;
  final int userId;
  final String userType;
  final String username;
  final String email;
  final String? mobileNumber;
  final String? phone1;
  final String? phone2;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? suffix;
  final String? prefix;
  final String gender;
  final String dateOfBirth;
  final String? aboutMe;
  final int completionPercentage;
  final bool onboarded;
  final List<Caregiver> caregivers;

  UserProfileFull({
    required this.profileId,
    required this.userId,
    required this.userType,
    required this.username,
    required this.email,
    this.mobileNumber,
    this.phone1,
    this.phone2,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.suffix,
    this.prefix,
    required this.gender,
    required this.dateOfBirth,
    this.aboutMe,
    required this.completionPercentage,
    required this.onboarded,
    required this.caregivers,
  });

  factory UserProfileFull.fromJson(Map<String, dynamic> json) {
    return UserProfileFull(
      profileId: json['profileId'] ?? 0,
      userId: json['userId'] ?? 0,
      userType: json['userType'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'],
      lastName: json['lastName'] ?? '',
      suffix: json['suffix'],
      prefix: json['prefix'],
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      aboutMe: json['aboutMe'],
      completionPercentage: json['completionPercentage'] ?? 0,
      onboarded: json['onboarded'] ?? false,
      caregivers: (json['caregivers'] as List?)
              ?.map((e) => Caregiver.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Caregiver {
  final String username;
  final String firstName;
  final String lastName;
  final String relationship;
  final int linkId;
  final String? profileImage;

  Caregiver({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.relationship,
    required this.linkId,
    this.profileImage,
  });

  factory Caregiver.fromJson(Map<String, dynamic> json) {
    return Caregiver(
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      relationship: json['relationship'] ?? '',
      linkId: json['linkId'] ?? 0,
      profileImage: json['profileImage'],
    );
  }
}

class PersonalDetails {
  final String injuryType;
  final String? injuryDetails;
  final int yearsSinceInjury;
  final int? yearsSinceRecovery;
  final List<RecoveryMilestone> recoveryMilestones;
  final List<Achievement> achievements;
  final String? personalStory;
  final String? conditionDetails;
  final String stageOfRecovery;
  final String? mentorshipGoals;
  final String? fitnessLevel;
  final int? availabilityHoursPerWeek;
  final bool offerSupport;

  PersonalDetails({
    required this.injuryType,
    this.injuryDetails,
    required this.yearsSinceInjury,
    this.yearsSinceRecovery,
    required this.recoveryMilestones,
    required this.achievements,
    this.personalStory,
    this.conditionDetails,
    required this.stageOfRecovery,
    this.mentorshipGoals,
    this.fitnessLevel,
    this.availabilityHoursPerWeek,
    this.offerSupport = false,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      injuryType: json['injuryType'] ?? '',
      injuryDetails: json['injuryDetails'],
      yearsSinceInjury: json['yearsSinceInjury'] ?? 0,
      yearsSinceRecovery: json['yearsSinceRecovery'],
      recoveryMilestones: (json['recoveryMilestones'] as List?)
              ?.map((e) => RecoveryMilestone.fromJson(e))
              .toList() ??
          [],
      achievements: (json['achievements'] as List?)
              ?.map((e) => Achievement.fromJson(e))
              .toList() ??
          [],
      personalStory: json['personalStory'],
      conditionDetails: json['conditionDetails'],
      stageOfRecovery: json['stageOfRecovery'] ?? '',
      mentorshipGoals: json['mentorshipGoals'],
      fitnessLevel: json['fitnessLevel'],
      availabilityHoursPerWeek: json['availabilityHoursPerWeek'],
      offerSupport: json['offerSupport'] ?? false,
    );
  }
}

class RecoveryMilestone {
  final int id;
  final String title;
  final String type;
  final String date;

  RecoveryMilestone({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
  });

  factory RecoveryMilestone.fromJson(Map<String, dynamic> json) {
    return RecoveryMilestone(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class Achievement {
  final int id;
  final String title;
  final String month;

  Achievement({
    required this.id,
    required this.title,
    required this.month,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      month: json['month'] ?? '',
    );
  }
}

class Address {
  final String? addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  Address({
    this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }
}

class ForumContribution {
  final int id;
  final String title;
  final String type;
  final int likes;
  final int replies;
  final String timeAgo;

  ForumContribution({
    required this.id,
    required this.title,
    required this.type,
    required this.likes,
    required this.replies,
    required this.timeAgo,
  });

  factory ForumContribution.fromJson(Map<String, dynamic> json) {
    return ForumContribution(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      likes: json['likes'] ?? 0,
      replies: json['replies'] ?? 0,
      timeAgo: json['timeAgo'] ?? '',
    );
  }
}

class ChatSession {
  final int id;
  final String mentee;
  final String lastActive;
  final String duration;
  final String topic;

  ChatSession({
    required this.id,
    required this.mentee,
    required this.lastActive,
    required this.duration,
    required this.topic,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? 0,
      mentee: json['mentee'] ?? '',
      lastActive: json['lastActive'] ?? '',
      duration: json['duration'] ?? '',
      topic: json['topic'] ?? '',
    );
  }
}

class LoginDetails {
  final String? createdAt;
  final String? lastLoggedInAt;
  final bool loggedIn;

  LoginDetails({
    this.createdAt,
    this.lastLoggedInAt,
    this.loggedIn = false,
  });

  factory LoginDetails.fromJson(Map<String, dynamic> json) {
    return LoginDetails(
      createdAt: json['createdAt'],
      lastLoggedInAt: json['lastLoggedInAt'],
      loggedIn: json['loggedIn'] ?? false,
    );
  }
}

class LinkedUserDTO {
  final String username;
  final String firstName;
  final String lastName;
  final String? aboutMe;
  final String? country;
  final String? profileImage;

  LinkedUserDTO({
    required this.username,
    required this.firstName,
    required this.lastName,
    this.aboutMe,
    this.country,
    this.profileImage,
  });

  factory LinkedUserDTO.fromJson(Map<String, dynamic> json) {
    return LinkedUserDTO(
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      aboutMe: json['aboutMe'],
      country: json['country'],
      profileImage: json['profileImage'],
    );
  }
}

class PendingCaregiverRequest {
  final String username;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String relationship;
  final int linkId;

  PendingCaregiverRequest({
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.relationship,
    required this.linkId,
  });

  factory PendingCaregiverRequest.fromJson(Map<String, dynamic> json) {
    return PendingCaregiverRequest(
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'],
      relationship: json['relationship'] ?? '',
      linkId: json['linkId'] ?? 0,
    );
  }
}
