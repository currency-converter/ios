//
//  Theme.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/5/3.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class Theme {
	
	// 0 白
	// 1 黑
	
	// 主背景色
	static let appBackgroundColor: [UIColor] = [
		UIColor.hex("efeef4"),
		UIColor.hex("121212")
	]
	
	// 货币文字颜色
	static let moneyLabelTextColor: [UIColor] = [
		UIColor.hex("000000"),
		UIColor.hex("ffffff")
	]
	
	// 导航栏样式
	static let barStyle: [UIBarStyle] = [
		UIBarStyle.default,
		UIBarStyle.blackTranslucent
	]
	
	// 状态栏样式
	static let statusBarStyle: [UIStatusBarStyle] = [
		UIStatusBarStyle.default,
		UIStatusBarStyle.lightContent
	]
	
	//货币选择页用的是自定义导航条，需要自己覆盖状态条背景
	static let statusBarBackgroundColor: [UIColor] = [
		UIColor.hex("f7f7f7"),
		UIColor.hex("171717")
	]
	
	// 单元格背景色
	static let cellBackgroundColor: [UIColor] = [
		UIColor.white,
		UIColor.black
	]
	
	// 单元格文字颜色
	static let cellTextColor: [UIColor] = [
		UIColor.black,
		UIColor.white
	]
	
	// 数字按钮背景色
	static let keyButtonBackgroundColor: [UIColor] = [
		UIColor.hex("dddddd"),
		UIColor.hex("424242")
	]
	
	// 数字文字颜色
	static let keyButtonTextColor: [UIColor] = [
		UIColor.black,
		UIColor.white
	]
	
	// 设置按钮背景色
	static let settingsButtonBackgroundColor: [UIColor] = [
		UIColor.hex("bbbbbb"),
		UIColor.hex("a5a5a5")
	]
	

}
