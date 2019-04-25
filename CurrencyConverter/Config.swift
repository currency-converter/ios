//
//  Config.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/4/24.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import Foundation

class Config {
	
	//groupId
	static let groupId: String = "group.com.zhongzhi.currencyconverter"
	
	// api
	static let updateRateUrl: String = "https://cc.beta.\u{71}\u{75}\u{6E}\u{61}\u{72}.com/api/rates?ios=1"
	
	// 数字字体名称
	static let numberFontName: String = "Avenir"
	
	// UserDefault 默认值
	static let defaults: [String: Any] = [
		// 小数位数
		"decimals": 2,
		// 使用千位分隔符
		"usesGroupingSeparator": true,
		// 是否使用按键声音
		"sounds": false,
		"fromSymbol": "USD",
		"toSymbol": "CNY",
		"autoUpdateRate": true,
		"rateUpdatedFrequency": RateUpdatedFrequency.daily.rawValue,
		"isCustomRate": false,
		"rateUpdatedAt": 1556017639,
		"rates": [
			"AED":3.6729,"AFN":77.4,"ALL":110.06,"AMD":481.48,"ANG":1.785,"AOA":317.839,"ARS":42.415,"AUD":1.406,"AWG":1.78,"AZN":1.6995,"BAM":1.7411,"BBD":2,"BDT":84.35,"BGN":1.73852,"BHD":0.377,"BIF":1817.5,"BMD":1,"BND":1.3567,"BOB":6.86,"BRL":3.9326,"BSD":1,"BTN":69.625,"BWP":10.6333,"BYN":2.09,"BYR":20020,"BZD":1.9978,"CAD":1.33737,"CDF":1635.45,"CHF":1.01998,"CLF":0.0238,"CLP":664.01,"CNY":6.7195,"COP":3153,"CRC":592.5,"CUC":0.995,"CUP":1,"CVE":97.85,"CZK":22.8788,"DJF":177.5,"DKK":6.63648,"DOP":50.64,"DZD":118.92,"EGP":17.15,"ERN":14.99,"ETB":28.51,"EUR":0.8888,"FJD":2.11,"FKP":0.7694,"GBP":0.76899,"GEL":2.6875,"GHS":5.1285,"GIP":0.7696,"GMD":49.3,"GNF":9126,"GTQ":7.6235,"GYD":205.49,"HKD":7.84373,"HNL":24.373,"HRK":6.5954,"HTG":83.2,"HUF":285.2,"IDR":14075,"ILS":3.5954,"INR":69.613,"IQD":1190,"IRR":42000,"ISK":120.3,"JMD":129.13,"JOD":0.707,"JPY":111.891,"KES":101.35,"KGS":69.6759,"KHR":4026,"KMF":436.27,"KPW":900,"KRW":1141.4,"KWD":0.3041,"KYD":0.82,"KZT":377.7,"LAK":8599,"LBP":1505.5,"LKR":174.51,"LRD":167.02,"LSL":14.15,"LTL":2.8345,"LVL":0.5078,"LYD":1.3899,"MAD":9.594,"MDL":17.73,"MGA":3505,"MKD":54.44,"MMK":1531,"MNT":2633.33,"MOP":8.0787,"MRO":355,"MUR":34.7,"MVR":15.57,"MWK":725.36,"MXN":18.8723,"MYR":4.1252,"MZN":64,"NAD":14.184,"NGN":357,"NIO":32.822,"NOK":8.51777,"NPR":110.95,"NZD":1.5012,"OMR":0.3849,"PAB":1,"PEN":3.3035,"PGK":3.3759,"PHP":52.03,"PKR":141.3,"PLN":3.811,"PYG":6220,"QAR":3.6395,"RON":4.2277,"RSD":104.5951,"RUB":63.7303,"RWF":882.05,"SAR":3.7498,"SBD":8.0947,"SCR":13.68,"SDG":45,"SEK":9.3354,"SGD":1.35707,"SHP":0.7696,"SLL":8925,"SOS":570,"SRD":7.43,"STD":21425.4,"SVC":8.75,"SYP":514.98,"SZL":14.1835,"THB":31.95,"TJS":9.4393,"TMT":3.41,"TND":3.0148,"TOP":2.3145,"TRY":5.8362,"TTD":6.7445,"TWD":30.844,"TZS":2298,"UAH":26.625,"UGX":3727,"USD":1,"UYU":32.234,"UZS":8405,"VEF":248209,"VND":23165,"VUV":111.47,"WST":2.6346,"XAF":582.62,"XCD":2.7,"XDR":0.720915,"XOF":582.62,"XPF":105.5,"YER":249.4,"ZAR":14.1874,"ZMW":12.33,"ZWL":321
		]
	]
}
