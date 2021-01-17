//
//  ViewController.swift
//  ios_new_Sockets
//
//  Created by Syritx on 2021-01-17.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    let host = "ip-here" // i.e. x.x.x.x
    let port = 6060
    var socket : CFSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView()
        view.backgroundColor = .white
        
        let message_button = UIButton(type: .system)
        message_button.frame = CGRect(x: 20, y: 20, width: 200, height: 50)
        message_button.setTitle("Request data", for: .normal)
        message_button.addTarget(self, action: #selector(createMessage(_:)), for: .touchUpInside)
        
        let connection_button = UIButton(type: .system)
        connection_button.frame = CGRect(x: 20, y: 70, width: 200, height: 50)
        connection_button.setTitle("Connect", for: .normal)
        connection_button.addTarget(self, action: #selector(tryConnectToServer(_:)), for: .touchUpInside)
        
        let disconnect_button = UIButton(type: .system)
        disconnect_button.frame = CGRect(x: 20, y: 120, width: 200, height: 50)
        disconnect_button.setTitle("Disconnect", for: .normal)
        disconnect_button.addTarget(self, action: #selector(disconnect(_:)), for: .touchUpInside)
        
        view.addSubview(connection_button)
        view.addSubview(disconnect_button)
        view.addSubview(message_button)
        self.view = view
        
    }
    
    @objc func tryConnectToServer(_ sender: UIButton) {
        do {
            try connectToServer()
            try sendToServer(message: "hello, this is a test")
        }
        catch {}
    }
    
    @objc func createMessage(_ sender: UIButton) {
        do {
            try sendToServer(message: "[get_data]")
        }
        catch {}
    }
    
    @objc func disconnect(_ sender: UIButton) {
        do {
            try sendToServer(message: "disconnect_ed")
        }
        catch {}
    }
    
    func connectToServer(timeout: Int=10) throws {
        let inAddr = inet_addr(host)
        if inAddr == INADDR_NONE {
            throw SocketError.noValidAddress
        }

        socket = CFSocketCreate(kCFAllocatorDefault,
                                    AF_INET,
                                    SOCK_STREAM,
                                    IPPROTO_TCP,
                                    CFSocketCallBackType.readCallBack.rawValue,
                                    { (socket, callBackType, address, data, info) in
                                        (socket: socket, callBackType: callBackType, address: address, data: data, info: info)
                                    },
                                    nil)
        if socket == nil {
            throw SocketError.socketCreationFailed
        }

        var sin = sockaddr_in() // https://linux.die.net/man/7/ip
        sin.sin_len = __uint8_t(MemoryLayout.size(ofValue: sin))
        sin.sin_family = sa_family_t(AF_INET)
        sin.sin_port = UInt16(port).bigEndian
        sin.sin_addr.s_addr = inAddr

        let addressDataCF = NSData(bytes: &sin, length: MemoryLayout.size(ofValue: sin)) as CFData

        let socketErr = CFSocketConnectToAddress(socket, addressDataCF, CFTimeInterval(timeout))
        switch socketErr {
        case .success:
            print("connected")
        case .error:
            print("connection error")
            throw SocketError.connectionError
        case .timeout:
            print("connection timeout")
            throw SocketError.connectionTimeout
        }
    }
    
    func sendToServer(message: String) throws {
        let data = CFDataCreate(nil, message, message.count)
        CFSocketSendData(socket, nil, data, 0)
    }

    enum SocketError: Error {
        case noValidAddress
        case socketCreationFailed
        case connectionError
        case connectionTimeout
    }
}
