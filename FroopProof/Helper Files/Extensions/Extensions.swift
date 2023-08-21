//
//  Extensions+View.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import UIKit
import Foundation


extension UIApplication {
    func endEditing(_ force: Bool) {
        self.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow})
            .first?.endEditing(force)
    }
}

extension UserData {
    static func convert(from myData: MyData) -> UserData {
        let userData = UserData()
        userData.data = myData.data
        userData.froopUserID = myData.froopUserID
        userData.timeZone = myData.timeZone
        userData.firstName = myData.firstName
        userData.lastName = myData.lastName
        userData.phoneNumber = myData.phoneNumber
        userData.addressNumber = myData.addressNumber
        userData.addressStreet = myData.addressStreet
        userData.unitName = myData.unitName
        userData.addressCity = myData.addressCity
        userData.addressState = myData.addressState
        userData.addressZip = myData.addressZip
        userData.addressCountry = myData.addressCountry
        userData.profileImageUrl = myData.profileImageUrl
        userData.fcmToken = myData.fcmToken
        userData.badgeCount = myData.badgeCount
        userData.coordinate = myData.coordinate
        return userData
    }
}


extension MyData: CustomStringConvertible {
    var description: String {
        return """
        MyData:
        - firstName: \(firstName)
        - lastName: \(lastName)
        - phoneNumber: \(phoneNumber)
        - addressNumber: \(addressNumber)
        - addressStreet: \(addressStreet)
        - unitName: \(unitName)
        - addressCity: \(addressCity)
        - addressState: \(addressState)
        - addressZip: \(addressZip)
        - addressCountry: \(addressCountry)
        - profileImageUrl: \(profileImageUrl)
        - coordinate: \(coordinate)
        - geoPoint: \(geoPoint)
        """
    }
}


extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension Color {
    
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255 )
    
    func luminosity(_ value: Double) -> Color {
        let uiColor = UIColor(self)
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(UIColor(hue: hue, saturation: saturation, brightness: CGFloat(value), alpha: alpha))
    }
}

extension View{
    //MARK: Custom View Modifier
    func blurredSheet<Content: View>(_ style: AnyShapeStyle, show: Binding<Bool>, onDismiss: @escaping ()->(), @ViewBuilder content: @escaping ()->Content)-> some View{
        self
            .fullScreenCover(isPresented: show, onDismiss: onDismiss) {
                content()
                    .background(RemovebackgroundColor())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        Rectangle()
                            .fill(style)
                            .ignoresSafeArea(.container, edges: .all)
                    }
            }
    }
}


// MARK: HelperView
fileprivate struct RemovebackgroundColor: UIViewRepresentable{
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            uiView.superview?.superview?.backgroundColor = .clear
        }
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Date {
    func diff(numDays: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: numDays, to: self)!
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

extension String {
    
    var formattedPhoneNumber: String {
        let cleanedPhoneNumber = self.filter { "0"..."9" ~= $0 }
        let formattedPhoneNumber: String
        
        if cleanedPhoneNumber.count == 10 {
            let startIndex1 = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 3)
            let endIndex1 = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 5)
            let startIndex2 = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 6)
            let endIndex2 = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 9)
            
            let part1 = cleanedPhoneNumber.prefix(3)
            let part2 = cleanedPhoneNumber[startIndex1...endIndex1]
            let part3 = cleanedPhoneNumber[startIndex2...endIndex2]
            
            formattedPhoneNumber = "(\(part1)) \(part2)-\(part3)"
        } else {
            formattedPhoneNumber = self
        }
        
        return formattedPhoneNumber
    }
    
    var formattedPhoneNumberC: String {
        let cleanedPhoneNumber = self.filter { "0"..."9" ~= $0 }
        
        // Assuming that the country code is only 1 digit. Adjust the `countryCodeLength` as needed.
        let countryCodeLength = 1
        let startIndex = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: countryCodeLength)
        let phoneNumberWithoutCountryCode = String(cleanedPhoneNumber[startIndex...])
        
        let formattedPhoneNumber: String
        
        if phoneNumberWithoutCountryCode.count == 10 {
            let startIndex1 = phoneNumberWithoutCountryCode.index(phoneNumberWithoutCountryCode.startIndex, offsetBy: 3)
            let endIndex1 = phoneNumberWithoutCountryCode.index(phoneNumberWithoutCountryCode.startIndex, offsetBy: 5)
            let startIndex2 = phoneNumberWithoutCountryCode.index(phoneNumberWithoutCountryCode.startIndex, offsetBy: 6)
            let endIndex2 = phoneNumberWithoutCountryCode.index(phoneNumberWithoutCountryCode.startIndex, offsetBy: 9)
            
            let part1 = phoneNumberWithoutCountryCode.prefix(3)
            let part2 = phoneNumberWithoutCountryCode[startIndex1...endIndex1]
            let part3 = phoneNumberWithoutCountryCode[startIndex2...endIndex2]
            
            formattedPhoneNumber = "(\(part1)) \(part2)-\(part3)"
        } else {
            formattedPhoneNumber = self
        }
        
        return formattedPhoneNumber
    }
}

extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: image.cgImage!)
    }
}


extension Froop: CustomStringConvertible {
    var description: String {
        return "Froop(id: \(id), location: \(String(describing: froopLocationCoordinate)), ...)" // Add all the properties you want to print
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        } else if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? navigationController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? tabBarController
        } else {
            return self
        }
    }
}


extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return String(format: "%02lX%02lX%02lX", Int(r * 0xff), Int(g * 0xff), Int(b * 0xff))
    }

    convenience init?(hexString: String) {
        let r, g, b: CGFloat
        let a: CGFloat = 1.0

        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}




