//
//  ApiService.swift
//  Loadify
//
//  Created by Vishweshwaran on 5/8/22.
//

import Foundation

protocol DataService {
    func getVideoDetails(url: URL, completion: @escaping (VideoDetails) -> Void)
}

class ApiService: DataService {
    
    func getVideoDetails(url: URL, completion: @escaping (VideoDetails) -> Void)  {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error Fetching data", error)
            }
            do {
                if let data = data {
                    let jsonResponse = try JSONDecoder().decode(VideoDetails.self, from: data)
                    completion(jsonResponse)
                }
            } catch {
                print("Error Decoding data", error)
            }
        }.resume()
    }
}

