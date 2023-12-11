import Foundation

enum LogLevel: String {
    case debug
    case info
    case warning
    case error
    case off
    
    var value: Int {
        switch self {
        case .debug:
            return 1
        case .info:
            return 2
        case .warning:
            return 3
        case .error:
            return 4
        case .off:
            return 0
        }
    }
}

class Logger {
    private let logLevel: LogLevel
    
    init() {
        let arguments = ProcessInfo.processInfo.arguments
 
        if let levelArg = arguments.first(where: { $0.starts(with: "-logLevel=") }),
           let levelStr = levelArg.split(separator: "=").last,
           let level = LogLevel(rawValue: String(levelStr)) {
            logLevel = level
        } else {
            logLevel = .debug
        }
    }
    
    func debug(_ message: String) {
        log(message, logLevel: .debug)
    }
    
    func info(_ message: String) {
        log(message, logLevel: .info)
    }
    
    func warning(_ message: String) {
        log(message, logLevel: .warning)
    }
    
    func error(_ message: String) {
        log(message, logLevel: .error)
    }
    
    private func log(_ message: String, logLevel: LogLevel) {
        
        guard logLevel.value >= self.logLevel.value, logLevel.value > 0 else { return }
        
        let levelString: String
        switch logLevel {
        case .debug:
            levelString = "DEBUG"
        case .info:
            levelString = "INFO"
        case .warning:
            levelString = "WARNING"
        case .error:
            levelString = "ERROR"
        case .off:
            levelString = ""
        }
        
        print("[\(levelString)] \(message)")
    }
}
