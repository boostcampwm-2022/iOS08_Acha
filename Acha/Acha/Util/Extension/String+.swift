//
//  String+.swift
//  Acha
//
//  Created by 조승기 on 2022/11/21.
//

import UIKit

extension String {
    func convertToDateFormat(format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        if let date = dateFormatter.date(from: self) {
            return date
        }
        return Date()
    }
    
    func stringCheck(pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: self.count)
            if regex.firstMatch(in: self, range: range) != nil {
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func generateQRCode() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    func stringLimit(_ number: Int) -> String {
        return self.count <= number ? self : self.map { String($0) }[0..<number].joined()
    }
}
