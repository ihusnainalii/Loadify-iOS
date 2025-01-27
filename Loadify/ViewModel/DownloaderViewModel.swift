//
//  ViewDetailsViewModel.swift
//  Loadify
//
//  Created by Vishweshwaran on 5/7/22.
//

import SwiftUI
import Combine
import LoggerKit
import Haptific

protocol Downloadable: Loadable, DownloadableError {
    var isDownloaded: Bool { get set }
    var downloadStatus: DownloadStatus { get set }
    
    func downloadVideo(url: String, with quality: VideoQuality) async
}

final class DownloaderViewModel: Downloadable {
    
    @Published var details: VideoDetails? = nil
    @Published var showLoader: Bool = false
    @Published var detailsError: Error? = nil
    @Published var downloadError: Error? = nil
    @Published var showSettingsAlert: Bool = false
    @Published var shouldNavigateToDownload: Bool = false
    @Published var isDownloaded: Bool = false
    @Published var downloadStatus: DownloadStatus = .none
    
    private lazy var photoService: PhotosServiceProtocol = PhotosService()
    private lazy var fileService: FileServiceProtocol = FileService()
    
    var downloader = Downloader()
    
    init() {
        Logger.initLifeCycle("DownloaderViewModel init", for: self)
    }
    
    func downloadVideo(url: String, with quality: VideoQuality) async {
        do {
            DispatchQueue.main.async {
                self.showLoader = true
            }
            try await photoService.checkForPhotosPermission()
            let filePath = fileService.getTemporaryFilePath()
            let tempURL = try await downloader.download(youtubeURL: url, quality: quality)
            try fileService.moveFile(from: tempURL, to: filePath)
            try checkVideoIsCompatible(at: filePath.path)
            UISaveVideoAtPathToSavedPhotosAlbum(filePath.path, nil, nil, nil)
            DispatchQueue.main.async {
                self.showLoader = false
                self.isDownloaded = true
                self.downloadStatus = .downloaded
                notifyWithHaptics(for: .success)
                Haptific.simulate(.notification(style: .success))
            }
        } catch PhotosError.permissionDenied {
            DispatchQueue.main.async {
                self.showSettingsAlert = true
                self.showLoader = false
                self.downloadStatus = .none
                notifyWithHaptics(for: .warning)
            }
        } catch {
            DispatchQueue.main.async {
                self.isDownloaded = false
                self.downloadError = error
                self.showLoader = false
                self.downloadStatus = .failed
                notifyWithHaptics(for: .error)
            }
        }
    }
    
    private func checkVideoIsCompatible(at filePath: String) throws {
        if !UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath) {
            throw DownloadError.notCompatible
        }
    }
    
    deinit {
        Logger.deinitLifeCycle("DownloaderViewModel deinit", for: self)
    }
}
