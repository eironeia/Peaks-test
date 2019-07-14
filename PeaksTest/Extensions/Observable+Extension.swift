//  Created by Alex Cuello on 14/07/2019.
//  Copyright © 2019 eironeia. All rights reserved.

import Foundation
import RxCocoa
import RxSwift

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
