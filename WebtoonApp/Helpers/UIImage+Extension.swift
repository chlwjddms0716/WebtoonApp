//
//  UIImage+Extension.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import UIKit

extension UIImage {
    func with(_ insets: UIEdgeInsets) -> UIImage {
         let targetWidth = size.width + insets.left + insets.right
         let targetHeight = size.height + insets.top + insets.bottom
         let targetSize = CGSize(width: targetWidth, height: targetHeight)
         let targetOrigin = CGPoint(x: insets.left, y: insets.top)
         let format = UIGraphicsImageRendererFormat()
         format.scale = scale
         let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
         return renderer.image { _ in
             draw(in: CGRect(origin: targetOrigin, size: size))
         }.withRenderingMode(renderingMode)
     }
    
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            // 적용할 tint 색상 설정
           
            // 렌더링 모드 변경 후 이미지 그리기
            withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
