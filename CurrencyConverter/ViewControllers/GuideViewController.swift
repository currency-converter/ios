//
//  GuideViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/5/24.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController, UIScrollViewDelegate {
	
	let isDebug: Bool = false
	
	var pageControl: UIPageControl!
	var scrollView: UIScrollView!
	
	
	//页面数量
	var numOfPages = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.render()
    }
	
	func render() {
		let frame = self.view.bounds
		let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
		let marginLeft: CGFloat = 10
		let pageControlWidth: CGFloat = 70
		let pageControlHeight: CGFloat = 50

		//scrollView的初始化
		scrollView = UIScrollView()
		scrollView.frame = self.view.bounds
		scrollView.delegate = self
		//为了能让内容横向滚动，设置横向内容宽度为3个页面的宽度总和
		scrollView.contentSize = CGSize(width:frame.size.width * CGFloat(numOfPages), height:frame.size.height)
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.scrollsToTop = false
		for i in 0..<numOfPages {
			let imgWidth: CGFloat = frame.size.width - marginLeft * 2
			let imgHeight: CGFloat = imgWidth * 1.5
			let titleLabelHeight: CGFloat = 150
			
			let titleLabel: UILabel = UILabel(frame: CGRect(x: frame.size.width*CGFloat(i) + marginLeft, y: statusBarHeight, width: frame.size.width - marginLeft * 2, height: titleLabelHeight))
			titleLabel.numberOfLines = 4
			
			titleLabel.textAlignment = .center
			titleLabel.textColor = .white
			titleLabel.font = UIFont.systemFont(ofSize: 24)
			titleLabel.text = NSLocalizedString("guide.\(i)", comment: "")
			if isDebug {
				titleLabel.backgroundColor = .red
			}
			scrollView.addSubview(titleLabel)
			
			let imgX: CGFloat = frame.size.width * CGFloat(i) + marginLeft
			let imgY: CGFloat = titleLabelHeight + statusBarHeight
			let imgView: UIImageView = UIImageView()
			imgView.frame = CGRect(x: imgX, y: imgY, width: imgWidth, height: imgHeight)
			if let path = Bundle.main.path(forResource: "\(i)", ofType: "png") {
				imgView.image = UIImage(contentsOfFile: path)
			}
			scrollView.addSubview(imgView)
		}
		scrollView.contentOffset = CGPoint.zero
		self.view.addSubview(scrollView)
		
		//顶部对齐
		let pageControlX: CGFloat = (self.view.bounds.width - pageControlWidth)/2
		let pageControlY: CGFloat = self.view.bounds.height - pageControlHeight
		pageControl = UIPageControl(frame: CGRect(x: pageControlX, y: pageControlY, width: pageControlWidth, height: pageControlHeight))
		pageControl.numberOfPages = numOfPages
		pageControl.currentPage = 0
		self.view.addSubview(pageControl)
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let twidth = CGFloat(numOfPages-1) * self.view.bounds.size.width
		//如果在最后一个页面继续滑动的话就会跳转到主页面
		if scrollView.contentOffset.x > twidth {
			let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
			let viewController: UIViewController = mainStoryboard.instantiateInitialViewController()!
			self.present(viewController, animated: true, completion: nil)
		}
	}
	
	//UIScrollViewDelegate方法，每次滚动结束后调用
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		//通过scrollView内容的偏移计算当前显示的是第几页
		let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
		//设置pageController的当前页
		pageControl.currentPage = page
	}
	
}
