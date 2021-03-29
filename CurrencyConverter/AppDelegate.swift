//
//  AppDelegate.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/2/25.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		IwatchSessionUtil.shareManager.startSession()
		
		//这里判断是否第一次启动APP
//        UserDefaults.standard.removeObject(forKey: "everLaunched")
		if (!(UserDefaults.standard.bool(forKey: "everLaunched"))) {
			UserDefaults.standard.set(true, forKey:"everLaunched")
			self.window!.rootViewController = GuideViewController()
		}
		
        return true
    }
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		if url.host == nil {
			return true
		}

		//获取url以及参数
		let urlString = url.absoluteString
		let queryArray = urlString.components(separatedBy: "/")
        
        if self.window!.rootViewController is GuideViewController {
            // 在引导页退出app并打开today widget，点击设置或国旗，会崩溃
            return true
        }
		let navigationController: UINavigationController = self.window!.rootViewController as! UINavigationController
		let rootView = navigationController.visibleViewController as! ViewController

		switch queryArray[2] {
		case "settings": // currencyconverter://settings
			rootView.performSegue(withIdentifier: "showSettingsSegue", sender: nil)
		case "currencypicker": // currencyconverter://currencypicker/to/CNY
			if queryArray[3] == "from" {
				rootView.currencyPickerType = .from
			} else {
				rootView.currencyPickerType = .to
			}
			
			let controller = CurrencyPickerViewController()
			controller.currencyType = queryArray[3]
			controller.currencySymbol = queryArray[4]
			rootView.present(controller, animated: true, completion: nil)
		default: break
		}
		
		return true
	}

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

