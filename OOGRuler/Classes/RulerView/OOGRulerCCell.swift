//
//  GQRulerCCell.swift
//  TestAa
//
//  Created by guoqiang on 2022/4/29.
//

import UIKit
import SnapKit

public class OOGRulerCCell: UICollectionViewCell {
    
    let lingLineView = UIView()
    let shortLineView = UIView()
    let numLB = UILabel()
    var config = OOGRulerConfig()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createUI()
    }
    
    private func createUI() {
        lingLineView.backgroundColor = config.longLineViewColor
        lingLineView.layer.masksToBounds = true
        lingLineView.layer.cornerRadius = config.lineViewIsCorner ? config.longLineViewWight/2 : 0
        contentView.addSubview(lingLineView)
        lingLineView.snp.makeConstraints { make in
            make.top.equalTo(config.longLineViewTop)
            make.width.equalTo(config.longLineViewWight)
            make.height.equalTo(config.longLineViewHeight)
            make.centerX.equalToSuperview()
        }
        
        shortLineView.backgroundColor = config.shortLineViewColor
        shortLineView.layer.masksToBounds = true
        shortLineView.layer.cornerRadius = config.lineViewIsCorner ? config.shortLineViewWeight/2 : 0
        contentView.addSubview(shortLineView)
        shortLineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(config.shortLineViewTop)
            make.width.equalTo(config.shortLineViewWeight)
            make.height.equalTo(config.shortLineViewHeight)
        }
        
        numLB.textColor = config.numColor
        numLB.font = config.numFont
        numLB.textAlignment = .center
        contentView.addSubview(numLB)
        numLB.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(config.itemWidth*4)
            make.height.equalTo(config.numHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    func refresh(_ num: Int, _ config: OOGRulerConfig) {
        self.config = config
        let showNum = num % config.type.precision == 0
        if config.type == .inch {
            numLB.text = "\(num/12)"
        } else if config.type == .cm {
            numLB.text = "\(num)"
        } else {
            numLB.text = "\(num/10)"
        }
        numLB.isHidden = !showNum
        shortLineView.isHidden = showNum
        lingLineView.isHidden = !showNum
        
        lingLineView.backgroundColor = config.longLineViewColor
        lingLineView.layer.cornerRadius = config.lineViewIsCorner ? config.longLineViewWight/2 : 0
        lingLineView.snp.remakeConstraints { make in
            make.top.equalTo(config.longLineViewTop)
            make.width.equalTo(config.longLineViewWight)
            make.height.equalTo(config.longLineViewHeight)
            make.centerX.equalToSuperview()
        }
        
        shortLineView.backgroundColor = config.shortLineViewColor
        shortLineView.layer.cornerRadius = config.lineViewIsCorner ? config.shortLineViewWeight/2 : 0
        shortLineView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(config.shortLineViewTop)
            make.width.equalTo(config.shortLineViewWeight)
            make.height.equalTo(config.shortLineViewHeight)
        }
        
        numLB.textColor = config.numColor
        numLB.font = config.numFont
        numLB.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(config.itemWidth*4)
            make.height.equalTo(config.numHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
