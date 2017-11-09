//
//  ViewController.swift
//  CardView
//
//  Created by Eugene Tulusha on 01.11.17.
//  Copyright © 2017 Eugene Tulusha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cardsView: CardsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        cardsView.backgroundColor = .red
        cardsView.dataSource = self
        cardsView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: CardsViewDataSource {
    func numberOfCards() -> Int {
        return 5
    }
    
    func cardCellForItem(at index: Int) -> UIView {
        return SwipableCardCell(frame: cardsView.bounds)
    }
    
    func emptyStateView() -> UIView? {
        return nil
    }
    
    
}

