//
//  CollectionViewController.swift
//  CollectionViewDemo
//
//  Created by Sidney Liu on 2022/3/30.
//

import UIKit

private let reuseIdentifier = "CollectionViewCell"

class CollectionViewController: UICollectionViewController {
    
    lazy var layout = CollectionViewLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.collectionViewLayout = self.layout
        self.installsStandardGestureForInteractiveMovement = true
        
        self.view.backgroundColor = UIColor.systemBackground
    }
    
    // MARK: Pinch
    
    var numberOfColumnsWhenBegan = 0
    var transitionLayout: UICollectionViewTransitionLayout?
    var isZoomingIn = false
    var isZoomingOut = false
    
    func interactiveTransitionCompletion(completed: Bool, finish: Bool) {
        self.transitionLayout = nil
        self.isZoomingIn = false
        self.isZoomingOut = false
    }
    
    @IBAction func pinchGestureTriggered(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale / 2.0 + 0.5
        
        switch sender.state {
        case .began:
            if let layout = self.collectionView.collectionViewLayout as? CollectionViewLayout {
                self.numberOfColumnsWhenBegan = layout.numberOfColumns
            }
            
        case .changed:
            print(sender.scale)
            if sender.scale < 1 {
                if self.isZoomingIn {
                    self.isZoomingIn = false
                    self.collectionView.cancelInteractiveTransition()
                }
                
                if !self.isZoomingOut {
                    self.isZoomingOut = true
                    if let layout = self.collectionView.collectionViewLayout as? CollectionViewLayout {
                        let newLayout = layout.nextLevelLayout()
                        self.transitionLayout = self.collectionView.startInteractiveTransition(to: newLayout, completion: self.interactiveTransitionCompletion)
                    }
                }
                
                self.transitionLayout?.transitionProgress = 1 - sender.scale
                self.transitionLayout?.invalidateLayout()
            } else {
                if self.isZoomingOut {
                    self.isZoomingOut = false
                    self.collectionView.cancelInteractiveTransition()
                }
                
                if !self.isZoomingIn {
                    self.isZoomingIn = true
                    if let layout = self.collectionView.collectionViewLayout as? CollectionViewLayout {
                        let newLayout = layout.prevLevelLayout()
                        self.transitionLayout = self.collectionView.startInteractiveTransition(to: newLayout, completion: self.interactiveTransitionCompletion)
                    }
                }
                
                self.transitionLayout?.transitionProgress = 1 - 1 / sender.scale
                self.transitionLayout?.invalidateLayout()
            }
            
//            let (numberOfColumns, scaleThreshold) = self.layout.layoutLevel(withScale: scale, currentNumOfColumns: self.numberOfColumnsWhenBegan)
//            if numberOfColumns != self.layout.numberOfColumns {
//                self.layout = CollectionViewLayout()
//                self.layout.numberOfColumns = numberOfColumns
//                self.collectionView.setCollectionViewLayout(self.layout, animated: true) { finish in
//                }
//            }
        case .ended:
            print("touch ended \(sender.velocity)")
//            self.transitionLayout?.transitionProgress = 1.0
//            self.transitionLayout?.invalidateLayout()
            self.collectionView.finishInteractiveTransition()
            
//            if sender.velocity > 0 && self.layout.numberOfColumns <= self.numberOfColumnsWhenBegan {
//                self.layout = self.layout.prevLevelLayout()
//                self.collectionView.setCollectionViewLayout(self.layout, animated: true) { finish in
//                }
//            } else if sender.velocity < 0 && self.layout.numberOfColumns >= self.numberOfColumnsWhenBegan {
//                self.layout = self.layout.nextLevelLayout()
//                self.collectionView.setCollectionViewLayout(self.layout, animated: true) { finish in
//                }
//            }
            
        case .cancelled:
//            self.transitionLayout?.transitionProgress = 0.0
//            self.transitionLayout?.invalidateLayout()
            self.collectionView.cancelInteractiveTransition()
        default:
            break
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.layer.cornerRadius = 10
        cell.label.text = String(indexPath.item)
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        return CollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }
    
//    override func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
//        return CollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
//    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
