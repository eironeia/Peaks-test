//  Created by Alex Cuello on 11/07/2019.
//  Copyright © 2019 eironeia. All rights reserved.

import UIKit
import RxSwift
import RxCocoa

class SquaresIntersectionViewController: UIViewController {

    private let intersectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.layer.zPosition = 1
        return label
    }()
    private var redView = UIView()
    private var blueView = UIView()
    private let viewModel: SquaresIntersectionViewModelType
    private let newPositionSubject = PublishSubject<RectangleNewPoisitionDescriptor>()
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.roundingMode = .down
        return numberFormatter
    }()
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
        setupLayout()
    }
    
    func setupLayout() {
        view.addSubview(redView)
        view.addSubview(blueView)
        intersectionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(intersectionLabel)
        NSLayoutConstraint.activate([intersectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     intersectionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
    
    func bindViewModel() {
        let startTrigger = rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()

        let input = SquaresIntersectionViewModel.Input(startTrigger: startTrigger,
                                                       newPoisition: newPositionSubject)
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
            .actions
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: disposeBag)

        let panGestureRedObservable = getPanGestureObservableFrom(superview: view, view: redView, type: .red)
            .do(onNext: { [weak self] _ in
                guard let self = self else {
                    assertionFailure("Self is nil")
                    return
                }
                self.setIntersection(mainFrame: self.redView.frame, secondaryFrame: self.blueView.frame)
        })

        let panGestureBlueObservable = getPanGestureObservableFrom(superview: view, view: blueView, type: .blue)
            .do(onNext: { [weak self] _ in
                guard let self = self else {
                    assertionFailure("Self is nil")
                    return
                }
                self.setIntersection(mainFrame: self.blueView.frame, secondaryFrame: self.redView.frame)
            })

        let panGestureObservable = Observable.merge(panGestureRedObservable,
                                                    panGestureBlueObservable)

        panGestureObservable
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: disposeBag)
    }
    
    func getPanGestureObservableFrom(superview: UIView, view: UIView, type: RectangleType) -> Observable<Void> {
        let panGesture = UIPanGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(panGesture)
        return panGesture
            .rx
            .event
            .do(onNext: { [weak newPositionSubject] panGesture in
                superview.bringSubviewToFront(view)
                let translation = panGesture.translation(in: superview)
                let startPoint = view.center
                let destinationPoint = CGPoint(x: startPoint.x + translation.x,
                                               y: startPoint.y + translation.y)
                switch panGesture.state {
                case .changed:
                    view.center = destinationPoint
                    panGesture.setTranslation(CGPoint.zero, in: view)
                case .ended:
                    let xPosition = Float(destinationPoint.x / superview.frame.width)
                    let yPosition = Float(destinationPoint.y / superview.frame.height)
                    let descriptor = RectangleNewPoisitionDescriptor(x: xPosition, y: yPosition, type: type)
                    newPositionSubject?.onNext(descriptor)

                default: return
                }
            })
            .mapToVoid()
    }
    
    func drawRectangle(rectangleDataSource: RectangleDataSource) {
        let viewFrame = getViewFrame(x: CGFloat(rectangleDataSource.x),
                                     y: CGFloat(rectangleDataSource.y),
                                     size: CGFloat(rectangleDataSource.size))
        switch rectangleDataSource.type {
        case .red:
            redView.frame.size = viewFrame.size
            redView.center = viewFrame.origin
            redView.backgroundColor = .red
        case .blue:
            blueView.frame.size = viewFrame.size
            blueView.center = viewFrame.origin
            blueView.backgroundColor = .blue
        }
    }
    
    func getViewFrame(x: CGFloat, y: CGFloat, size: CGFloat) -> CGRect {
        let viewFrame = view.frame
        let origin = CGPoint(x: viewFrame.width * x,
                             y: viewFrame.height * y)
        let size = CGSize(width: viewFrame.width * size,
                          height: viewFrame.height * size)
        return CGRect(origin: origin, size: size)
    }

    func setIntersection(mainFrame: CGRect, secondaryFrame: CGRect) {
        let intersection = mainFrame.intersection(secondaryFrame)
        let width = numberFormatter.string(from: NSNumber(value: Float(intersection.size.width))) ?? "-"
        let height = numberFormatter.string(from: NSNumber(value: Float(intersection.size.height))) ?? "-"
        intersectionLabel.text = "(\(width), \(height))"
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
