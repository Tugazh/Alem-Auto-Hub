class SettingsModel {
  final String city;
  final String language;
  final NotificationSettingsModel notifications;
  final SecuritySettingsModel security;

  const SettingsModel({
    required this.city,
    required this.language,
    required this.notifications,
    required this.security,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      city: json['city']?.toString() ?? 'Алматы',
      language: json['language']?.toString() ?? 'ru',
      notifications: NotificationSettingsModel.fromJson(
        json['notifications'] as Map<String, dynamic>? ?? {},
      ),
      security: SecuritySettingsModel.fromJson(
        json['security'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'language': language,
      'notifications': notifications.toJson(),
      'security': security.toJson(),
    };
  }

  SettingsModel copyWith({
    String? city,
    String? language,
    NotificationSettingsModel? notifications,
    SecuritySettingsModel? security,
  }) {
    return SettingsModel(
      city: city ?? this.city,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      security: security ?? this.security,
    );
  }
}

class NotificationSettingsModel {
  final bool push;
  final bool service;
  final bool promo;
  final bool email;

  const NotificationSettingsModel({
    required this.push,
    required this.service,
    required this.promo,
    required this.email,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      push: json['push'] as bool? ?? true,
      service: json['service'] as bool? ?? true,
      promo: json['promo'] as bool? ?? false,
      email: json['email'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'push': push, 'service': service, 'promo': promo, 'email': email};
  }

  NotificationSettingsModel copyWith({
    bool? push,
    bool? service,
    bool? promo,
    bool? email,
  }) {
    return NotificationSettingsModel(
      push: push ?? this.push,
      service: service ?? this.service,
      promo: promo ?? this.promo,
      email: email ?? this.email,
    );
  }
}

class SecuritySettingsModel {
  final bool twoFactorEnabled;

  const SecuritySettingsModel({required this.twoFactorEnabled});

  factory SecuritySettingsModel.fromJson(Map<String, dynamic> json) {
    return SecuritySettingsModel(
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'twoFactorEnabled': twoFactorEnabled};
  }

  SecuritySettingsModel copyWith({bool? twoFactorEnabled}) {
    return SecuritySettingsModel(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}
