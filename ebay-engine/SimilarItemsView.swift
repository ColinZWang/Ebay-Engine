//
//  SimilarItemsView.swift
//  ebay-engine
//
//  Created by Colin Wang on 12/7/23.
//

import SwiftUI

// Define your SimilarItem model conforming to Identifiable and Decodable
struct SimilarItem: Identifiable, Decodable {
    let id: String
    let title: String
    let viewItemURL: String
    let imageURL: String
    let timeLeft: String
    let buyItNowPrice: PriceDetail
    let shippingCost: PriceDetail

    enum CodingKeys: String, CodingKey {
        case id = "itemId"
        case title
        case viewItemURL
        case imageURL
        case timeLeft
        case buyItNowPrice
        case shippingCost
    }
    
    struct PriceDetail: Codable {
        let currencyId: String
        let value: String

        enum CodingKeys: String, CodingKey {
            case currencyId = "@currencyId"
            case value = "__value__"
        }

        // Helper property to get the price as a double
        var doubleValue: Double? {
            return Double(value)
        }
    }
}



struct SimilarItemsView: View {
    let itemId: String
    @State private var similarItems: [SimilarItem] = []
    @State private var originalSimilarItems: [SimilarItem] = [] // Holds the original data
    @State private var isLoading = false
    @State private var selectedSortCriteria = "Default"
    @State private var sortOrder = "Ascending"

    private let sortCriteria = ["Default", "Name", "Price", "Days Left", "Shipping"]
    private let sortOrders = ["Ascending", "Descending"]
    
    var body: some View {
        VStack {
            // Sort Criteria Picker
            VStack {
                Text("Sort By")
                    .font(.headline)
                    .frame(maxWidth:.infinity, alignment:.leading)
                Picker("Sort By", selection: $selectedSortCriteria) {
                    ForEach(sortCriteria, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()

            // Order Picker
            if selectedSortCriteria != "Default"{
                VStack {
                    Text("Order")
                        .font(.headline)
                        .frame(maxWidth:.infinity, alignment:.leading)
                    Picker("Order", selection: $sortOrder) {
                        ForEach(sortOrders, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
            }

            // Displaying the items
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 10) {
                    ForEach(similarItems, id: \.id) { item in
                        VStack {
                            AsyncImage(url: URL(string: item.imageURL)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                            
                            Text(item.title)
                                .font(.subheadline)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Text("$\(String(format: "%.2f", item.shippingCost.doubleValue ?? 0.0))")
                                Spacer()
                                Text(formattedTimeLeft(item.timeLeft))
                            }
                            .font(.caption)
                            .padding(.horizontal)
                            .foregroundColor(.gray)
                            
                            Text("$\(item.buyItNowPrice.doubleValue ?? 0.0, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .frame(width: 160)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }
                .onAppear(perform: loadSimilarItems)
                .navigationTitle("Similar Items")
            }
        }
        .onChange(of: selectedSortCriteria) {
            sortItems()
        }
        .onChange(of: sortOrder) {
            sortItems()
        }
    }
    private func formattedTimeLeft(_ timeLeft: String) -> String {
        if let dayString = timeLeft.split(separator: "D").first?.split(separator: "P").last,
           let days = Int(dayString) {
            return "\(days) \(days == 1 ? "day left" : "days left")"
        }
        return "N/A"
    }
    
    func loadSimilarItems() {
        isLoading = true
        guard let url = URL(string: "http://localhost:8080/similarItems/\(itemId)") else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode([SimilarItem].self, from: data)
                    DispatchQueue.main.async {
                        self.similarItems = decodedResponse
                        self.originalSimilarItems = decodedResponse
                        print("First Similar Item: \(decodedResponse[0]) \n")
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            } else if let error = error {
                print("Error fetching similar items: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.sortItems()
                self.isLoading = false
            }
        }.resume()
    }
    func sortItems() {
        let isAscending = sortOrder == "Ascending"
        switch selectedSortCriteria {
        case "Default":
                similarItems = originalSimilarItems
        case "Name":
            similarItems.sort { isAscending ? $0.title < $1.title : $0.title > $1.title }
        case "Price":
            similarItems.sort { isAscending ?
                ($0.buyItNowPrice.doubleValue ?? 0) < ($1.buyItNowPrice.doubleValue ?? 0) :
                ($0.buyItNowPrice.doubleValue ?? 0) > ($1.buyItNowPrice.doubleValue ?? 0) }
        case "Days Left":
            similarItems.sort { isAscending ?
                extractDays(from: $0.timeLeft) < extractDays(from: $1.timeLeft) :
                extractDays(from: $0.timeLeft) > extractDays(from: $1.timeLeft) }
        case "Shipping":
            similarItems.sort { isAscending ?
                ($0.shippingCost.doubleValue ?? 0) < ($1.shippingCost.doubleValue ?? 0) :
                ($0.shippingCost.doubleValue ?? 0) > ($1.shippingCost.doubleValue ?? 0) }
        default:
            break // Default criteria, perhaps reset to original order or do nothing
        }
    }

    // Helper function to extract days from the timeLeft string
    private func extractDays(from timeLeft: String) -> Int {
        // Extracting the numeric value between 'P' and 'D'
        let daysString = timeLeft.split(separator: "D").first?.split(separator: "P").last ?? "0"
        return Int(daysString) ?? 0
    }

}
