import 'live_activities_platform_interface.dart';
import 'dart:convert';

class LiveActivities {
  /// Create an iOS 16.1+ live activity.
  /// When the activity is created, an activity id is returned.
  /// Data is a map of key/value pairs that will be transmitted to your iOS extension widget.
  /// Map is limited to String keys and values for now.
  Future<Activity?> createActivity(Map<String, dynamic> data) async {
    try {
      var result = await LiveActivitiesPlatform.instance.createActivity(data);
      return Activity.fromJson(json.decode(result!));
    } catch(e) {
      print(e);
    }
    return null;
  }

  /// Update an iOS 16.1+ live activity.
  /// You can get an activity id by calling [createActivity].
  /// Data is a map of key/value pairs that will be transmitted to your iOS extension widget.
  /// Map is limited to String keys and values for now.
  Future updateActivity(String activityId, Map<String, String> data) {
    return LiveActivitiesPlatform.instance.updateActivity(activityId, data);
  }

  /// End an iOS 16.1+ live activity.
  /// You can get an activity id by calling [createActivity].
  Future endActivity(String activityId) {
    return LiveActivitiesPlatform.instance.endActivity(activityId);
  }
}

class Activity {
  String? activityId;
  String? pushToken;

  Activity({this.activityId, this.pushToken});

  Activity.fromJson(Map<String, dynamic> json) {
    activityId = json['activity_id'];
    pushToken = json['pushToken'];
  }
}