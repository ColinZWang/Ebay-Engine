//
//  PhotosView.swift
//  ebay-engine
//
//  Created by Colin Wang on 12/7/23.
//

import SwiftUI

struct PhotosView: View {
    @State private var imageLinks: [String] = []
    @State private var isLoading = false
    let productTitle: String

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                ForEach(imageLinks, id: \.self) { link in
                    if let url = URL(string: link) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                Text("Couldn't load image")
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 300, height: 200) // or use another frame size
                    }
                }
            }
        }
        .onAppear {
            loadImages()
        }
    }

    private func loadImages() {
        guard let encodedTitle = productTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:8080/photos?productTitle=\(encodedTitle)") else {
            print("Invalid URL")
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let imageLinks = try? JSONDecoder().decode([String].self, from: data) {
                DispatchQueue.main.async {
                    self.imageLinks = imageLinks
                    isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    isLoading = false
                    print("Error fetching photos: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }.resume()
    }
}
