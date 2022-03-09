//
//  Errors.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/09.
//

import Foundation

enum ErrorType: String, Error {
    
    case invalidSearch = "No poems or authors under this search. Please try again"
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the serve. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
    case unableToFavorite = "There was an error favoriting this poem. Please try again."
    case alreadyInFavorites = "You've already favorited this poem."
}
