import UIKit

final class MessengerDateFormatter {
    private let dateFormatter = DateFormatter()
    
    init() {}
    
    func string(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "dd MMM"
        }
        return dateFormatter.string(from: date)
    }
}
