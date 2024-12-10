import Foundation

@objc(EventAttribute)
public class EventAttribute: NSObject {
    @objc public static let created_at = "created_at"
    @objc public static let device_os = "device_os"
    @objc public static let device_id = "device_id"
    @objc public static let device_model = "device_model"
    @objc public static let device_os_ver = "device_os_ver"
    @objc public static let device_manufacturer = "device_manufacturer"
    @objc public static let sdk_type = "sdk_type"
    @objc public static let session_id = "session_id"
    @objc public static let mediation = "mediation"
    @objc public static let msg = "msg"
    @objc public static let sdk_version = "sdk_version"
    @objc public static let mediation_sdk_version = "mediation_sdk_version"
    @objc public static let package = "package"
    @objc public static let type = "type"
    @objc public static let ifv = "ifv"
    @objc public static let impression_id = "impression_id"
    @objc public static let platform = "platform"
    @objc public static let versionNumber = "version"
    @objc public static let adapter_version = "adapter_version"
    @objc public static let duration = "duration"
    @objc public static let duration_avg = "duration_avg"
    @objc public static let app_key = "app_key"
    @objc public static let cid = "cid"
    @objc public static let crid = "crid"
    @objc public static let placement = "placement"
    @objc public static let media_url = "media_url"

    /// Returns the expected type of a given attribute
    @objc static func expectedType(for attribute: String) -> String {
        switch attribute {
        case created_at:
            return "Date"
        case duration, duration_avg:
            return "Int"
        default:
            return "String"
        }
    }
}
