class MeasurementModel {
  String? customerName;
  String? phoneNumber;
  Map<String, String> qameezData;
  Map<String, String> trouserData;
  String extraNotes;
  DateTime? createdAt;

  MeasurementModel({
    this.customerName,
    this.phoneNumber,
    Map<String, String>? qameezData,
    Map<String, String>? trouserData,
    this.extraNotes = "",
    this.createdAt,
  })  : qameezData = qameezData ?? {},
        trouserData = trouserData ?? {};

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'qameezData': qameezData,
      'trouserData': trouserData,
      'extraNotes': extraNotes,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory MeasurementModel.fromMap(Map<String, dynamic> map) {
    return MeasurementModel(
      customerName: map['customerName'],
      phoneNumber: map['phoneNumber'],
      qameezData: Map<String, String>.from(map['qameezData']),
      trouserData: Map<String, String>.from(map['trouserData']),
      extraNotes: map['extraNotes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}