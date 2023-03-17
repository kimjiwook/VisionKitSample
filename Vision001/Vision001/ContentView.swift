//
//  ContentView.swift
//  Vision001
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
                        .padding()
                }
            }
        }
        .fullScreenCover(isPresented: $vm.isShowFullscreen) {
            DocumentScanningViewAdapter { images in
                // 도큐멘트 스캔 닫기
                vm.isShowFullscreen = false
                
                // 결과 후 적용 애니메이션 처리
                withAnimation {
                    if let images = images {
                        vm.scanImages = images
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
