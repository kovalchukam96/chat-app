import UIKit

enum ColorPalette {
    
    enum Background {
        static var primary = UIColor(light: UIColor.white, dark: UIColor.black)
        static var alternative = UIColor(light: UIColor(rgb: 0xF2F2F7), dark: UIColor.darkGray)
        static var incomingBubble = UIColor(light: UIColor(rgb: 0xE9E9EB), dark: UIColor.darkGray)
        static var contextMenu = UIColor(light: UIColor(rgb: 0xEDEDED), dark: UIColor.darkGray)
    }
    enum Text {
        static var primary = UIColor(light: UIColor.black, dark: UIColor.white)
        static var secondary = UIColor(light: UIColor(rgb: 0x3C3C43), dark: UIColor(rgb: 0xF2F2F7))
    }
    enum Element {
        static var border = UIColor(light: UIColor(rgb: 0x3C3C43), dark: UIColor.lightGray)
        static var separator = UIColor(light: UIColor.darkGray, dark: UIColor.lightGray)
    }
    
}
