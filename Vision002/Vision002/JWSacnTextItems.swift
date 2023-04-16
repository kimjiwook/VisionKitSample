//
//  JWSacnTextItems.swift
//  Vision002
//
//  Created by JWMacBook on 2023/04/16.
//

import UIKit
import SwiftUI

// Scan된 이미지에서 Text 및 rect 뽑아와서 담아주는 Model
open class JWScanTextItems: Identifiable, ObservableObject {
    var uuid:String = UUID().uuidString
    var text:String = ""
    var rect:CGRect = .zero
    
    public init() {
        
    }
}
