//NSRegularExpressionUtil
/*
 simpreboot © 2021 DrewCrawfordApps LLC
 Unless explicitly acquired and licensed from Licensor under another
 license, the contents of this file are subject to the Reciprocal Public
 License ("RPL") Version 1.5, or subsequent versions as allowed by the RPL,
 and You may not copy or use this file in either source code or executable
 form, except in compliance with the terms and conditions of the RPL.

 All software distributed under the RPL is provided strictly on an "AS
 IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND
 LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT
 LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE, QUIET ENJOYMENT, OR NON-INFRINGEMENT. See the RPL for specific
 language governing rights and limitations under the RPL.
 */
import Foundation
struct Result: RandomAccessCollection {
    func index(after i: Int) -> Int {
        i+1
    }
    
    let startIndex  = 0
    
    var endIndex: Int { match.numberOfRanges }
    
    let match: NSTextCheckingResult
    let stringView: String
    
    subscript(group: Int) -> Substring {
        let range = match.range(at: group)
        let h = stringView.index(stringView.startIndex, offsetBy: range.location)
        let t = stringView.index(h, offsetBy: range.length)
        return stringView[h..<t]
    }
}


extension NSRegularExpression {
    func firstResult(in string: String) -> Result? {
        guard let match = firstMatch(in: string, options: .init(), range: NSRange(location: 0, length: string.count)) else { return nil }
        return Result(match:match, stringView: string)
    }
}
