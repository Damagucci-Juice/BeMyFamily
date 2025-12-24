//
//  SearchFlow.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//
import Foundation

enum SearchFlow: Hashable {
    case filter
    case searchResult([AnimalSearchFilter])
}
