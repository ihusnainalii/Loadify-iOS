//
//  LoadifyApp.swift
//  Loadify
//
//  Created by Vishweshwaran on 5/7/22.
//

import SwiftUI

@main
struct LoadifyApp: App {
    
    @StateObject var viewModel = DownloaderViewModel()
    
    var body: some Scene {
        WindowGroup {
            URLView(viewModel: viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
