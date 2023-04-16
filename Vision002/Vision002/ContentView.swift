//
//  ContentView.swift
//  Vision002
//
//  Created by JWMacBook on 2023/03/17.
//
/*
 2023. 03. 17 Kimjiwook
 Vision Kit의 Document Scan Sample 작업
 */

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ContentVM()
    
    // 타이머 관련
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State var value = 0.0
    
    var body: some View {
        ScrollView {
            LazyVStack {
                // 1. 버튼영역
                HStack {
                    // 1. 문서스캔
                    Button {
                        // 문서스캔 열어주기.
                        vm.isShowFullscreen = true
                    } label: {
                        HStack {
                            Image(systemName: "scanner")
                            Text("문서스캔")
                        }
                    }
                    
                    // 2. 이미지 전체삭제
                    Button {
                        vm.scanImages = [UIImage]()
                        vm.imageInfos = [JWScanTextItems]()
                    } label: {
                        HStack {
                            Image(systemName: "x.square.fill")
                            Text("전체삭제")
                        }
                    }
                    
                }
                .padding()
                
                // 2. 이미지 영역
                ForEach(vm.scanImages, id:\.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .onReceive(timer) { input in
                            // 초당 호출됨. (너무 빠른느낌)
                            withAnimation(Animation.easeIn(duration: 1.0)) {
                                if self.value >= 0.1 {
                                    self.value = 0.0
                                } else {
                                    self.value = 0.3
                                }
                            }
                        }
                        .overlay {
                            GeometryReader { proxy in
                                ZStack {
                                    /*
                                     이미지 원본 기준으로 사이즈 및 좌표값 보정절차 필요.
                                     */
                                    let proxySize = proxy.size
                                    
                                    let widthScale = image.size.width / proxy.size.width
                                    let heightScale = image.size.height / proxy.size.height
                                    // print("")
                                    /*
                                     Vision 기준은 왼쪽아래 부터 시작이라는데,,,
                                     UIKit 기준 X,Y (0,0) 으로 시작했는데, 아닌듯.
                                     Y 기준이 반대임.. 환장하것내
                                     https://stackoverflow.com/questions/64759383/bounding-box-from-vndetectrectanglerequest-is-not-correct-size-when-used-as-chil
                                     */
                                    
                                    // 좌표값들 체크하기
                                    ForEach(vm.imageInfos) { info in
                                        let width = (info.rect.width / widthScale)
                                        let height = (info.rect.height / heightScale)
                                        
                                        let positionX = (info.rect.origin.x / widthScale) + (width / 2)
                                        let positionY = proxySize.height - (info.rect.origin.y / heightScale) - (height / 2)
                                        
                                        JWOCRTextRectPath()
                                            .frame(width: width, height: height)
                                            .foregroundColor(.blue.opacity(value))
                                            .position(x: positionX, y: positionY)
                                            .tag(UUID().uuidString)
                                    }
                                }
                            }
                        }
                }
                
                // 3. 텍스트 영역
                ForEach(vm.imageInfos) { info in
                    Text(info.text)
                        .padding()
                        .foregroundColor(.white)
                        .background(.red)
                        .clipShape(Capsule())                        
                }
            }
        }
        .fullScreenCover(isPresented: $vm.isShowFullscreen) {
            DocumentScanningViewAdapter { images in
                // 도큐멘트 스캔 닫기
                vm.isShowFullscreen = false
                
                // 결과 후 적용 애니메이션 처리
                withAnimation {
                    /*
                     이미지 한장으로 테스트 진행.
                     OCR 기능이 우선
                     */
                    if let image = images?.first {
                        vm.scanImages = [image]
                        vm.detectText(image) // Text 인식 하기
                    } else {
                        vm.scanImages = [UIImage]()
                    }
                }
            }
            .edgesIgnoringSafeArea(.all) // safeArea 영역 재설정(전체덮기)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//MARK: - #. 사각형 테투리 (Path)
public struct JWOCRTextRectPath:Shape {
    public func path(in rect:CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        return path
    }
}
