//
//  QRcodeViewController.swift
//  QRcodeDemo
//
//  Created by YuHsiang on 2022/1/12.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import AVFoundation

class QRcodeViewController: UIViewController ,AVCaptureMetadataOutputObjectsDelegate{
    
    var captureSesion:AVCaptureSession?
    var previewLayer:AVCaptureVideoPreviewLayer!
    private let disposeBag = DisposeBag()
    
    private var isScanMode: Bool = true
    
    private let cancelBtn: UIButton = {
        let cb = UIButton()
        cb.setImage(UIImage(named: "btn_cancel_invite"), for: .normal)
        cb.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
        return cb
    }()
    
    private var scanImage: UIImageView = {
        let ti = UIImageView(image: UIImage(named: "image_qrcode_scan"))
        ti.snp.makeConstraints { make in
            make.height.equalTo(297)
            make.width.equalTo(297)
        }
        return ti
    }()
    
    private let showQRcodeBtn: UIButton = {
        let cb = UIButton()
        cb.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cb.layer.cornerRadius = 24
        cb.setImage(UIImage(named: "btn_showQR"), for: .normal)
        cb.semanticContentAttribute = .forceLeftToRight
        cb.backgroundColor = .white
        cb.setTitle("顯示QR碼", for: .normal)
        cb.setTitleColor(.black, for: .normal)
        cb.imageEdgeInsets =  UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)

        cb.snp.makeConstraints { make in
            make.height.equalTo(47)
            make.width.equalTo(176)
        }
        return cb
    }()
    
    private let camView: UIView = {
        let av = UIView()
        av.snp.makeConstraints { make in
            make.height.equalTo(UIScreen.main.bounds.height*0.8)
            make.width.equalTo(UIScreen.main.bounds.width)
            }
        return av
    }()
    
    private var cardView: UIView = {
        let ti = UIView()
        ti.layer.cornerRadius = 10
        ti.backgroundColor = .white
        ti.snp.makeConstraints { make in
            make.height.equalTo(297)
            make.width.equalTo(297)
        }
        ti.isHidden = true
        return ti
    }()
    
    private var myQRcode: UIImageView = {
        let ti = UIImageView()
        return ti
    }()
    
    private let QRcodeString: UILabel = {
        let hl = UILabel()
        hl.textAlignment = .center
        hl.font = UIFont.systemFont(ofSize: 17)
        hl.textColor = .black
        return hl
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.gray
        layoutView()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if(captureSesion?.isRunning == false){
                captureSesion?.startRunning()
            }
        }

    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

             setQRCodeScan()
        displayQRCodeImage()
        
        
       
    }
    
    //掃QRCode的動作
        func setQRCodeScan(){
            
            //實體化一個AVCaptureSession物件
            captureSesion = AVCaptureSession()
            
            //AVCaptureDevice可以抓到相機和其屬性
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {return}
            let videoInput:AVCaptureDeviceInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            }catch let error {
                print(error)
                return
            }
            if (captureSesion?.canAddInput(videoInput) ?? false ){
                captureSesion?.addInput(videoInput)
            }else{
                return
            }
            
            //AVCaptureMetaDataOutput輸出影音資料，先實體化AVCaptureMetaDataOutput物件
            let metaDataOutput = AVCaptureMetadataOutput()
            if (captureSesion?.canAddOutput(metaDataOutput) ?? false){
                captureSesion?.addOutput(metaDataOutput)
                
                //關鍵！執行處理QRCode
                metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                //metadataOutput.metadataObjectTypes表示要處理哪些類型的資料，處理QRCODE
                metaDataOutput.metadataObjectTypes = [.qr, .ean8 , .ean13 , .pdf417]
                
            }else{
                return
            }
            
            //用AVCaptureVideoPreviewLayer來呈現Session上的資料
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSesion!)
            //顯示size
            previewLayer.videoGravity = .resizeAspectFill
            //呈現在camView上面
            previewLayer.frame = camView.layer.frame
            //加入畫面
            view.layer.addSublayer(previewLayer)
            
            
            //開始影像擷取呈現鏡頭的畫面
            captureSesion?.startRunning()
        }
        
        //使用AVCaptureMetadataOutput物件辨識QR Code，此AVCaptureMetadataOutputObjectsDelegate的委派方法metadataOutout會被呼叫
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSesion?.startRunning()
            if let metadataObject = metadataObjects.first{
                
                //AVMetadataMachineReadableCodeObject是從OutPut擷取到barcode內容
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {return}
                //將讀取到的內容轉成string
                guard let stringValue = readableObject.stringValue else {return}
             
                //將string資料放到label元件上
//                print(stringValue)
                QRcodeString.text = stringValue
//                captureSesion?.stopRunning()
               
                
               
            }
        }
    
    func displayQRCodeImage(){
        
        let myString: String = "QrcodeDemo"
        let data = myString.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        DispatchQueue.main.async{ [self] in
            myQRcode.image = UIImage(ciImage: scaledQrImage)
        }
    }
    

    func layoutView(){
        
        view.addSubview(camView)
        camView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
        }
        
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(25)
        }
        
        view.addSubview(scanImage)
        scanImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
        }
        
        view.addSubview(showQRcodeBtn)
        showQRcodeBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(scanImage.snp.bottom).offset(80)
        }
        
        view.addSubview(QRcodeString)
        QRcodeString.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-80)
        }
        
       
        view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
        }
        
        cardView.addSubview(myQRcode)
        myQRcode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
      
        
        cancelBtn.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        scanImage.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        showQRcodeBtn.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        cardView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
       
    }

    func setupView(){
        
        cancelBtn.rx.tap
            .subscribe(onNext: { _ in
                self.dismiss(animated: false, completion: nil)
                })
                .disposed(by: disposeBag)
        
        showQRcodeBtn.rx.tap
            .subscribe(onNext: { [self] _ in
                if isScanMode {
                    showQRcodeBtn.setTitle("掃描QR碼", for: .normal)
                    showQRcodeBtn.setImage(UIImage(named: "btn_hideQR"), for: .normal)
                    captureSesion?.stopRunning()
                    cardView.isHidden = false
                    
                } else {
                    showQRcodeBtn.setTitle("顯示QR碼", for: .normal)
                    showQRcodeBtn.setImage(UIImage(named: "btn_showQR"), for: .normal)
                    captureSesion?.startRunning()
                    cardView.isHidden = true
                }
                isScanMode = !isScanMode
                })
                .disposed(by: disposeBag)
       
    }


}
