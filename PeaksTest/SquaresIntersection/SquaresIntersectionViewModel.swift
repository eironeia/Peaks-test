//  Created by Alex Cuello on 12/07/2019.
//  Copyright © 2019 eironeia. All rights reserved.

import Foundation
import RxSwift

struct RectangleNewPoisitionDescriptor {
    let x: Float
    let y: Float
    let type: RectangleType
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
        let newPoisition: Observable<RectangleNewPoisitionDescriptor>
    }

    struct Output {
        let dataSource: Observable<[RectangleDataSource]>
        let actions: Observable<Void>
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

        let saveNewPosition = input
            .newPoisition
            .do(onNext: { descriptor in
                self.respository
                    .savePosition(descriptor: descriptor)
            })
            .mapToVoid()

        return Output(dataSource: rectangleDataSource,
                      actions: saveNewPosition)
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
