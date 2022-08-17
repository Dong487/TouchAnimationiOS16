//
//  Home.swift
//  TouchAnimationiOS16
//
//  Created by DONG SHENG on 2022/8/17.
//

import SwiftUI

struct Home: View {
    
    // MARK: Gesture State
        @GestureState var location: CGPoint = .zero
    var body: some View {
        
        GeometryReader{ proxy in
            let size = proxy.size
            //MARK: To Fit Info Whole View
            // Calculating Item Count with the help of Height & Width (利用 size 算出適合的項目數量 )
            // In a Row We Have 10 Items
            let width = (size.width / 10)
            // .rounded() 四捨五入到整數位 -> return整數
            // 多排 * 10
            let itemCount = Int((size.height / width).rounded()) * 10
            
            // MARK: For Solid Linear Gradient
            // 顏色漸層 的 遮罩 (剛好相反 Zstack(顏色漸層在底下) )
            LinearGradient(
                colors: [.cyan , .yellow ,.mint , .pink , .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .mask{
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0), count: 10) ,spacing: 0) {
                    ForEach(0..<itemCount ,id: \.self){ _ in
                        GeometryReader{ innerProxy in
                            let rect = innerProxy.frame(in: .named("Gesture"))
                            let scale = itemScale(rect: rect, size: size)
                            
                            // MARK: Instead Of Manual Calculation (代替人工計算?)
                            // We're going to use UIKit's CGAffineTransform
                            let transformedRect = rect.applying(.init(scaleX: scale ,y: scale)) // 123123
                            
                            // MARK: Transforming Location Too
                            let transformedLocation = location.applying(.init(scaleX: scale ,y: scale)) // 123123
                            
                            RoundedRectangle(cornerRadius: 4)
                                .scaleEffect(scale) // 位置 1
                            
                            // MARK: For Effect 1
                            // We Need to Re-Locate Every Item To Currently Draaging position (重新定位每個項目)
                                .offset(x: (transformedRect.midX - rect.midX) ,y: (transformedRect.midY - rect.midY))
                                .offset(x: location.x - transformedLocation.x ,y: location.y - transformedLocation.y)
                            // MARK: For Effect 2 Simply Replace Scale Loaction (動畫效果2 只要更改 .scale的位置 上面移到下面)
//                                .scaleEffect(scale) // 位置 2
                            
                        }
                        .padding(5)
                        .frame(height: width)
                    }
                }
            }
        
            
        }
        .padding(15)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($location, body: { value, out, _ in
                    out = value.location
                })
        )
        .coordinateSpace(name: "Gesture")
        .preferredColorScheme(.dark)
    }
}

struct Home_Previews: PreviewProvider {
    
    static var previews: some View {
        Home()
    }
}


extension Home{
    
    // 判斷點下去的位置 距離多少 做縮放 (直線距離 利用rect的location 算三角形斜邊)
    // MARK: Calculating Scaale For Each Item With the Help Of Pythagorean Theorem
    func itemScale(rect: CGRect ,size: CGSize) -> CGFloat {
        let a = location.x - rect.midX
        let b = location.y - rect.midY
        
        let root = sqrt((a * a) + (b * b)) // sqrt平方根計算
        let diagonalValue = sqrt((size.width * size.width) + (size.height * size.height))
        
        // MARK: For More Detail Divide Dignonal Value
        
        // MARK: Main Grid Magnification Effect
        // 這邊給一個值 將會是 動畫中圓形size Ex: 150
        let scale = (root - 150) / 150
        // MARK: FOr ALL Other Effects (其他效果)
//        let scale = root / (diagonalValue / 2) // 這邊改 值 會有不同等級的視覺效果
        
        
        let modifiedScale = location == .zero ? 1 : ( 1 - scale)
        
        // MARK: To Avoid SeifUI Transform Warning
        return modifiedScale > 0 ? modifiedScale : 0.001
    }
}
