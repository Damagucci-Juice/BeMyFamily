//
//  String+extension.swift
//  BeMyFamily
//
//  Created by Gucci on 12/27/25.
//

import Foundation

extension String {
    func limitText(to limit: Int) -> String {
        if self.count > limit {
            let index = self.index(self.startIndex, offsetBy: limit)
            return String(self[..<index]) + "..."
        }
        return self
    }
}
