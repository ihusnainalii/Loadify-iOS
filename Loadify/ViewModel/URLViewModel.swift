//
//  URLViewModel.swift
//  Loadify
//
//  Created by Vishweshwaran on 18/06/22.
//

import Foundation
import LoggerKit
import Haptific

protocol ViewLifyCycle {
    func onDisappear()
}

protocol Detailable: Navigatable, ViewLifyCycle {
    func getVideoDetails(for url: String) async
}

final class URLViewModel: Detailable {
    
    @Published var shouldNavigateToDownload: Bool = false
    @Published var showLoader: Bool = false
    @Published var error: Error? = nil
    @Published var errorMessage: String? = nil
    
    var details: VideoDetails? = nil
    var fetcher = DetailFetcher()
    
    init() {
        Logger.initLifeCycle("URLViewModel init", for: self)
    }
    
    func getVideoDetails(for url: String) async {
        do {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.showLoader = true
            }
            let response = try await fetcher.loadDetails(for: url)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.details = response
                self.showLoader = false
                notifyWithHaptics(for: .success)
                self.shouldNavigateToDownload = true
            }
        } catch let error as NetworkError {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self else { return }
                self.showLoader = false
                switch error {
                case .invalidResponse(let message):
                    self.errorMessage = message
                case .badRequest(let message):
                    self.errorMessage = message
                case .unauthorized(let message):
                    self.errorMessage = message
                case .forbidden(let message):
                    self.errorMessage = message
                case .notFound(let message):
                    self.errorMessage = message
                case .serverError(let message):
                    self.errorMessage = message
                case .unknownError(let message):
                    self.errorMessage = message
                }
                notifyWithHaptics(for: .error)
            }
        } catch {
            Logger.error("Failed with err: ", error.localizedDescription)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self else { return }
                self.showLoader = false
                self.error = error
                notifyWithHaptics(for: .error)
            }
        }
    }
    
    func onDisappear() {
        details = nil
    }
    
    deinit {
        Logger.deinitLifeCycle("URLViewModel deinit", for: self)
    }
}

