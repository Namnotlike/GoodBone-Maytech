class PostureAlert {
  final int? id;
  final DateTime timestamp;
  final String alertType; // e.g., "Slouching", "Leaning", "Inactive"
  final String message;

  PostureAlert({
    this.id,
    required this.timestamp,
    required this.alertType,
    required this.message,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'alertType': alertType,
    'message': message,
  };

  factory PostureAlert.fromMap(Map<String, dynamic> map) => PostureAlert(
    id: map['id'],
    timestamp: DateTime.parse(map['timestamp']),
    alertType: map['alertType'],
    message: map['message'],
  );
}
