//  Created by Alex Cuello on 12/07/2019.
//  Copyright © 2019 eironeia. All rights reserved.

import Foundation
import RxSwift

enum PanGestureEventType {
    case changed
    case ended
}

struct PanGestureDataSource {
    let startPoint: CGPoint
    let translationPoint: CGPoint
    let type: PanGestureEventType
}

protocol SquaresIntersectionViewModelType {
    func transform(input: SquaresIntersectionViewModel.Input) -> SquaresIntersectionViewModel.Output
}

struct SquaresIntersectionViewModel: SquaresIntersectionViewModelType {
    private let respository: SquaresInteresectionRepositoryType

    init(repository: SquaresInteresectionRepositoryType) {
        self.respository = repository
    }

    struct Input {
        let startTrigger: Observable<Void>
        let panGestureRed: Observable<PanGestureDataSource?>
        let panGestureBlue: Observable<PanGestureDataSource?>
    }

    struct Output {
        let dataSource: Observable<[RectangleDataSource]>
        let destinationPointRed: Observable<CGPoint?>
        let destinationPointBlue: Observable<CGPoint?>

    }

    func transform(input: SquaresIntersectionViewModel.Input) -> SquaresIntersectionViewModel.Output {
        let rectangleDataSource = input
            .startTrigger
            .flatMapLatest { _ in
                self.respository
                    .getSquares()
                    .asObservable()
            }
            .map(mapToRectanglesDataSource)

        let destinationPointRed = input
            .panGestureRed
            .flatMapLatest { dataSource -> Observable<CGPoint?> in
                guard let dataSource = dataSource else { return .just(nil) }
                let destinationPoint = self.getDestinationPoint(startPoint: dataSource.startPoint,
                                                                translationPoint: dataSource.translationPoint)

                if case dataSource.type = PanGestureEventType.ended {
                    self.respository.savePosition(position: destinationPoint, type: .red)
                }

                return .just(destinationPoint)
        }

        let destinationPointBlue = input
            .panGestureBlue
            .flatMapLatest { dataSource -> Observable<CGPoint?> in
                guard let dataSource = dataSource else { return .just(nil) }
                let destinationPoint = self.getDestinationPoint(startPoint: dataSource.startPoint,
                                                                translationPoint: dataSource.translationPoint)

                if case dataSource.type = PanGestureEventType.ended {
                    self.respository.savePosition(position: destinationPoint, type: .blue)
                }

                return .just(destinationPoint)
        }

        return Output(dataSource: rectangleDataSource,
                      destinationPointRed: destinationPointRed,
                      destinationPointBlue: destinationPointBlue)
    }

    func getDestinationPoint(startPoint: CGPoint, translationPoint: CGPoint) -> CGPoint {
        return CGPoint(x: startPoint.x + translationPoint.x,
                       y: startPoint.y + translationPoint.y)
    }

    func mapToRectanglesDataSource(rectangles: [Rectangle]) -> [RectangleDataSource] {
        let rectangleRed = rectangles[0]
        let rectangleBlue = rectangles[1]
        return [mapToRectangleDataSource(rectangle: rectangleRed, type: .red),
                mapToRectangleDataSource(rectangle: rectangleBlue, type: .blue)]
    }

    func mapToRectangleDataSource(rectangle: Rectangle, type: RectangleType) -> RectangleDataSource {
        return RectangleDataSource(x: rectangle.x, y: rectangle.y, size: rectangle.size, type: type)
    }
}

struct RectangleDataSource {
    let x, y, size: Float
    let type: RectangleType
}
