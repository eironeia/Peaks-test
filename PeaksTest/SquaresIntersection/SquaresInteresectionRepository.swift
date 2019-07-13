//  Created by Alex Cuello on 13/07/2019.
//  Copyright © 2019 eironeia. All rights reserved.

import Foundation
import RxSwift

// I feel like the JSON should provide identifiers for the rectangles
// and not having to handle this logic on the frontend.
enum RectangleType {
    case red
    case blue
}

protocol SquaresInteresectionRepositoryType {
    func getSquares() -> Single<[Rectangle]>
    func savePosition()
}

struct SquaresInteresectionRepository: SquaresInteresectionRepositoryType {
    func getSquares() -> Single<[Rectangle]> {
        guard let rectangles = loadJSONFrom(fileName: "RectanglesJSON") else {
            return .error(NSError()) //This is for demo purposes
        }
        return .just(rectangles)
    }

    func savePosition() {

    }

    func loadJSONFrom(fileName: String) -> [Rectangle]? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json"),
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let result = try? JSONDecoder().decode(Rectangles.self, from: jsonData) else {
                assertionFailure("Can not find JSON file")
                return nil
        }
        return result.rectangles
    }

    func hasStoredValues() -> Bool {
        return false

    }
}

// MARK: - Rectangles
struct Rectangles: Codable {
    let rectangles: [Rectangle]

    enum CodingKeys: String, CodingKey {
        case rectangles
    }
}

// MARK: - Rectangle
struct Rectangle: Codable {
    let x: Double
    let y: Double
    let size: Double
}
