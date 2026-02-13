#if os(iOS)
import UIKit

public struct VxBannerModel: @unchecked Sendable {
    public let id: String
    public let type: VxBannerTypes
    public let font: VxFont
    public let title: String
    public let buttonLabel: String?
    public var buttonAction: (@Sendable () -> Void)?

    public init(id: String,
                type: VxBannerTypes,
                font: VxFont,
                title: String,
                buttonLabel: String? = nil,
                buttonAction: (@Sendable () -> Void)? = nil) {
        self.id = id
        self.type = type
        self.font = font
        self.title = title
        self.buttonLabel = buttonLabel
        self.buttonAction = buttonAction
    }
}

public enum VxBannerTypes: Sendable {
    case success
    case error
    case warning
    case info
    case debug

    public var backgroundColor: UIColor {
        switch self {
        case .success: return UIColor(red: 57/255, green: 198/255, blue: 117/255, alpha: 1)
        case .error: return UIColor(red: 220/255, green: 38/255, blue: 38/255, alpha: 1)
        case .warning: return UIColor(red: 234/255, green: 179/255, blue: 8/255, alpha: 1)
        case .info: return UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1)
        case .debug: return UIColor.black.withAlphaComponent(0.9)
        }
    }

    public var textColor: UIColor {
        switch self {
        case .debug: return .white
        default: return .white
        }
    }

    public var iconName: String {
        switch self {
        case .success: return "checkmark.circle"
        case .error: return "xmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .info: return "info.circle"
        case .debug: return "magnifyingglass.circle"
        }
    }
}
#endif
