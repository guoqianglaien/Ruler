//
//  ViewController.swift
//  OOGRuler
//
//  Created by guoqiang@laien.io on 06/28/2022.
//  Copyright (c) 2022 guoqiang@laien.io. All rights reserved.
//

import UIKit
import OOGRuler
import SnapKit

class ViewController: UIViewController, OOGRulerProtocol {
    func valueChange(_ value: Double, _ tag: Int) {
        if tag == 0 {
            firstLb.text = "\(value)cm"
        } else {
            secondLb.text = "\(value)lb"
        }
    }

    let firstLb = UILabel()
    let secondLb = UILabel()
    let lb3 = UILabel()
    let lb4 = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstLb.textAlignment = .center
        view.addSubview(firstLb)
        firstLb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(50)
        }
        
        let ruler = OOGRuler(frame: .init(x: 0, y: 0, width: 340, height: 88), OOGRulerConfig())
        view.addSubview(ruler)
        ruler.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(100)
            make.width.equalTo(340)
            make.height.equalTo(88)
        }
        view.layoutIfNeeded()
        ruler.refresh(.cm, 180)
        ruler.delegate = self
        ruler.tag = 0
        
        secondLb.textAlignment = .center
        view.addSubview(secondLb)
        secondLb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ruler.snp.bottom).offset(100)
        }
        
        let ruler1 = OOGRuler(frame: .init(x: 0, y: 0, width: 340, height: 88), OOGRulerConfig())
        view.addSubview(ruler1)
        ruler1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondLb.snp.bottom).offset(30)
            make.width.equalTo(340)
            make.height.equalTo(88)
        }
        view.layoutIfNeeded()
        ruler1.refresh(.kg, 100)
        ruler1.delegate = self
        ruler1.tag = 1
        
        
    }
}
