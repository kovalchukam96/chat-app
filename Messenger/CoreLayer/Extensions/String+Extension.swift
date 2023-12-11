import UIKit

extension String {
  func createInitials() -> String {
        let words = self.split(separator: " ")
        var initials = ""
        for word in words {
            if let firstCharacter = word.first {
                initials.append(firstCharacter)
            }
            if initials.count == 2 {
                break
            }
        }
        return initials
    }
}
