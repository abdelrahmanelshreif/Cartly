//
//  EgyptLocationValidator.swift
//  Cartly
//
//  Created by Khalid Amr on 12/06/2025.
//

import Foundation
import CoreLocation

struct EgyptLocationValidator {
    static func isInsideEgypt(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let bounds = (minLat: 22.0, maxLat: 31.6, minLon: 25.0, maxLon: 35.0)
        return coordinate.latitude >= bounds.minLat &&
               coordinate.latitude <= bounds.maxLat &&
               coordinate.longitude >= bounds.minLon &&
               coordinate.longitude <= bounds.maxLon
    }
}
