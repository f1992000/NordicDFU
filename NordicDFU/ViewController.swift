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
var TargetCharacteristic: CBCharacteristic!
var TxCharacteristic: CBCharacteristic?
var TargetService: CBService!
var connectDeviceName = "DfuTarg"

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

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
    }



}

