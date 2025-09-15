//
//  Spaceship.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 06-05-2025.
//

infix operator <=> : ComparisonPrecedence

enum Spaceship {
    case asc
    case desc
}

func <=>(lhs: Int, rhs: Int) -> Spaceship? {
    switch true {
    case lhs < rhs:
        .asc
    case lhs > rhs:
        .desc
    default:
        nil
    }
}

func <=>(lhs: Double, rhs: Double) -> Spaceship? {
    switch true {
    case lhs < rhs:
        .asc
    case lhs > rhs:
        .desc
    default:
        nil
    }
}

func <=>(lhs: String, rhs: String) -> Spaceship? {
    switch lhs.localizedCaseInsensitiveCompare(rhs) {
    case .orderedAscending:
        .asc
    case .orderedDescending:
        .desc
    default:
        nil
    }
}
