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
    // 1. Text 빼오는거 샘플
    func detectText(_ image: UIImage) {
        guard let image = image.cgImage else {
            print("Invalid image")
            return
        }
        
        // 2. VNRecognizeTextRequest 준비
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error detecting text: \(error)")
            } else {
                // 여기서 진행.
                self.handleDetectionResults(results: request.results, image: image)
            }
        }
        
        /*
         recognitionLanguages 를 포함하지 않으면, 기본적으로 영어임.
         한국어를 포함할꺼면 꼭 ko_KR 넣어줘야함.
         , "cn", "jp"
         */
        request.recognitionLanguages = ["ko_KR"]
        request.recognitionLevel = .accurate
        
        // 2-1. VNRecognizeTextRequest 요청 행위
        performDetection(request: request, image: image)
    }
    
    // 3. VNRecognizeTextRequest 결과 분석 후 Model에 저장
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
                
                    // Vision 에서 비율로 준 boundingBox 값을 이미지 크기에 맞게 변환
                    let rect = VNImageRectForNormalizedRect(observation.boundingBox,
                                                            Int(image.width),
                                                            Int(image.height))
                    print(rect)
                    print("\n")
                    print("\n")
                    
                    // 모델에 필요한 값 저장해놓기
                    let info = JWScanTextItems()
                    info.text = text.string
                    info.rect = rect
                    textInfos.append(info)
                }
            }
        }
        
        // 데이터 넣어주기
        DispatchQueue.main.async {
            self.imageInfos.removeAll()
            self.imageInfos = textInfos
        }
    }
    
    // 요청 행위
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
