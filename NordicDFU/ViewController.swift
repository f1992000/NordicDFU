//
//  ViewController.swift
//  NordicDFU
//
//  Created by  DARFON on 2019/12/19.
//  Copyright © 2019  DARFON. All rights reserved.
//

import UIKit
import CoreBluetooth
import iOSDFULibrary

var MacCentralManager: CBCentralManager!
var TargetPeripheral: CBPeripheral!
var connectDeviceName = "DfuTarg"
var DFUFileName = "DFU.zip"

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate {

   override func viewDidLoad() {
        super.viewDidLoad()
        MacCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //检查蓝牙设备是否有在更新
        if central.state == CBManagerState.poweredOn {
            print("did update:\(central.state)")
            // 蓝牙设备确实有反应了开始搜索
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Start Scanning")
        } else {
            //蓝牙设备没有更新的话，报告原因
            print("BLE on this Mac is not ready")
            switch central.state {
            case .unknown:
                print("蓝牙central.state is .unknown")
            case .resetting:
                print("蓝牙central.state is .resetting")
            case .unsupported:
                print("蓝牙central.state is .unsupported")
            case .unauthorized:
                print("蓝牙central.state is .unauthorized")
            case .poweredOff:
                print("蓝牙central.state is .poweredOff")
            case .poweredOn:
                print("蓝牙central.state is .poweredOn")
            @unknown default:
                print("UnKnowError")
            }
        }
    }


    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == connectDeviceName{
            TargetPeripheral = peripheral
            TargetPeripheral.delegate = self  // 初始化peripheral的delegate
            MacCentralManager.stopScan()
            MacCentralManager.connect(TargetPeripheral) //连接
            print("\(peripheral) is connected") // 调试用
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connection Confirmed!")
        startDFU()
    }

    func startDFU(){
 
        let filePath = NSHomeDirectory()+"/Documents/"+DFUFileName
        do{
          let fileList = try FileManager.default.contentsOfDirectory(atPath: filePath)
          for file in fileList{
            print(file)
          }
        }
        catch{
            print("Cannot list directory")
        }
        
        let selectedFirmware = DFUFirmware(urlToZipFile:URL(fileURLWithPath: filePath))

        let initiator = DFUServiceInitiator().with(firmware: selectedFirmware!)
        // Optional:
        // initiator.forceDfu = true/false // default false
        // initiator.packetReceiptNotificationParameter = N // default is 12
        initiator.logger = self // - to get log info
        initiator.delegate = self // - to be informed about current state and errors
        initiator.progressDelegate = self // - to show progress bar
        // initiator.peripheralSelector = ... // the default selector is used
        let controller = initiator.start(target: TargetPeripheral)
    }
        
        func dfuStateDidChange(to state: DFUState) {
            print("state: \(state.description())")
        }
        
        func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
            print("dfu error : \(message)")
        }
        
        func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
            print("progress: \(progress)")
        }
        
        func logWith(_ level: LogLevel, message: String) {
            print("logWith (\(level.name())) : \(message)")
        }

}

