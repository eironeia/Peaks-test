//  Created by Alex Cuello on 12/07/2019.
//  Copyright © 2019 eironeia. All rights reserved.

import Foundation
import RxSwift

protocol SquaresIntersectionViewModelType {
    func transform(input: SquaresIntersectionViewModel.Input) -> SquaresIntersectionViewModel.Output
}

struct SquaresIntersectionViewModel: SquaresIntersectionViewModelType {
    struct Input {
        let startTrigger: Observable<Void>
    }

    struct Output {

    }

    func transform(input: SquaresIntersectionViewModel.Input) -> SquaresIntersectionViewModel.Output {
        
        return Output()
    }
}
