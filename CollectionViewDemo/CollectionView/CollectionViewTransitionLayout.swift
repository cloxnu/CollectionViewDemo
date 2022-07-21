//
//  CollectionViewTransitionLayout.swift
//  CollectionViewDemo
//
//  Created by Sidney Liu on 2022/3/31.
//

import UIKit

class CollectionViewTransitionLayout: UICollectionViewTransitionLayout {
    
    override func prepare() {
        super.prepare()
        print("[TransitionLayout] prepare progress: \(self.transitionProgress)")
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("[TransitionLayout] layoutAttributesForItem progress: \(self.transitionProgress)")
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("[TransitionLayout] layoutAttributesForElements progress: \(self.transitionProgress)")
        return super.layoutAttributesForElements(in: rect)
    }
    
    override func finalizeLayoutTransition() {
        print("[TransitionLayout] finalize progress: \(self.transitionProgress)")
        super.finalizeLayoutTransition()
    }
    
    override var transitionProgress: CGFloat {
        get {
            return super.transitionProgress
        }
        set {
            super.transitionProgress = newValue
            
        }
    }
    

}
