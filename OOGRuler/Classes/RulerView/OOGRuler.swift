//
//  OOGRuler.swift
//  Ruler
//
//  Created by guoqiang on 2022/6/28.
//

import UIKit
import SnapKit

public protocol OOGRulerProtocol: AnyObject {
    // value: Inch: in , cm: cm, kg: 0.1kg, lb: 0.1 lb
    func valueChange(_ value: Double, _ tag: Int)
}

public class OOGRulerConfig {
    
    ///刻度宽度, 取整形 避免精度问题
    var itemWidth: Int = 10
    
    ///类型
    var type: GQRulerType = .cm
    
    ///尺子的宽度
    var rulerWidth: CGFloat = 340
    
    ///长刻度线高度
    var longLineViewHeight: CGFloat = 36
    
    var longLineViewTop: CGFloat = 12
    
    ///长刻度线宽度
    var longLineViewWight: CGFloat = 2
    
    ///长刻度线颜色
    var longLineViewColor = UIColor.lightGray
    
    ///短刻度线高度
    var shortLineViewHeight: CGFloat = 20
    
    ///短刻度线宽度
    var shortLineViewWeight: CGFloat = 2
    
    var shortLineViewTop: CGFloat = 20
    
    ///短刻度线 颜色
    var shortLineViewColor = UIColor.lightGray
    
    ///刻度是否切圆角
    var lineViewIsCorner = true
    
    ///选中刻度的颜色
    var selectedLineColor = UIColor.red
    
    ///选中刻度下方图标
    var selectedImage = UIImage(named: "selectedImage")
    
    ///刻度文字颜色
    var numColor = UIColor.black
    
    ///刻度文字大小
    var numFont = UIFont.systemFont(ofSize: 12)
    
    ///刻度文字高度
    var numHeight: CGFloat = 20
    
    ///刻度和文字的高度
    var margin: CGFloat = 8
    
    ///是否支持震动  ios 13以后支持
    var enbleFeedback = GQFeedbackType.different
    
    ///指针view， 宽度小于 等于 ruleritem 的两倍 高度从顶部开始, 需要把bounds 设置好
    var selectedView: UIView?
    
    ///刻度能否被点击
    var canSelected = false
    
    public init() {}
    
    enum GQFeedbackType {
        case none
        ///一样
        case same
        ///长短刻度不一样
        case different
    }
}

public enum GQRulerType {
    
    case cm
    case inch
    case kg
    case lb
    
    //精度
    var precision: Int {
        get {
            switch self {
            case .inch: return 12
            default: return 10
            }
        }
    }
    

    ///直尺的最大刻度， cm 这里一刻度 代表1 cm， 那么最大值 就是多少厘米，
    ///同理 kg这里单位是0.1kg  这里的最大值 就乘以 0.1
    var maxData: Int {
        get {
            switch self {
            case .kg: return 11501
            case .lb: return 23001
            case .cm, .inch: return 10001
            }
        }
    }
    
    //左边让的刻度数， kg lb 有小树 要乘以10
    var minAddKedu: Int {
        get {
            switch self {
            case .kg: return 50
            case .lb: return 110
            case .cm: return 3
            case .inch: return 1
            }
        }
    }
}

public class OOGRuler: UIView {
    private var collectioonView: UICollectionView!
    private var config: OOGRulerConfig!
    ///切换刻度尺子的时候 会存在 精度问题， 如体重lb 切换到kg， 这个可以避免
    private var currentValue: Double? = nil
    ///当前指针的刻度
    private var currentIndex = 0
    
    private var realRulerWidth: CGFloat = 0
    
    public weak var delegate: OOGRulerProtocol?
    
    public init(frame: CGRect, _ config: OOGRulerConfig) {
        super.init(frame: frame)
        
        self.config = config
        dealwithWith()
        createUI()
    }
    
