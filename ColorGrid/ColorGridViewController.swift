//
//  ColorGridViewController.swift
//  TopprDemo
//
//  Created by kanchan yadav on 5/16/17.
//  Copyright © 2017 kanchan yadav. All rights reserved.
//

/**
 DESCRIPTION: 
    1. I have fixed the width and height of each cell for now. So i can get total horizontal and vertical cells count using Screen Width and Height.
    2. I am using this count to calculate frame for each cell. 
    3. I have created a func to generate unique tag using these horizonal and vertical indexes of a cell,added UIPanGestureRecognizer to each cell view and added then to self.view.
    4. if user performs PanGesture, panGestureHandling selector is called, which gets  object of the cell using tag assigned to it and a helper function to animate this cell.
 */

import UIKit

class ColorGridViewController: UIViewController,UIGestureRecognizerDelegate{
    
    private let cellWidth = CGFloat(31)
    private let cellHeight = CGFloat(31)
    private var previousCellIndex = (0,0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.renderViewsOnScreen()
    }

    /**
     Description: this func does horizontal and vertical index calculation for cell(similar to matrices), adds UIPanGestureREcognizer, creates a unique tag for each cell which i will use later user user performs pan gesture to get that view.
     */
    private func renderViewsOnScreen(){
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        let horizontalCellsCount = Int(floor(screenWidth/cellWidth))
        let verticalCellsCount = Int(floor(screenHeight/cellHeight))
        var i = 0
        var j = 0
        while j < verticalCellsCount {
            while i < horizontalCellsCount {
                let currentCellFrame = self.calculateFrameForView(horizontalIndex: i, verticalIndex: j)
                let currentCell = self.getViewForFrame(frame: currentCellFrame)
                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ColorGridViewController.panGestureHandling(gesture:)))
                panGestureRecognizer.delegate = self
                let cellTag = self.getTag(horizontalIndex: i, verticalIndex: j)
                currentCell.tag  = cellTag
                currentCell.addGestureRecognizer(panGestureRecognizer)
                self.view.addSubview(currentCell)
                i += 1
            }
            i = 0
            j += 1
        }
    }
    
    /**
     Description: This func is used to calculate frame for a given horizontal and Vertical index. Cell Height and Width are kept fixed.
    */
    func calculateFrameForView(horizontalIndex:Int,verticalIndex:Int) -> CGRect {

        let colorViewFame = CGRect(x:CGFloat(cellWidth*CGFloat(horizontalIndex)) , y: CGFloat(cellHeight*CGFloat(verticalIndex)), width: CGFloat(cellWidth), height: CGFloat(cellHeight))
        
        return colorViewFame
    }
    
    /**
     Description: Once we have calculated the frame, here we create uiview's and assign unique tag to each of them which will be used later.
     */
    func getViewForFrame(frame:CGRect)->UIView{
        let view = UIView(frame: frame)
        view.layer.borderWidth  = 1.0
        view.layer.borderColor = UIColor.blue.cgColor
        let randomColor =  UIColor(colorLiteralRed: random(), green: random(), blue: random(), alpha: 1.0)
        view.backgroundColor = randomColor
        return view
    }
    
    /**
     Description: This func generated a unique number from horizontal and vertical Index of Cell.
     */
    private func getTag(horizontalIndex:Int,verticalIndex:Int) -> Int{
        
        let multiplyOfSum = ((horizontalIndex+verticalIndex)*(horizontalIndex+verticalIndex+1))/2 + verticalIndex
        return multiplyOfSum
    }
    
    /**
     Description: random number generator func to create random colors.
     */
    func random() -> Float {
        return Float(arc4random()) / Float(UInt32.max)
    }

    /**
     Description: UIPanGestureRecognizer selector func
     */
    func panGestureHandling(gesture: UIPanGestureRecognizer){
        if let initialView = gesture.view {
            self.view.bringSubview(toFront: initialView)
            
            if gesture.state == UIGestureRecognizerState.began {
                self.animateView(view: initialView)
                
            } else if gesture.state == UIGestureRecognizerState.changed {
                //handle movement
                if self.viewChangedFor(point: gesture.location(in: self.view)){
                    let location = gesture.location(in: self.view)
                    if let currentView = self.getViewForPoint(location: location){
                        self.view.bringSubview(toFront: currentView)
                        self.animateView(view: currentView)
                    }
                }
            }
        }
    }
    
    /**
     Description: this func zooms in and zoom out a given view.
     */
    private func animateView(view:UIView){
        
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform(scaleX: 3, y: 3)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                view.transform = CGAffineTransform(scaleX:1,y:1)
            }
        })
    }

    /**
     Description: To animate a cell, its UIView object is needed. I have already assigned unique tags (which was calculated based on horizontal and vertical index and i can calculate these both from location ) to each cell view while creating them. That can be used now to retrieve UIView objects for cell now.
     */
    private func getViewForPoint(location:CGPoint) -> UIView?{
        
        let horizontalIndex = Int(location.x/CGFloat(cellWidth))
        let verticalIndex = Int(location.y/CGFloat(cellHeight))
        previousCellIndex.0 = horizontalIndex
        previousCellIndex.1 = verticalIndex
        let currentCellTag = self.getTag(horizontalIndex: horizontalIndex, verticalIndex: verticalIndex)
        let cell = self.view.viewWithTag(currentCellTag)
        return cell
        //get current cell horizontal and vertical index. ..
        //from that calculate tag 
        //get subview with tag
        
    }

    /**
     Description: this func check if user moved to another cell while performing pan gesture. IF user moved to another cell then we will animate that cell.
     */
    private func viewChangedFor(point:CGPoint)->Bool{
        let horizontalIndex = Int(point.x/CGFloat(cellWidth))
        let verticalIndex = Int(point.y/CGFloat(cellHeight))
        
        if previousCellIndex.0 == horizontalIndex && previousCellIndex.1 == verticalIndex {
            return false
        }
        return true
    }

}


