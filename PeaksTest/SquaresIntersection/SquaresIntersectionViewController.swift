//  Created by Alex Cuello on 11/07/2019.
//  Copyright © 2019 eironeia. All rights reserved.

import UIKit
import RxSwift
import RxCocoa

class SquaresIntersectionViewController: UIViewController {

    private var redView = UIView()
    private var blueView = UIView()
    private let viewModel: SquaresIntersectionViewModelType
    private lazy var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    init(viewModel: SquaresIntersectionViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SquaresIntersectionViewController {
    func setupUI() {
        view.backgroundColor = .white
    }

    func bindViewModel() {
        let startTrigger = rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()

        let panGestureRed = UIPanGestureRecognizer(target: self, action: nil)
        let panGestureRedObservable = getPanGestureObservableFrom(superview: view, view: redView, panGesture: panGestureRed)

        let panGestureBlue = UIPanGestureRecognizer(target: self, action: nil)
        let panGestureBlueObservable = getPanGestureObservableFrom(superview: view, view: blueView, panGesture: panGestureBlue)

        let input = SquaresIntersectionViewModel.Input(startTrigger: startTrigger,
                                                       panGestureRed: panGestureRedObservable,
                                                       panGestureBlue: panGestureBlueObservable)
        let output = viewModel.transform(input: input)

        output
            .dataSource
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] rectanglesDataSource in
                guard let self = self else {
                    assertionFailure("Self is nil")
                    return
                }
                rectanglesDataSource.forEach(self.drawRectangle)
            })
            .disposed(by: disposeBag)

        output
            .destinationPointRed
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak redView] destinationPoint in
                guard let destinationPoint = destinationPoint,
                    let redView = redView else { return }
                redView.center = destinationPoint
                panGestureRed.setTranslation(CGPoint.zero, in: redView)
            })
            .disposed(by: disposeBag)

        output
            .destinationPointBlue
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak blueView] destinationPoint in
                guard let destinationPoint = destinationPoint,
                    let blueView = blueView else { return }
                blueView.center = destinationPoint
                panGestureBlue.setTranslation(CGPoint.zero, in: blueView)
            })
            .disposed(by: disposeBag)
    }

    func getPanGestureObservableFrom(superview: UIView, view: UIView, panGesture: UIPanGestureRecognizer) -> Observable<PanGestureDataSource?> {
        view.addGestureRecognizer(panGesture)
        return panGesture
            .rx
            .event
            .map({ panGesture -> PanGestureDataSource? in
                superview.bringSubviewToFront(view)
                let translation = panGesture.translation(in: superview)

                switch panGesture.state {
                case .began, .changed:
                    return PanGestureDataSource(startPoint: view.center,
                                                translationPoint: translation,
                                                type: .changed)
                case .ended:
                    return PanGestureDataSource(startPoint: view.center,
                                                translationPoint: translation,
                                                type: .ended)
                default: return nil
                }
            })
    }

    func drawRectangle(rectangleDataSource: RectangleDataSource) {
        let viewFrame = getViewFrame(x: CGFloat(rectangleDataSource.x), y: CGFloat(rectangleDataSource.y), size: CGFloat(rectangleDataSource.size))
        switch rectangleDataSource.type {
        case .red:
            redView.frame.size = viewFrame.size
            redView.center = viewFrame.origin
            redView.backgroundColor = .red
            view.addSubview(redView)
        case .blue:
            blueView.frame.size = viewFrame.size
            blueView.center = viewFrame.origin
            blueView.backgroundColor = .blue
            view.addSubview(blueView)
        }
    }

    func getViewFrame(x: CGFloat, y: CGFloat, size: CGFloat) -> CGRect {
        let viewFrame = view.frame
        let origin = CGPoint(x: viewFrame.width * x, y: viewFrame.height * y)
        let size = CGSize(width: viewFrame.width * size, height: viewFrame.height * size)
        return CGRect(origin: origin, size: size)
    }
}

extension ObservableType {
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}
