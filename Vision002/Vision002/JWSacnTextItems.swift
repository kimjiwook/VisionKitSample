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
    var uuid:String = UUID().uuidString // UUID 키값
    var text:String = ""    // 인식한 Text
    var rect:CGRect = .zero // Text Rect값
    
    public init() {
        
    }
}
