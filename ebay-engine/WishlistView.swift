//
//  WishlistView.swift
//  ebay-engine
//
//  Created by Colin Wang on 12/7/23.
//

import SwiftUI

struct WishlistView: View {
    @State private var wishlistItems: [WishlistItem] = []
    @State private var isLoading = false

    var body: some View {
        List {
            ForEach(wishlistItems, id: \.id) { item in
                NavigationLink(destination: ItemDetailView(itemId: item.itemId, shippingCost: item.shipping)) {
                    HStack {
                        // Image loading logic here
                        if let imageUrl = URL(string: item.image) {
                            AsyncImage(url: imageUrl) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fit)
                                } else if phase.error != nil {
                                    Color.red // Error placeholder
                                } else {
                                    Color.blue // Loading placeholder
                                }
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                        } else {
                            Color.gray // Placeholder for missing image
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Text("$\(item.price)")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                            Text(item.shipping)
                                .foregroundColor(.gray)
                            Text(item.zip)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .onDelete(perform: deleteItem) // Swipe to delete
        }
        .onAppear(perform: loadWishlist)
        .navigationTitle("Favorites")
    }

    func loadWishlist() {
        isLoading = true
        print("Loading wishlist...")

        // Replace with your server's actual URL
        guard let url = URL(string: "http://localhost:8080/wishlist") else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode([WishlistItem].self, from: data)
                    DispatchQueue.main.async {
                        self.wishlistItems = decodedResponse
                        print("Decoded Response: \(decodedResponse)")
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            } else if let error = error {
                print("Error fetching wishlist: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()

    }
    
    // Function to delete item from wishlist
    private func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = wishlistItems[index]
            // Implement logic to delete the item from the server
            removeFromWishlist(item: itemToDelete)
        }
        wishlistItems.remove(atOffsets: offsets)
    }

    // Remove item from wishlist on server
    func removeFromWishlist(item: WishlistItem) {
        guard let url = URL(string: "http://localhost:8080/wishlist/\(item.id)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Item removed from wishlist")
            }
        }.resume()
    }
}
