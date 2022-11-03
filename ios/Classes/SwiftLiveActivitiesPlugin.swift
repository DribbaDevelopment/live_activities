import Flutter
import UIKit
import ActivityKit

public class SwiftLiveActivitiesPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "live_activities", binaryMessenger: registrar.messenger())
    let instance = SwiftLiveActivitiesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if #available(iOS 16.1, *) {
      switch (call.method) {
      case "createActivity":
        guard let args = call.arguments  as? [String: Any] else {
          return
        }
        if let data = args["data"] as? Dictionary<String, Any> {
          createActivity(data: data, result: result)
        } else {
          result(FlutterError(code: "WRONG_ARGS", message: "argument are not valid, check if 'data' is valid", details: nil))
        }
        break
      case "updateActivity":
        guard let args = call.arguments  as? [String: Any] else {
          return
        }
        if let activityId = args["activityId"] as? String, let data = args["data"] as? Dictionary<String, String> {
          updateActivity(activityId: activityId, data: data, result: result)
        } else {
          result(FlutterError(code: "WRONG_ARGS", message: "argument are not valid, check if 'activityId' & 'data' are valid", details: nil))
        }
        break
      case "endActivity":
        guard let args = call.arguments  as? [String: Any] else {
          return
        }
        if let activityId = args["activityId"] as? String {
          endActivity(activityId: activityId, result: result)
        } else {
          result(FlutterError(code: "WRONG_ARGS", message: "argument are not valid, check if 'activityId' is valid", details: nil))
        }
        break
      default:
        break
      }
    } else {
      result(FlutterError(code: "WRONG_IOS_VERSION", message: "this version of iOS is not supported", details: nil))
    }
  }
  
  @available(iOS 16.1, *)
  func createActivity(data: Dictionary<String, Any>, result: @escaping FlutterResult) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      
      if let error = error {
        result(FlutterError(code: "AUTHORIZATION_ERROR", message: "authorization error", details: error.localizedDescription))
      }
    }
    
    let liveDeliveryAttributes = LiveActivitiesAppAttributes()
      let initialContentState = LiveActivitiesAppAttributes.LiveDeliveryData(mainTitle: (data["mainTitle"] ?? "") as! String, progress: (data["progress"]  ?? 0.0) as! Double, title: (data["title"] ?? "") as! String, subtitle: (data["subtitle"]  ?? "") as! String, type: (data["type"]  ?? "") as! String, ongoingOrders: (data["ongoingOrders"] ?? 0) as! Int)
    
    do {
      let deliveryActivity = try Activity<LiveActivitiesAppAttributes>.request(
        attributes: liveDeliveryAttributes,
        contentState: initialContentState,
        pushType: PushType.token)
        
        Task {
              for await data in deliveryActivity.pushTokenUpdates {
                 let myToken = data.map {String(format: "%02x", $0)}.joined()
                  result("{\"activity_id\": \"\(deliveryActivity.id)\", \"pushToken\": \"\(myToken)\"}")
              }
           }
        
        
    } catch (let error) {
      result(FlutterError(code: "LIVE_ACTIVITY_ERROR", message: "can't launch live activity", details: error.localizedDescription))
    }
  }
  
  @available(iOS 16.1, *)
  func updateActivity(activityId: String, data: Dictionary<String, Any>, result: @escaping FlutterResult) {
    Task {
      for activity in Activity<LiveActivitiesAppAttributes>.activities {
        if (activityId == activity.id) {
              let updatedStatus = LiveActivitiesAppAttributes.LiveDeliveryData(mainTitle: (data["mainTitle"] ?? "") as! String, progress: (data["progress"]  ?? 0.0) as! Double, title: (data["title"] ?? "") as! String, subtitle: (data["subtitle"]  ?? "") as! String, type: (data["type"]  ?? "") as! String, ongoingOrders: (data["ongoingOrders"] ?? 0) as! Int)
          await activity.update(using: updatedStatus)
          break;
        }
      }
    }
  }
  
  @available(iOS 16.1, *)
  func endActivity(activityId: String, result: @escaping FlutterResult) {
    Task {
      for activity in Activity<LiveActivitiesAppAttributes>.activities {
        if (activityId == activity.id) {
          await activity.end(dismissalPolicy: .immediate)
          break;
        }
      }
    }
  }
  
  struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState
    
    public struct ContentState: Codable, Hashable {
        var mainTitle: String
        var progress: Double
        var title: String
        var subtitle: String
        var type: String
        var ongoingOrders: Int
    }
    
    var id = UUID()
  }
}
