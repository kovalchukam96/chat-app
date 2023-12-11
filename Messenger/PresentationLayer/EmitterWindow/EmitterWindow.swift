import UIKit

final class EmitterWindow: UIWindow {
    
    private var emitterLayer: CAEmitterLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPanGesture()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView === self {
            return nil
        }
        return hitView
    }
    
    private func startGeneratingIcons(at position: CGPoint) {
        if emitterLayer == nil {
            createEmitterLayer(at: position)
        } else {
            emitterLayer?.emitterPosition = position
            emitterLayer?.birthRate = 1
        }
    }
    
    private func stopGeneratingIcons() {
        emitterLayer?.birthRate = 0
    }
    
    private func createEmitterLayer(at position: CGPoint) {
        let emitterLayer = CAEmitterLayer()
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "GestureAnimation")?.cgImage
        emitterCell.birthRate = 5
        emitterCell.lifetime = 1.5
        emitterCell.velocity = 10
        emitterCell.velocityRange = 5
        emitterCell.emissionRange = CGFloat.pi * 2
        emitterCell.scale = 0.025
        emitterCell.scaleRange = 0.05
        emitterCell.alphaSpeed = -1 / emitterCell.lifetime
        
        emitterLayer.emitterCells = [emitterCell]
        
        layer.addSublayer(emitterLayer)
        self.emitterLayer = emitterLayer
    }
    
    private func setupPanGesture() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panRecognizer.delegate = self
        panRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(panRecognizer)
    }
    
    private func setupTapGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapRecognizer.delegate = self
        tapRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func handlePan(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            startGeneratingIcons(at: gesture.location(in: self))
        case .changed:
            emitterLayer?.emitterPosition = gesture.location(in: self)
        case .ended, .cancelled, .failed:
            stopGeneratingIcons()
        default:
            break
        }
    }
    
    @objc private func handleTap(_ gesture: UIGestureRecognizer) {
        startGeneratingIcons(at: gesture.location(in: nil))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.stopGeneratingIcons()
        }
    }
}

extension EmitterWindow: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
