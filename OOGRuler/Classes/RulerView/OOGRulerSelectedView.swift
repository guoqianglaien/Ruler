//
//  GQRulerSelectedView.swift
//  TestAa
//
//  Created by guoqiang on 2022/4/29.
//

import UIKit
import SnapKit

public class OOGRulerSelectedView: UIView {
    
    init(frame: CGRect, _ config: OOGRulerConfig) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        let lineView = UIView()
        lineView.backgroundColor = config.selectedLineColor
        lineView.layer.masksToBounds = true
        lineView.layer.cornerRadius = config.lineViewIsCorner ? (config.longLineViewWight > config.shortLineViewWeight ? config.longLineViewWight : config.shortLineViewWeight)/2 : 0
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.equalTo(config.longLineViewWight > config.shortLineViewWeight ? config.longLineViewWight : config.shortLineViewWeight)
            make.height.equalTo(config.longLineViewHeight+2*config.longLineViewTop)
        }
        
        let placeView = UIView()
        placeView.backgroundColor = .white
        addSubview(placeView)
        placeView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(config.numHeight)
        }
        
        let selectedIcon = UIImageView(image: .init(named: "selectedImage"))
        addSubview(selectedIcon)
        selectedIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(2)  
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
