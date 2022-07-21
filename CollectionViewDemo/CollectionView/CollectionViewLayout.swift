//
//  CollectionViewLayout.swift
//  CollectionViewDemo
//
//  Created by Sidney Liu on 2022/3/30.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout {

    // 2:12:3:12:2
    // 两个一列
    private let edgeInsetTimes = 2
    private let innerInsetTimes = 3
    private let cellWidthTimes = 12
    
    private let cellRatio = 1.3
    
    var numberOfColumns = 2
    private let numberOfColumnsLimit = 1...6
    
    private var contentSize = CGSize.zero
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    func layoutLevel(withScale scale: Double, currentNumOfColumns: Int) -> (numberOfColumns: Int, thresholdScale: Double) {
        let currentTotalTimes = self.totalTimes(numberOfColumns: currentNumOfColumns)
        
        if scale < 1 && currentNumOfColumns < self.numberOfColumnsLimit.upperBound {
            for num in (currentNumOfColumns+1...self.numberOfColumnsLimit.upperBound).reversed() {
                let scaleThreshold = Double(currentTotalTimes) / Double(self.totalTimes(numberOfColumns: num))
                if scale <= scaleThreshold {
                    return (num, scaleThreshold)
                }
            }
        } else if scale > 1 && currentNumOfColumns > self.numberOfColumnsLimit.lowerBound {
            for num in self.numberOfColumnsLimit.lowerBound...currentNumOfColumns-1 {
                let scaleThreshold = Double(currentTotalTimes) / Double(self.totalTimes(numberOfColumns: num))
                if scale >= scaleThreshold {
                    return (num, scaleThreshold)
                }
            }
        }
        
        return (currentNumOfColumns, 1.0)
    }
    
    func nextLevelLayout() -> CollectionViewLayout {
        if self.numberOfColumns >= self.numberOfColumnsLimit.upperBound {
            return self
        }
        let layout = CollectionViewLayout()
        layout.numberOfColumns = self.numberOfColumns + 1
        return layout
    }
    
    func prevLevelLayout() -> CollectionViewLayout {
        if self.numberOfColumns <= self.numberOfColumnsLimit.lowerBound {
            return self
        }
        let layout = CollectionViewLayout()
        layout.numberOfColumns = self.numberOfColumns - 1
        return layout
    }
    
    func totalTimes(numberOfColumns num: Int) -> Int {
        return self.edgeInsetTimes * 2 + self.innerInsetTimes * (num - 1) + self.cellWidthTimes * num
    }

    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        self.contentSize = collectionView.bounds.size
        self.cachedAttributes.removeAll()
        
        let totalTimes = self.edgeInsetTimes * 2 + self.innerInsetTimes * (self.numberOfColumns - 1) + self.cellWidthTimes * self.numberOfColumns
        let unitLength = self.contentSize.width / CGFloat(totalTimes)
        
        let cellWidth = unitLength * CGFloat(self.cellWidthTimes)
        let cellHeight = cellWidth * self.cellRatio
        
        var lastHeight = CGFloat(self.edgeInsetTimes) * unitLength
        
        for idx in 0..<collectionView.numberOfItems(inSection: 0) {
            
            let currentColumn = idx % self.numberOfColumns
            let cellX = CGFloat(self.edgeInsetTimes) * unitLength + CGFloat(currentColumn * (self.innerInsetTimes + self.cellWidthTimes)) * unitLength
            
            let frame = CGRect(x: cellX, y: lastHeight, width: cellWidth, height: cellHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: idx, section: 0))
            attributes.frame = frame
            self.cachedAttributes.append(attributes)
            
            self.contentSize.height = frame.maxY + CGFloat(self.edgeInsetTimes) * unitLength
            if currentColumn == self.numberOfColumns - 1 {
                lastHeight += cellHeight + CGFloat(self.edgeInsetTimes) * unitLength
            }
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var resultAttributesArray = [UICollectionViewLayoutAttributes]()
        
        // Find any cell that sits within the query rect.
        guard let lastIndex = cachedAttributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else {
                  return resultAttributesArray
              }
        
        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            resultAttributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            resultAttributesArray.append(attributes)
        }
        
        return resultAttributesArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cachedAttributes[indexPath.item]
    }
    
    // Binary Search
    func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }
}
