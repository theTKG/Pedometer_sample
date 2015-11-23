//
//  ViewController.swift
//  Pedometer
//
//  Created by Ooguchi Taiga on 2015/11/15.
//  Copyright © 2015年 Ooguchi Taiga. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //UUIDカラNSUUIDを作成
    let proximityUUID = NSUUID(UUIDString:"AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAB")
    var region  = CLBeaconRegion()
    var manager = CLLocationManager()

    var pedometer:CMPedometer = CMPedometer()
    var step_text: String = ""
    
    var myNameRegistButton: UIButton!
    var lastUpDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 個人認証用の名前
        NSUserDefaults.standardUserDefaults().setObject("サンプルさん", forKey: "name")
        NSUserDefaults.standardUserDefaults().setObject("2015-11-20", forKey: "lastUpDate")
        NSUserDefaults.standardUserDefaults().synchronize();
        
        
        //CLBeaconRegionを生成
        region = CLBeaconRegion(proximityUUID:proximityUUID!,identifier:"EstimoteRegion")
        
        //デリゲートの設定
        manager.delegate = self
        
        /*
        位置情報サービスへの認証状態を取得する
        NotDetermined   --  アプリ起動後、位置情報サービスへのアクセスを許可するかまだ選択されていない状態
        Restricted      --  設定 > 一般 > 機能制限により位置情報サービスの利用が制限中
        Denied          --  ユーザーがこのアプリでの位置情報サービスへのアクセスを許可していない
        Authorized      --  位置情報サービスへのアクセスを許可している
        */
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            //iBeaconによる領域観測を開始する
            print("観測開始")
            self.manager.startRangingBeaconsInRegion(self.region)
        case .NotDetermined:
            print("許可承認")
            //デバイスに許可を促す
            if( Int(UIDevice.currentDevice().systemVersion) >= 8) {
                //iOS8以降は許可をリクエストする関数をCallする
                self.manager.requestAlwaysAuthorization()
            }else{
                self.manager.startRangingBeaconsInRegion(self.region)
            }
        case .Restricted, .Denied:
            //デバイスから拒否状態
            print("Restricted")
        }

        
        pedometerQuery()
        
        
        // Labelを作成.
        let myLabel: UILabel = UILabel(frame: CGRectMake(0,0,300,300))
        myLabel.backgroundColor = UIColor.orangeColor()
        myLabel.layer.masksToBounds = true
        myLabel.layer.cornerRadius = 20.0
        myLabel.text = step_text
        myLabel.numberOfLines = 7
        myLabel.textColor = UIColor.whiteColor()
        myLabel.textAlignment = NSTextAlignment.Center
        myLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 200)
        self.view.addSubview(myLabel)
        
        // 名前登録ページ遷移のボタンの生成する.
        myNameRegistButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        myNameRegistButton.backgroundColor = UIColor.blueColor();
        myNameRegistButton.layer.masksToBounds = true
        myNameRegistButton.setTitle("名前を登録", forState: .Normal)
        myNameRegistButton.layer.cornerRadius = 50.0
        myNameRegistButton.layer.position = CGPoint(x: (self.view.bounds.width/6)*1 , y:(self.view.bounds.height/10)*9)
        myNameRegistButton.addTarget(self, action: "onClickNameRegistButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myNameRegistButton)
        
    }
    
    /*
    名前登録ボタン押下時のイベントセット
    */
    func onClickNameRegistButton(sender: UIButton){
        
        // 遷移するViewを定義する.
        let myNameRegist: NameRegist = NameRegist()
        
        // アニメーションを設定する.
        myNameRegist.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        // Viewの移動する.
        self.presentViewController(myNameRegist, animated: true, completion: nil)
        
    }
    
    //以下 CCLocationManagerデリゲートの実装---------------------------------------------->
    
    /*
    - (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
    Parameters
    manager : The location manager object reporting the event.
    region  : The region that is being monitored.
    */
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        manager.requestStateForRegion(region)
    }
    
    /*
    - (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
    Parameters
    manager :The location manager object reporting the event.
    state   :The state of the specified region. For a list of possible values, see the CLRegionState type.
    region  :The region whose state was determined.
    */
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion) {
        if (state == .Inside) {
            //領域内にはいったときに距離測定を開始
            manager.startRangingBeaconsInRegion(region)
        }
    }
    
    /*
    リージョン監視失敗（bluetoosの設定を切り替えたりフライトモードを入切すると失敗するので１秒ほどのdelayを入れて、再トライするなど処理を入れること）
    - (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
    Parameters
    manager : The location manager object reporting the event.
    region  : The region for which the error occurred.
    error   : An error object containing the error code that indicates why region monitoring failed.
    */
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("monitoringDidFailForRegion \(error)")
    }
    
    /*
    - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
    Parameters
    manager : The location manager object that was unable to retrieve the location.
    error   : The error object containing the reason the location or heading could not be retrieved.
    */
    //通信失敗
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
        
        // 出勤の処理を記載
        dakoku("出勤")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        
        // 退勤の処理を記載
        dakoku("退勤")
    }
    
    /*
    beaconsを受信するデリゲートメソッド。複数あった場合はbeaconsに入る
    - (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
    Parameters
    manager : The location manager object reporting the event.
    beacons : An array of CLBeacon objects representing the beacons currently in range. You can use the information in these objects to determine the range of each beacon and its identifying information.
    region  : The region object containing the parameters that were used to locate the beacons
    */
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons)
        
        if(beacons.count == 0) { return }
        //複数あった場合は一番先頭のものを処理する
        var beacon = beacons[0] as CLBeacon
        
        /*
        beaconから取得できるデータ
        proximityUUID   :   regionの識別子
        major           :   識別子１
        minor           :   識別子２
        proximity       :   相対距離
        accuracy        :   精度
        rssi            :   電波強度
        */
        if (beacon.proximity == CLProximity.Unknown) {
            print("Unknown Proximity")
             return
        } else if (beacon.proximity == CLProximity.Immediate) {
            print("Immediate")
        } else if (beacon.proximity == CLProximity.Near) {
            print("Near")
        } else if (beacon.proximity == CLProximity.Far) {
            print("Far")
        }

    }
    
    
    
    /**
    歩数計に関する一週間分の情報を返します。
    
    :returns: 歩数計に関する情報
    */
    func pedometerQuery() -> NSMutableArray {
        let result = NSMutableArray()
        
        let pedometer:CMPedometer = CMPedometer()
        if(!CMPedometer.isStepCountingAvailable()) {
            return result
        }
        
        let now:NSDate = NSDate()
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var from:NSDate = self.stringToDate(formatter.stringFromDate(now), isStart: true)
        var to:NSDate = self.stringToDate(formatter.stringFromDate(now), isStart: false)
        
        print(from)
        print(to)
        
//        from = self.dateByAddingDay(from, day: -1)
//        to = self.dateByAddingDay(to, day: -1)
        
        for i in 0...6 {
            let semaphore:dispatch_semaphore_t = dispatch_semaphore_create(0)
            
            pedometer.queryPedometerDataFromDate(from, toDate: to, withHandler: {(pedometerData, error) in
//                result[i] = [
//                    "steps": pedometerData!.numberOfSteps,
//                    "distance": pedometerData!.distance,
//                    "floorsAscended": pedometerData!.floorsAscended,
//                    "floorsDescended": pedometerData!.floorsDescended,
//                    "startDate": pedometerData!.startDate,
//                    "endDate": pedometerData!.endDate
//                ]
                print("startDate : \(pedometerData!.startDate)")
                print("endDate : \(pedometerData!.endDate)")
                print("steps : \(pedometerData!.numberOfSteps)")
                self.step_text += "\(pedometerData!.startDate) = \(pedometerData!.numberOfSteps) | "
                
                dispatch_semaphore_signal(semaphore)
            })
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            from = self.dateByAddingDay(from, day: -1)
            to = self.dateByAddingDay(to, day: -1)
        }
        
        return result
    }
    
    /**
    指定した日付に時分秒を追加して新しいNSDateを返します。
    
    :param: date もとのNSDate
    :param: isStart trueのとき00:00:00、falseのとき23:59:59を追加します
    :returns: 新しいNSDate
    */
    private func stringToDate(date: String, isStart: Bool) -> NSDate {
        let timestamp = (isStart) ? date + " 00:00:00" : date + " 23:59:59"
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.dateFromString(timestamp)!
    }
    
    /**
    指定した日数を加減した新しいNSDateを返します。
    
    :param: date もとのNSDate
    :param: day 加減する日数
    :returns: 新しいNSDate
    */
    private func dateByAddingDay(date: NSDate, day: Int) -> NSDate {
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        let components:NSDateComponents = NSDateComponents()
        components.day = day
        return calendar.dateByAddingComponents(components, toDate: date, options: NSCalendarOptions())!
    }
    
    /**
    出勤時間を打刻する
    */
    func dakoku(state: String) {
        let registName = NSUserDefaults.standardUserDefaults().objectForKey("name")!
        print(registName)

        if state == "出勤" {
            // 出勤時間を打刻
            // 前回登録日以降の歩数を登録
            lastUpDate = NSUserDefaults.standardUserDefaults().objectForKey("lastUpDate") as! String
            print(lastUpDate)
            
            // API を使って登録
            
        } else if state == "退勤" {
            // 退勤時間を打刻
            // API を使って登録
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

