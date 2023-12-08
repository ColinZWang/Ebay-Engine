//
//  ItemDetailView.swift
//  ebay-engine
//
//  Created by Colin Wang on 12/7/23.
//

import SwiftUI

// Detailed view that fetches and shows the product details
struct ItemDetailView: View {
    let itemId: String
    let shippingCost: String
    @State private var productDetails: ProductDetails?
    @State private var isLoading = false
    
    // Grid layout configuration
    private let gridItems = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        
        TabView{
            
            // Info Tab
            ScrollView{
                VStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else if let details = productDetails {
                        TabView {
                            ForEach(details.ProductImages, id: \.self) { imageUrl in
                                if let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image.resizable().aspectRatio(contentMode: .fit)
                                        } else if phase.error != nil {
                                            Text("Error loading image")
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 200)
                        
                        Text(details.Title)
                            .font(.headline)
                            .padding(.vertical)
                        
                        Text("$\(details.Price, specifier: "%.2f")")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                            Text("Description")
                        }
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .padding(.horizontal)
                        .padding(.vertical)
                        
                        
                        // Item specifics table
                        ForEach(details.ItemSpecifics, id: \.Name) { item in
                            VStack(spacing: 2){
                                HStack {
                                    Text(item.Name + ":")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(item.Value.joined(separator: ", "))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider() // Horizontal divider after each item
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Text("No details available")
                    }
                }
            }
            .tabItem{
                Label("Info", systemImage: "info.circle")
            }
            
            // Shipping Tab
            if let details = productDetails {
                ShippingInfoView(productDetails: details, shippingCost: shippingCost)
                    .tabItem {
                        Label("Shipping", systemImage: "shippingbox")
                    }
            } else {
                Text("Loading Shipping Info...")
                    .tabItem {
                        Label("Shipping", systemImage: "shippingbox")
                    }
            }

            // Photos Tab
            PhotosView(productTitle: productDetails?.Title ?? "")
                .tabItem {
                    Label("Photos", systemImage: "photo")
                }

            // Similar Tab
            SimilarItemsView(itemId: itemId)
                .tabItem {
                    Label("Similar", systemImage: "rectangle.on.rectangle")
                }
        }
        .onAppear {
            loadItemDetails()
        }
    }
    
    func loadItemDetails() {
        isLoading = true
        let url = URL(string: "http://localhost:8080/product/\(itemId)")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    isLoading = false
                    print("No data received")
                }
                return
            }

            print("Item Details Data Received \n")
            let decoder = JSONDecoder()

            do {
                let details = try decoder.decode(ProductDetails.self, from: data)
                DispatchQueue.main.async {
                    self.productDetails = details
                    isLoading = false
                    print("Product Details: \(details) \n")
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    print("Decoding error: \(error.localizedDescription)")
                    // Handle decoding error
                }
            }
        }.resume()
    }
}
