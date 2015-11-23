//
//  NameRegist.swift
//  Pedometer
//
//  Created by Ooguchi Taiga on 2015/11/23.
//  Copyright © 2015年 Ooguchi Taiga. All rights reserved.
//

import UIKit

class NameRegist: UIViewController, UITextFieldDelegate {
    
    var myName = ""
    var myTextField = UITextField(frame: CGRectMake(50,200,300,30))

    var myBackButton: UIButton!
    var mySaveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myName = NSUserDefaults.standardUserDefaults().objectForKey("name")!
        
        // 名前の入力欄を作成.
        myTextField.text = myName as? String
        myTextField.returnKeyType = UIReturnKeyType.Done
        myTextField.delegate = self
        myTextField.borderStyle = UITextBorderStyle.RoundedRect
        self.view.addSubview(myTextField)
        
        
        // 戻るボタンを作成
        myBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        myBackButton.backgroundColor = UIColor.blueColor()
        myBackButton.layer.masksToBounds = true
        myBackButton.setTitle("戻る", forState: .Normal)
        myBackButton.layer.cornerRadius = 50.0
        myBackButton.layer.position = CGPoint(x: (self.view.bounds.width/6)*4, y:(self.view.bounds.height/10)*9)
        myBackButton.addTarget(self, action: "onClickBackButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myBackButton)
        
        // 保存ボタンを作成
        mySaveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        mySaveButton.backgroundColor = UIColor.magentaColor()
        mySaveButton.layer.masksToBounds = true
        mySaveButton.setTitle("保存", forState: .Normal)
        mySaveButton.layer.cornerRadius = 50.0
        mySaveButton.layer.position = CGPoint(x: (self.view.bounds.width/6)*2, y:(self.view.bounds.height/10)*9)
        mySaveButton.addTarget(self, action: "onClickSaveButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(mySaveButton);
        
    }
    
    
    /*
    戻るボタン押下時
    */
    func onClickBackButton(sender: UIButton){
        
        // 前のviewに戻る
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    /*
    保存ボタン押下時
    */
    func onClickSaveButton(sender: UIButton){
        
        // 都道府県の設定を保存する処理
        print(myTextField.text!)
        NSUserDefaults.standardUserDefaults().setObject(myTextField.text!, forKey:"name")
        NSUserDefaults.standardUserDefaults().synchronize();
        
        // 前のviewに戻る
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        myTextField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}