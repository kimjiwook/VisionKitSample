//
//  ContentVM.swift
//  Vision001
//
//  Created by JWMacBook on 2023/03/17.
//

import UIKit
import SwiftUI

class ContentVM: ObservableObject {
    @Published public var isShowFullscreen = false // DocumentScan Full Flag
    @Published public var scanImages:[UIImage] = [UIImage]() // Scan Result Images
}
