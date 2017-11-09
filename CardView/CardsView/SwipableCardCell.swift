import Foundation
import UIKit

protocol SwipableCardCellDelegate: class {
    func swiped(_ card: SwipableCardCell, to direction: SwipeDirection)
    func tapped(_ card: SwipableCardCell)
}

class SwipableCardCell: UIView {
    weak var delegate: SwipableCardCellDelegate?
    
    var leftOverlay: UIView?
    var rightOverlay: UIView?
    var topOverlay: UIView?
    var bottomOverlay: UIView?
    
    private let actionMargin: CGFloat = 120.0
    private let rotationStrength: CGFloat = 320.0
    private let rotationAngle: CGFloat = CGFloat(Double.pi) / CGFloat(8.0)
    private let rotationMax: CGFloat = 1
    private let scaleStrength: CGFloat = -2
    private let scaleMax: CGFloat = 1.02
    
    private var xFromCenter: CGFloat = 0.0
    private var yFromCenter: CGFloat = 0.0
    private var originalPoint = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragEvent(gesture:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEvent(gesture:)))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        
        self.addContentView(frame)
    }
    
    private func addContentView(_ frame: CGRect) {
        let container = UIView(frame: CGRect(x: 30, y: 20, width: frame.width - 60, height: frame.height - 40))
        let label = UILabel(frame: container.bounds)
        label.text = "element"
        label.textAlignment = .center
        label.backgroundColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 48, weight: UIFont.Weight.thin)
        label.clipsToBounds = true
        label.layer.cornerRadius = 16
        container.addSubview(label)
        
        container.layer.shadowRadius = 4
        container.layer.shadowOpacity = 1.0
        container.layer.shadowColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 0)
        container.layer.shouldRasterize = true
        container.layer.rasterizationScale = UIScreen.main.scale
        self.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureOverlays() {
        self.configureOverlay(overlay: self.leftOverlay)
        self.configureOverlay(overlay: self.rightOverlay)
    }
    
    private func configureOverlay(overlay: UIView?) {
        if let o = overlay {
            self.addSubview(o)
            o.alpha = 0.0
        }
    }
    
    @objc private func dragEvent(gesture: UIPanGestureRecognizer) {
        xFromCenter = gesture.translation(in: self).x
        yFromCenter = gesture.translation(in: self).y
        
        switch gesture.state {
        case .began:
            self.originalPoint = self.center
            break
        case .changed:
            let rStrength = min(xFromCenter / self.rotationStrength, rotationMax)
            let rAngle = self.rotationAngle * rStrength
            let scale = min(1 - fabs(rStrength) / self.scaleStrength, self.scaleMax)
            self.center = CGPoint(x: self.originalPoint.x + xFromCenter, y: self.originalPoint.y + yFromCenter)
            let transform = CGAffineTransform(rotationAngle: rAngle)
            let scaleTransform = transform.scaledBy(x: scale, y: scale)
            self.transform = scaleTransform
            self.updateOverlay(xFromCenter)
            break
        case .ended:
            self.afterSwipeAction()
            break
        default:
            break
        }
    }
    
    @objc private func tapEvent(gesture: UITapGestureRecognizer) {
        self.delegate?.tapped(self)
    }
    
    private func afterSwipeAction() {
        if xFromCenter > actionMargin {
            completeAction(.right)
        } else if xFromCenter < -actionMargin {
            completeAction(.left)
        } else if yFromCenter > actionMargin {
            completeAction(.bottom)
        } else if yFromCenter < -actionMargin {
            completeAction(.top)
        } else {
            UIView.animate(withDuration: 0.3) {
                self.center = self.originalPoint
                self.transform = CGAffineTransform.identity
                self.leftOverlay?.alpha = 0.0
                self.rightOverlay?.alpha = 0.0
            }
        }
    }
    
    private func updateOverlay(_ distance: CGFloat) {
        var activeOverlay: UIView?
        if (distance > 0) {
            self.leftOverlay?.alpha = 0.0
            activeOverlay = self.rightOverlay
        } else {
            self.rightOverlay?.alpha = 0.0
            activeOverlay = self.leftOverlay
        }
        
        activeOverlay?.alpha = min(fabs(distance)/100, 1.0)
    }
    
    private func completeAction(_ direction: SwipeDirection) {
        let finishPoint = self.finishPoint(for: direction)
        UIView.animate(withDuration: 0.3, animations: {
            self.center = finishPoint
        }) { _ in
            self.removeFromSuperview()
        }
        self.delegate?.swiped(self, to: direction)
    }
    
    private func finishPoint(for direction: SwipeDirection) -> CGPoint {
        switch direction {
        case .left:
            return CGPoint(x: -500, y: 2 * yFromCenter + self.originalPoint.y)
        case .right:
            return CGPoint(x: 500, y: 2 * yFromCenter + self.originalPoint.y)
        case .top:
            return CGPoint(x: 2 * xFromCenter + self.originalPoint.x, y: -1000)
        case .bottom:
            return CGPoint(x: 2 * xFromCenter + self.originalPoint.x, y: 1000)
        }
    }
}

extension SwipableCardCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

