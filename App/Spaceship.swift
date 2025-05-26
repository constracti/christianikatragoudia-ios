//
//  Spaceship.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 06-05-2025.
//

import Foundation

infix operator <=> : ComparisonPrecedence

enum Spaceship {
    case asc
    case desc
}

func <=>(lhs: Int, rhs: Int) -> Spaceship? {
    return switch true {
    case lhs < rhs:
        .asc
    case lhs > rhs:
        .desc
    default:
        nil
    }
}

func <=>(lhs: Double, rhs: Double) -> Spaceship? {
    return switch true {
    case lhs < rhs:
        .asc
    case lhs > rhs:
        .desc
    default:
        nil
    }
}

func <=>(lhs: String, rhs: String) -> Spaceship? {
    return switch lhs.localizedCaseInsensitiveCompare(rhs) {
    case .orderedAscending:
        .asc
    case .orderedDescending:
        .desc
    default:
        nil
    }
}