    private func createUI() {
        
        let  layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CGFloat(config.itemWidth), height: config.longLineViewHeight+config.longLineViewTop*2+config.numHeight+config.margin)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectioonView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectioonView.backgroundColor = .white
        collectioonView.showsHorizontalScrollIndicator = false
        collectioonView.delegate = self
        collectioonView.dataSource = self
        collectioonView.contentInset = UIEdgeInsets(top: 0, left: realRulerWidth/2-CGFloat(config.itemWidth)/2, bottom: 0, right: realRulerWidth/2)
        collectioonView.register(OOGRulerCCell.self, forCellWithReuseIdentifier: "GQRulerCCell")
        addSubview(collectioonView)
        collectioonView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.equalTo(realRulerWidth)
            make.height.equalTo(layout.itemSize.height)
        }
        
        if config.selectedView == nil {
            let selectedView = OOGRulerSelectedView(frame: .zero, config)
            addSubview(selectedView)
            selectedView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.equalTo(config.itemWidth*2)
            }
        } else {
            addSubview(config.selectedView!)
            config.selectedView?.snp.makeConstraints({ make in
                make.top.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
            })
        }
    }
    
    public func refresh(_ type: GQRulerType, _ value: Double) {
        config.type = type
        collectioonView.reloadData()
        currentValue = value
        switch type {
        case .lb, .kg:
            /// 一个刻度为0.1 所要要乘以10
            /// 四舍五入 数据， 因为外面展示的就是四舍五入
            /// 减去从最小值开始 的偏移刻度， 左边不从0 开始
            /// 再乘以 每个刻度对应的宽度
            /// 再减去半屏幕的刻度， 因为指针在中间
            /// 加一个宽度。是因为奇数个指针在中间。从0 开始 需要偏移一个单位
            collectioonView.setContentOffset(.init(x: CGFloat((Int((value*10).rounded()) - type.maxData)*config.itemWidth) - realRulerWidth/2 + CGFloat(config.itemWidth/2), y: 0), animated: false)
            ///偏移量相同。不会调用didscroll方法
            if CGFloat((Int((value*10).rounded()) - type.maxData)*config.itemWidth) - realRulerWidth/2 + CGFloat(config.itemWidth/2) == collectioonView.contentOffset.x {
                currentValue = value
                scrollChangeValue(collectioonView.contentOffset.x)
            }
        case .cm, .inch:
            collectioonView.setContentOffset(.init(x: CGFloat((Int(value)-type.minAddKedu)*config.itemWidth) - realRulerWidth/2 + CGFloat(config.itemWidth/2), y: 0), animated: false)
            if CGFloat((Int(value)-type.minAddKedu)*config.itemWidth) - realRulerWidth/2 + CGFloat(config.itemWidth/2) == collectioonView.contentOffset.x {
                currentValue = value
                scrollChangeValue(collectioonView.contentOffset.x)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension OOGRuler: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        config.type.maxData
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GQRulerCCell", for: indexPath) as! OOGRulerCCell
        cell.refresh(indexPath.item+config.type.minAddKedu, config)
        return cell
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollChangeValue(scrollView.contentOffset.x)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollChangeValue(scrollView.contentOffset.x, true)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollChangeValue(scrollView.contentOffset.x, true)
    }
    
    private func scrollChangeValue(_ offset: CGFloat, _ needChange: Bool = false) {
        print(offset)
        ///切换尺子类型时会存在误差
        if  currentValue != nil {
            delegate?.valueChange(currentValue!,tag)
            currentValue = nil
            return
        }
        
        ///当前最左边的偏移
        let index = Int(offset) / config.itemWidth
        
        ///加上半个尺子最左边的偏移量。
        let realIndex = index + Int(realRulerWidth / 2) / config.itemWidth
        
        ///滑动结束 需要停止到整数刻度上
        if needChange {
            collectioonView.contentOffset.x = CGFloat(index) * CGFloat(config.itemWidth)
            feedBack(false,realIndex < 0)
        } else {
            if currentIndex != realIndex {
                if (realIndex + 1) % config.type.precision == 0 {
                    feedBack(false, realIndex < 0)
                } else {
                    feedBack(true, realIndex < 0)
                }
                currentIndex = realIndex
            }
        }
        backDataWith(realIndex)
    }
    
    private func feedBack(_ isLight: Bool, _ isOver: Bool) {
        if isOver { return }
        
        if config.enbleFeedback == .none {
            return
        } else if config.enbleFeedback == .same {
            if #available(iOS 13.0, *) {
                let impactLight = UIImpactFeedbackGenerator(style: .rigid)
                impactLight.impactOccurred(intensity: 0.5)
            } else {
                // Fallback on earlier versions
            }
            return
        }
        
        if #available(iOS 13.0, *) {
            if isLight {
                let impactLight = UIImpactFeedbackGenerator(style: .rigid)
                impactLight.impactOccurred(intensity: 0.5)
            } else {
                let impactLight = UIImpactFeedbackGenerator(style: .heavy)
                impactLight.impactOccurred(intensity: 0.5)
            }
        }
    }
    
    private func backDataWith(_ index: Int) {
        switch config.type {
        case .inch, .cm :
            delegate?.valueChange(Double(index+config.type.minAddKedu),tag)
        case .lb, .kg:
            //有小数点
            delegate?.valueChange(Double(index+config.type.minAddKedu)/10,tag)
        }
    }
}


extension OOGRuler {
    
    private func dealwithWith() {
        ///显示的总刻度个数
        var all = Int(config.rulerWidth / CGFloat(config.itemWidth))
        ///保证尺子上是奇数个刻度
        if all % 2 == 0 {
            all -= 1
        }
        realRulerWidth = CGFloat(all * config.itemWidth)
    }
}
