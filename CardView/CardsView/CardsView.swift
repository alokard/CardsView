import UIKit

protocol CardsViewDataSource {
    func numberOfCards() -> Int
    func cardCellForItem(at index: Int) -> CardCellView
    func emptyStateView() -> UIView?
}

class CardCellView: UIView {
    
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
    
    private var visibleCells = [CardCellView]()
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
    
    private func add(cardCell: CardCellView, at index: Int) {
        adjustSizeTransform(for: cardCell, at: index)
        visibleCells.append(cardCell)
        insertSubview(cardCell, at: 0)
        cardsPoolCount -= 1
    }
    
    private func add(emptyView: UIView) {
        
    }
    
    private func adjustSizeTransform(for cardCell: CardCellView, at index: Int) {
        
    }
    
    private func didSwipe(cell: CardCellView) {
        guard let dataSource = dataSource else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            //TODO: complete card move off the screen animation
        }) { completed in
            cell.removeFromSuperview()
            if let index = self.visibleCells.index(of: cell) {
                self.visibleCells.remove(at: index)
            }
        }
        
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
}
