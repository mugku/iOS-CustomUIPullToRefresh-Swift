//
//  CustomTableViewController.swift
//  CustomUIPullToRefresh
//
//  Created by DUBULEE on 2015. 10. 15..
//  Copyright © 2015년 DUBULEE. All rights reserved.
//

import UIKit

class CustomTableViewController: UITableViewController {
	var refreshParentView : UIView!
	var refreshColorBgView : UIView!
	var loadingBack : UIImageView!
	var loadingAbove : UIImageView!
	var isRefreshOverlap = false
	var isRefreshAnimate = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.initCustomPullToRefreshControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 20
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("CustomTableCell", forIndexPath: indexPath)
		cell.textLabel!.text = " Cell dubu"
		return cell
	}
}

extension CustomTableViewController {
	
	func initCustomPullToRefreshControl() {
		self.refreshControl = UIRefreshControl()
		
		self.refreshParentView = UIView(frame: self.refreshControl!.bounds)
		self.refreshParentView.backgroundColor = UIColor.clearColor()
		
		self.refreshColorBgView = UIView(frame: self.refreshControl!.bounds)
		self.refreshColorBgView.backgroundColor = UIColor.clearColor()
		
		loadingBack = UIImageView(image: UIImage(named: "apple.png"))
		self.loadingAbove = UIImageView(image: UIImage(named: "android.png"))
		
		self.refreshParentView.addSubview(self.loadingBack)
		self.refreshParentView.addSubview(self.loadingAbove)
		
		self.refreshParentView.clipsToBounds = true
		
		self.refreshControl!.tintColor = UIColor.clearColor()
		
		self.refreshControl!.addSubview(self.refreshColorBgView)
		self.refreshControl!.addSubview(self.refreshParentView)
		
		self.isRefreshOverlap = false
		self.isRefreshAnimate = false
		
		self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
	}
	
	func refresh(){
		let delay = 2.0
		let removeTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
		dispatch_after(removeTime, dispatch_get_main_queue()) { () -> Void in
			
			self.refreshControl!.endRefreshing()
		}
		// TODO FINISH
	}
	
	func animatePullToRefreshView() {
		
		var colorArray = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.blackColor(), UIColor.purpleColor()]
		
		struct ColorIndex {
			static var colorIndex = 0
		}
		
		self.isRefreshAnimate = true
		
		UIView.animateWithDuration(
			Double(0.3),
			delay: Double(0.0),
			options: UIViewAnimationOptions.CurveLinear,
			animations: {
				self.loadingAbove.transform = CGAffineTransformRotate(self.loadingAbove.transform, CGFloat(M_PI_2))
				self.refreshColorBgView!.backgroundColor = colorArray[ColorIndex.colorIndex]
				ColorIndex.colorIndex = (ColorIndex.colorIndex + 1) % colorArray.count
			},
			completion: { finished in
				if (self.refreshControl!.refreshing) {
					self.animatePullToRefreshView()
				}else {
					self.resetPullToRefreshAnimation()
				}
			}
		)
	}
	
	func resetPullToRefreshAnimation() {
		self.isRefreshAnimate = false
		self.isRefreshOverlap = false
		self.refreshColorBgView.backgroundColor = UIColor.clearColor()
	}
	
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		var refreshBounds = self.refreshControl!.bounds
		let pullDistance = max(0.0, -self.refreshControl!.frame.origin.y)
		let midX = self.tableView.frame.size.width / 2.0
		
		let refreshBgWidth = self.loadingBack.bounds.size.width
		let refreshBgWidthHalf =  refreshBgWidth / 2.0
		
		let refreshAvobeWidth = self.loadingAbove.bounds.size.width
		let refreshAvobeWidthHalf = refreshAvobeWidth / 2.0
		
		let ratio = min( max(pullDistance, 0.0), 100.0) / 100.0
		
		var refreshBgX = (midX +  refreshBgWidthHalf)  - ( refreshBgWidth * ratio)
		var refreshAvobeX = (midX - refreshAvobeWidth - refreshAvobeWidthHalf)  + (refreshAvobeWidth * ratio)
		
		if (fabsf(Float( refreshBgX - refreshAvobeX)) < 1.0) {
			self.isRefreshOverlap = true
		}
		
		if (self.isRefreshOverlap || self.refreshControl!.refreshing) {
			refreshBgX = midX -  refreshBgWidthHalf
			refreshAvobeX = midX - refreshAvobeWidthHalf
		}
		
		var  refreshBgFrame = self.loadingBack.frame
		refreshBgFrame.origin.x =  refreshBgX
		
		var refreshAvobeFrame = self.loadingAbove.frame
		refreshAvobeFrame.origin.x = refreshAvobeX
		
		self.loadingBack.frame =  refreshBgFrame
		self.loadingAbove.frame = refreshAvobeFrame
		
		refreshBounds.size.height = pullDistance
		
		self.refreshColorBgView.frame = refreshBounds
		self.refreshParentView.frame = refreshBounds
		
		if (self.refreshControl!.refreshing && !self.isRefreshAnimate) {
			self.animatePullToRefreshView()
		}
	}
}
