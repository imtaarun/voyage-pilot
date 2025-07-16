// trip_models.dart
import 'dart:developer';

class TripPlan {
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;
  List<TripDay> tripDays;

  TripPlan({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.tripDays,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    var daysFromJson = json['tripPlan']['tripDays'] as List;
    List<TripDay> dayList = daysFromJson.map((d) => TripDay.fromJson(d)).toList();

    return TripPlan(
      name: json['tripPlan']['trip']['name'],
      description: json['tripPlan']['trip']['description'],
      startDate: DateTime.parse(json['tripPlan']['trip']['startDate']),
      endDate: DateTime.parse(json['tripPlan']['trip']['endDate']),
      tripDays: dayList,
    );
  }
}

class TripDay {
  DateTime date;
  String notes;
  List<Activity> activities;

  TripDay({
    required this.date,
    required this.notes,
    required this.activities,
  });

  factory TripDay.fromJson(Map<String, dynamic> json) {
    var activitiesFromJson = json['activities'] as List;
    List<Activity> activityList = activitiesFromJson.map((a) => Activity.fromJson(a)).toList();
    return TripDay(
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      activities: activityList,
    );
  }
}

class Activity {
  String activityType;
  String name;
  String description;
  String location;
  String startTime;
  String endTime;
  List<Activity> alternatives;

  Activity({
    required this.activityType,
    required this.name,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.alternatives,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    var alternativesFromJson = json['alternatives'] as List? ?? [];
    List<Activity> alternativeList = alternativesFromJson.length > 1 ?  alternativesFromJson.map((a) => Activity.fromJson(a)).toList() : [];
    return Activity(
      activityType: json['activity_type'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      alternatives: alternativeList,
    );
  }
}