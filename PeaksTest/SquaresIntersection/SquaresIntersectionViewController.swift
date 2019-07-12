//  Created by Alex Cuello on 11/07/2019.
//  Copyright © 2019 eironeia. All rights reserved.

import UIKit
import RxSwift
import RxCocoa

class SquaresIntersectionViewController: UIViewController {

    private var view1: UIView!
    private var view2: UIView!

    private lazy var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()

        view1 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view1.backgroundColor = .blue
        view.addSubview(view1)

        view2 = UIView(frame: CGRect(x: 25, y: 25, width: 50, height: 50))
        view2.backgroundColor = .red
        view.addSubview(view2)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        view2.addGestureRecognizer(panGesture)
    }

    @objc
    func draggedView(_ sender: UIPanGestureRecognizer) {

        switch sender.state {
        case .changed:
            view.bringSubviewToFront(view2)
            let translation = sender.translation(in: view)
            view2.center = CGPoint(x: view2.center.x + translation.x, y: view2.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: view)
        case .ended:
            print(view1.frame.intersection(view2.frame))
        default:
            //TODO: Handle other states ⚠️
            break
        }
    }
}

private extension SquaresIntersectionViewController {
    func setupUI() {
        view.backgroundColor = .white
    }

    func bindViewModel() {

    }
}

extension ObservableType {
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
}
