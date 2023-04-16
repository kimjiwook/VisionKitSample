//
//  DocumentScanningViewAdapter.swift
//  Vision002
//
//  Created by JWMacBook on 2023/03/17.
//
/*
 2023. 03. 17 Kimjiwook
 DocumentScan SwiftUI로 호출로직 구현
 아직은 SwiftUI 자체 제공이 없어서 UIKit으로 구현한 부분을 사용함.
 */

import SwiftUI
import VisionKit

//MARK: - #. DocumentSacn
public struct DocumentScanningViewAdapter: UIViewControllerRepresentable {
    private let scannerHandler: ([UIImage]?) -> Void
    
    public init(completion: @escaping ([UIImage]?) -> Void) {
        self.scannerHandler = completion
    }
    
    public typealias UIViewControllerType = VNDocumentCameraViewController
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentScanningViewAdapter>) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<DocumentScanningViewAdapter>) {}
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(completion: scannerHandler)
    }
    
    // Delegate
    final public class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let scannerHandler: ([UIImage]?) -> Void
        
        init(completion: @escaping ([UIImage]?) -> Void) {
            self.scannerHandler = completion
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            //            print("Document camera view controller did finish with ", scan)
            //            let recognizer = TextRecognizer(cameraScan: scan)
            //            recognizer.recognizeText(withCompletionHandler: completionHandler)
            
            
            // 찍은 갯수 만큼 진행
            var images = [UIImage]()
            for pageIdx in 0 ..< scan.pageCount {
                let img = scan.imageOfPage(at: pageIdx)
                // 이미지 가져오서 만들어주기.
                images.append(img)
            }
            
            // 결과 전달하기.
            scannerHandler(images)
        }
        
        public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            scannerHandler(nil)
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document camera view controller did finish with error ", error)
            scannerHandler(nil)
        }
    }
}
