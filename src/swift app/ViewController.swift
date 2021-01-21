//
//  ViewController.swift
//  swift-sockets
//
//  Created by Syritx on 2021-01-21.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    var readStream : Unmanaged<CFReadStream>?
    var writeStream : Unmanaged<CFWriteStream>?
    
    var inputStream : InputStream!
    var outputStream : OutputStream!
    
    var temperatureLabel : UILabel!
    var humidityLabel : UILabel!
    
    var HOST : NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        HOST = "192.168.0.165"
        let uiView = UIView()
        uiView.backgroundColor = .black
        
        let width = UIScreen.main.bounds.width-40
        let yOffset = 20
        let inlineOffset = 10
        
        let messageButton = UIButton()
        messageButton.frame = CGRect(x: 20, y: 20+yOffset+inlineOffset, width: Int(width), height: 50)
        messageButton.setTitle("Request Data", for: .normal)
        messageButton.backgroundColor = .link
        messageButton.setTitleColor(.white, for: .normal)
        messageButton.addTarget(self, action: #selector(requestDataFromServer(_:)), for: .touchUpInside)
        
        let disconnect = UIButton()
        disconnect.frame = CGRect(x: 20, y: 120+yOffset+inlineOffset*3, width: Int(width), height: 50)
        disconnect.setTitle("Disconnect", for: .normal)
        disconnect.backgroundColor = .link
        disconnect.setTitleColor(.white, for: .normal)
        disconnect.addTarget(self, action: #selector(disconnectFromServer(_:)), for: .touchUpInside)
        
        let connect = UIButton()
        connect.frame = CGRect(x: 20, y: 70+yOffset+inlineOffset*2, width: Int(width), height: 50)
        connect.setTitle("Connect", for: .normal)
        connect.backgroundColor = .link
        connect.setTitleColor(.white, for: .normal)
        connect.addTarget(self, action: #selector(connectToServer(_:)), for: .touchUpInside)
        
        temperatureLabel = UILabel()
        temperatureLabel.frame = CGRect(x: 20, y: 170+yOffset+inlineOffset*4, width: Int(width), height: 50)
        temperatureLabel.text = "[TEMPERATURE]: 0.0"
        temperatureLabel.textColor = .white
        temperatureLabel.backgroundColor = .black
        
        humidityLabel = UILabel()
        humidityLabel.frame = CGRect(x: 20, y: 200+yOffset+inlineOffset*5, width: Int(width), height: 50)
        humidityLabel.text = "[HUMIDITY]: 0.0"
        humidityLabel.textColor = .white
        humidityLabel.backgroundColor = .black
        
        self.view = uiView
        view.addSubview(messageButton)
        view.addSubview(disconnect)
        view.addSubview(connect)
        view.addSubview(temperatureLabel)
        view.addSubview(humidityLabel)
    }
    
    @objc func requestDataFromServer(_ sender: UIButton) {
        
        let dat = "[get_data]".data(using: .utf8)!
        
        dat.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            else {
                return
            }
            outputStream!.write(pointer, maxLength: dat.count)
        }
    }
    
    @objc func connectToServer(_ sender: UIButton) {
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, HOST, 6060, &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        inputStream.open()
        outputStream.open()
    }
    
    @objc func disconnectFromServer(_ sender: UIButton) {
        let dat = "disconnect_ed".data(using: .utf8)!
        
        dat.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            else {
                return
            }
            outputStream!.write(pointer, maxLength: dat.count)
        }
        outputStream!.close()
    }
}

extension ViewController : StreamDelegate {
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
            
        case .hasBytesAvailable:
            print("message")
            getReceivedMessage(stream: aStream as! InputStream)
            
        default:
            print("others")
        }
    }
    
    func getReceivedMessage(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
        var totalLength = 0
        
        while stream.hasBytesAvailable {
            let len = stream.read(buffer, maxLength: 1024)
            if len < 0, let error = stream.streamError {
                print(error)
                break
            }
            print("lol a test lol")
            totalLength = len
            break
        }
        
        print("length is bigger than 0");
        guard let output = String(bytesNoCopy: buffer,
                            length: totalLength,
                            encoding: .utf8,
                            freeWhenDone: true)
        else {
            return
        }
        print(totalLength)
        
        if output.starts(with: "[command_buffer]") {
            print(output)
            let commands = output.components(separatedBy: "[command_buffer]")
            for word in commands {
                print(word)
                if word.starts(with: "[temperature]:") {
                    temperatureLabel.text = word.uppercased()
                }
                
                if word.starts(with: "[humidity]:") {
                    humidityLabel.text = word.uppercased()
                }
            }
        }
    }
}
