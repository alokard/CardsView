import UIKit

protocol CardsViewDataSource {
    func numberOfCards() -> Int
    func cardCellForItem(at index: Int) -> UIView
    func emptyStateView() -> UIView?
}

enum SwipeDirection {
    case left
    case right
    case top
    case bottom
}

open class CardsView: UIView {
    
    var dataSource: CardsViewDataSource?
    var numberOfVisibleCells: Int = 4
    
    private var visibleCells = [UIView]()
    private var cardsPoolCount = 0
    
    func reloadData() {
        removeAllCardCells()
        guard let dataSource = dataSource else { return }
        
        let cardsCount = dataSource.numberOfCards()
        cardsPoolCount = cardsCount
        for i in 0..<min(cardsCount, numberOfVisibleCells) {
            let cell = dataSource.cardCellForItem(at: i)
            add(cardCell: cell, at: i)
        }
        
        if let emptyView = dataSource.emptyStateView() {
            add(emptyView: emptyView)
        }
        
        setNeedsLayout()
    }
    
    private func removeAllCardCells() {
        for cardCell in visibleCells {
            cardCell.removeFromSuperview()
        }
        visibleCells = []
    }
    
    private func add(cardCell: UIView, at index: Int) {
        adjustSizeTransform(for: cardCell, at: index)
        visibleCells.append(cardCell)
        insertSubview(cardCell, at: 0)
        cardsPoolCount -= 1
    }
    
    private func add(emptyView: UIView) {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: self.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func adjustSizeTransform(for cardCell: UIView, at index: Int) {
        var cardViewFrame = bounds
        let horizontalInset = (CGFloat(index) * 12)
        let verticalInset = CGFloat(index) * 12
        
        cardViewFrame.size.width -= 2 * horizontalInset
        cardViewFrame.origin.x += horizontalInset
        cardViewFrame.origin.y += verticalInset
        
        cardCell.frame = cardViewFrame
    }
    
    private func didSwipe(cell: UIView) {
        handleSwipedCell(cell)
        guard let dataSource = dataSource else { return }
        
        if cardsPoolCount > 0 {
            let newIndex = dataSource.numberOfCards() - cardsPoolCount
            
            add(cardCell: dataSource.cardCellForItem(at: newIndex), at: numberOfVisibleCells - 1)
            
            for (index, cardCell) in visibleCells.enumerated() {
                UIView.animate(withDuration: 0.2, animations: {
                    cardCell.center = self.center
                    self.adjustSizeTransform(for: cardCell, at: index)
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    private func handleSwipedCell(_ cell: UIView) {
        visibleCells.removeFirst()
        
        //TODO: call some delegate handler?
    }
}
