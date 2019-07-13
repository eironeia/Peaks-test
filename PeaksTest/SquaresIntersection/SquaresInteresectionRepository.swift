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
    func savePosition(position: CGPoint, type: RectangleType)
}

struct SquaresInteresectionRepository: SquaresInteresectionRepositoryType {
    private let userDefaults = UserDefaults.standard

    private enum UserDefaultsKeys: String {
        case redXPosition
        case redYPosition
        case blueXPosition
        case blueYPosition
    }

    func getSquares() -> Single<[Rectangle]> {
        guard let rectangles = fetchSquares() else {
            return .error(NSError()) //This is for demo purposes
        }
        return .just(rectangles)
    }

    func savePosition(position: CGPoint, type: RectangleType) {
        switch type {
        case .red:
            userDefaults.set(Float(position.x), forKey: UserDefaultsKeys.blueXPosition.rawValue)
            userDefaults.set(Float(position.y), forKey: UserDefaultsKeys.blueYPosition.rawValue)
        case .blue:
            userDefaults.set(position.x, forKey: UserDefaultsKeys.blueXPosition.rawValue)
            userDefaults.set(position.y, forKey: UserDefaultsKeys.blueYPosition.rawValue)
        }
        userDefaults.synchronize()
    }

    func fetchSquares() -> [Rectangle]? {
        guard let path = Bundle.main.path(forResource: "RectanglesJSON", ofType: "json"),
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let result = try? JSONDecoder().decode(Rectangles.self, from: jsonData) else {
                assertionFailure("Can not find JSON file")
                return nil
        }
        var rectangles = result.rectangles

        //Red
        var redRectangle = rectangles[0] //This shouldn't be the approach
        if let xPosition = userDefaults.value(forKey: UserDefaultsKeys.redXPosition.rawValue) as? Float,
            let yPosition = userDefaults.value(forKey: UserDefaultsKeys.redYPosition.rawValue) as? Float {
            redRectangle = Rectangle(x: xPosition, y: yPosition, size: redRectangle.size)
        }

        //Blue
        var blueRectangle = rectangles[1]
        if let xPosition = userDefaults.value(forKey: UserDefaultsKeys.blueXPosition.rawValue) as? Float,
            let yPosition = userDefaults.value(forKey: UserDefaultsKeys.blueYPosition.rawValue) as? Float {
            blueRectangle = Rectangle(x: xPosition, y: yPosition, size: blueRectangle.size)
        }

        return [redRectangle, blueRectangle]
    }

    func clean() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.redXPosition.rawValue)
        userDefaults.removeObject(forKey: UserDefaultsKeys.redYPosition.rawValue)
        userDefaults.removeObject(forKey: UserDefaultsKeys.redXPosition.rawValue)
        userDefaults.removeObject(forKey: UserDefaultsKeys.redXPosition.rawValue)
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
    let x: Float
    let y: Float
    let size: Float
}
