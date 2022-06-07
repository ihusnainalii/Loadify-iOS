//
//  ApiService.swift
//  Loadify
//
//  Created by Vishweshwaran on 5/8/22.
//

import Foundation
import Photos
import UIKit

protocol DataService {
    func getVideoDetails(for url: String) async throws -> VideoDetails
    func downloadVideo(url: URL, completion: @escaping (DownloaderStatus) -> Void)
}

enum DownloaderStatus {
    case downloaded, failed
}

enum DetailsError: Error, LocalizedError {
    case invaildDomain
    case invaildApiUrl
    case emptyUrl
    
    var errorDescription: String? {
        switch self {
        case .invaildDomain: return "This is not a valid YouTube URL"
        case .invaildApiUrl: return "This is not a vaild API URL"
        case .emptyUrl: return "URL cannot be empty"
        }
    }
}

class ApiService: DataService {
    
    func getVideoDetails(for url: String) async throws -> VideoDetails {
        if url.isEmpty { throw DetailsError.emptyUrl }
        let apiUrl = "https://api.tikapp.ml/api/yt/details?url=\(url)"
        guard let url = URL(string: apiUrl) else { throw DetailsError.invaildApiUrl }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // TODO: - Handle the data effectively
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedData = try JSONDecoder().decode(VideoDetails.self, from: data)
        return decodedData
    }
}

extension ApiService {
    
    // TODO: - Change this to Async Await later.
    func downloadVideo(url: URL, completion: @escaping (DownloaderStatus) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error Donwloading.. \(error)")
            }
            DispatchQueue.main.async {
                do {
                    // TODO: - Video is not downloaded properly.
                    try data?.write(to: filePath)
                    PHPhotoLibrary.shared().performChanges ({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePath)
                    }) { completed, error in
                        if completed {
                            completion(.downloaded)
                        } else if let error = error {
                            print("Error downloading... \(error.localizedDescription)")
                            completion(.failed)
                        }
                    }
                } catch {
                    print("Error Writing file \(error)")
                    completion(.failed)
                }
            }
        }.resume()
    }
}

