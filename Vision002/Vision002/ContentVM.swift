//
//  ContentVM.swift
//  Vision002
//
//  Created by JWMacBook on 2023/04/16.
//

import UIKit
import SwiftUI
import Vision

class ContentVM: ObservableObject {
    @Published public var isShowFullscreen = false // DocumentScan Full Flag
    @Published public var scanImages:[UIImage] = [UIImage]() // Scan Result Images

    // OCR Text,Rect 뺀 정보 (애니메이션을 위한 변수)
    @Published public var imageInfos:[JWScanTextItems] = [JWScanTextItems]()
}


// TextView Scan관련
extension ContentVM {
    // import Vision // Text 뽑아오는게 있내 <-- 필수
    // Text 빼오는거 샘플
    func detectText(_ image: UIImage) {
        guard let image = image.cgImage else {
            print("Invalid image")
            return
        }
        
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error detecting text: \(error)")
            } else {
                // 여기서 진행.
                self.handleDetectionResults(results: request.results, image: image)
            }
        }
        
        request.recognitionLanguages = ["ko_KR", "cn"] // 기본이 영어 이며, 한국어는 꼭 넣어줘야함
        request.recognitionLevel = .accurate
        
        // 요청 행위
        performDetection(request: request, image: image)
    }
    
    func handleDetectionResults(results: [Any]?, image:CGImage) {
        guard let results = results, results.count > 0 else {
            print("No text found")
            return
        }
        
        print("이미지 Text 빼오기")
        print(image)
        
        var textInfos = [JWScanTextItems]()
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    print(text.string)
                    print(text.confidence)
                    print(observation.boundingBox)
                    print("\n")
                
                    
                    let rect = VNImageRectForNormalizedRect(observation.boundingBox,
                                                            Int(image.width),
                                                            Int(image.height))
                    print(rect)
                    print("\n")
                    print("\n")
                    
                    let info = JWScanTextItems()
                    info.text = text.string
                    info.rect = rect
//                    texts.append(text.string) // 이름 값들 넣어놓기.
//                    rects.append(rect) // 좌표값 넣어놓기.
                    textInfos.append(info)
                    // break // 테스트좀 (하나만)
                }
            }
            // break // 테스트좀 (하나만)
        }
        
        // 데이터 넣어주기
        DispatchQueue.main.async {
            self.imageInfos.removeAll()
            self.imageInfos = textInfos
        }
    }
    
    func performDetection(request: VNRecognizeTextRequest, image: CGImage) {
        let requests = [request]
        
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform(requests)
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
}
