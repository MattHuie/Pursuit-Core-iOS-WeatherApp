//
//  PixabayAPIClient.swift
//  WeatherApp
//
//  Created by Matthew Huie on 1/22/19.
//  Copyright © 2019 Pursuit. All rights reserved.
//

import Foundation

final class PixabayAPIClient {
    private init() {}
    static func searchWeather(keyword: String, completionHandler: @escaping (AppError?, [LargeImage]?) -> Void) {
        let endpointURLString = "https://pixabay.com/api/?key=\(SecretKeys.imageAPIKey)&q=\(keyword)"
        
        guard let url = URL(string: endpointURLString) else {
            completionHandler(AppError.badURL(endpointURLString), nil)
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(AppError.networkError(error), nil)
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -999
                    completionHandler(AppError.badStatusCode("\(statusCode)"), nil)
                    return
            }
            if let data = data {
                do {
                    let pixaImage = try JSONDecoder().decode(Pixabay.self, from: data)
                    completionHandler(nil, pixaImage.hits )
                } catch {
                    completionHandler(AppError.decodingError(error), nil)
                }
            }
        } .resume()
    }
}

