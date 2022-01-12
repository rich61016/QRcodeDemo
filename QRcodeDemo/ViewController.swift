//
//  ViewController.swift
//  QRcodeDemo
//
//  Created by YuHsiang on 2022/1/12.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
    
    private let disposbag = DisposeBag()
    
    private let showQRcodeBtn: UIButton = {
        let cb = UIButton()
        cb.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cb.layer.cornerRadius = 24
        cb.setTitle("開啟QRcode", for: .normal)
        cb.setTitleColor(.white, for: .normal)
        cb.backgroundColor = .black
        cb.snp.makeConstraints { make in
            make.height.equalTo(47)
            make.width.equalTo(176)
        }
        return cb
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
        setupView()
    }
    
    func layoutView(){
        view.addSubview(showQRcodeBtn)
        showQRcodeBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        
    }

    func setupView(){
        showQRcodeBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = QRcodeViewController()
                vc.modalPresentationStyle = .fullScreen
                self!.present(vc, animated: true, completion: nil)
                  }).disposed(by: disposbag)
    }

}

