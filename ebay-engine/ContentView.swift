//
//  ContentView.swift
//  ebay-engine
//
//  Created by Colin Wang on 11/14/23.
//

import SwiftUI

struct ContentView: View {
    @State private var keyword: String = ""
    @State private var selectedCategory: String = "All"
    @State private var conditionNew: Bool = false
    @State private var conditionUsed: Bool = false
    @State private var conditionUnspecified: Bool = false
    @State private var freeShipping: Bool = false
    @State private var pickup: Bool = false
    @State private var distance: String = ""
    @State private var customLocation: Bool = false
    @State private var zipCode: String = ""
    @State private var keywordWarning: Bool = false
    let categories = ["All", "Art", "Baby", "Books", "Clothing, Shoes & Accessories", "Computers/Tablets & Networking", "Health & Beauty", "Music", "Video Games & Consoles"]
    @State private var searchResults: [SearchResult] = []
    @State private var showingResults = false

    

    var body: some View {
        NavigationView {
            Form{
                Section{
                    searchForm
                }
                if showingResults{
                    Section{
                        resultsList
                    }
                }
            }
            .navigationBarTitle("Product Search")
            .navigationBarItems(trailing: NavigationLink(destination: WishlistView(), label: {
                Image(systemName: "heart.circle") // You can use a custom image or system icon
                    .imageScale(.large)
            }))
            .overlay(
                keywordWarning ? WarningView().position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.75) : nil
                    )
        }
    }

    
    
    var searchForm: some View{
         Section(){
             VStack(spacing:18) {
                HStack {
                    Text("Keyword:")
                    TextField("Required", text: $keyword)
                }
                
                Divider()
                
                VStack{
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Divider()

                VStack {
                    Text("Condition")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Toggle("Used", isOn: $conditionUsed)
                        Toggle("New", isOn: $conditionNew)
                        Toggle("Unspecified", isOn: $conditionUnspecified)
                    }
                    .toggleStyle(ChecklistToggleStyle())
                }
                
                Divider()
                
                VStack {
                    Text("Shipping")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Toggle("Pickup", isOn: $pickup)
                        Toggle("Free Shipping", isOn: $freeShipping)
                    }
                    .toggleStyle(ChecklistToggleStyle())
                }
                
                Divider()
                
                HStack {
                    Text("Distance:")
                    Spacer()
                    TextField("10", text: $distance)
                        .keyboardType(.numberPad)
                }
                
                Divider()
                
                Toggle("Custom Location", isOn: $customLocation)
                
                Divider()

                if customLocation {
                    HStack {
                        Text("Zipcode:")
                        TextField("Enter zip code", text: $zipCode)
                            .keyboardType(.numberPad)
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button("Submit") {
                        print("Clicking Submit Button \n")
                        if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            keywordWarning = true
                            showingResults = false
                        } else {
                            keywordWarning = false
                            print("Performing Search for: \(keyword)")
                            performSearch()
                        }
                    }
                    
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .buttonStyle(BorderlessButtonStyle())
                    
                    
                    
                    Spacer()
                    
                    Button("Clear") {
                        print("Clicking Clear Button \n")
                        keyword = ""
                        selectedCategory = "All"
                        conditionNew = false
                        conditionUsed = false
                        conditionUnspecified = false
                        freeShipping = false
                        pickup = false
                        distance = ""
                        customLocation = false
                        zipCode = ""
                        keywordWarning = false
                        showingResults = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .buttonStyle(BorderlessButtonStyle())
                    
                    
                    
                    Spacer()
                }
            }
        }
    }
    
    var resultsList: some View{
        Section(header: Text("Results")
            .font(.system(size:28, weight: .bold))
            .padding(.top, 5)
            .padding(.bottom, 5)){
            if searchResults.isEmpty {
                Text("No results found.")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                List(searchResults, id: \.itemId) { result in
                    HStack{
                        NavigationLink(destination: ItemDetailView(itemId: result.itemId, shippingCost: result.shipping ?? "N/A")) {
                            
                            HStack {
                                // Displaying the image from the URL
                                if let imageUrlString = result.image, let imageUrl = URL(string: imageUrlString) {
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
                                    Text(result.title ?? "Unknown Title")
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    if let price = result.price {
                                        Text("$\(price)")
                                            .foregroundColor(.blue)
                                            .fontWeight(.bold)
                                    } else {
                                        Text("N/A")
                                            .foregroundColor(.blue)
                                    }
                                    Text(result.shipping ?? "N/A")
                                        .foregroundColor(.gray)
                                    Text(result.zip ?? "N/A")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                VStack{
                                    Spacer()
                                    Button(action: {
                                        if let index = searchResults.firstIndex(where: { $0.id == result.id }) {
                                            searchResults[index].isFavorite.toggle() // Toggle the favorite status
                                            if searchResults[index].isFavorite {
                                                addToWishlist(item: result)
                                            } else {
                                                removeFromWishlist(item: result)
                                            }
                                        }
                                    }) {
                                        Image(systemName: result.isFavorite ? "heart.fill" : "heart")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Spacer()
                                    Text(result.condition ?? "N/A")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func performSearch() {
        // Check if custom location is enabled
        if !customLocation {
            fetchUserZipCode { zipCode in
                self.zipCode = zipCode
                print("Fetched Zipcode for User: \(self.zipCode) \n")
                self.executeSearch()
            }
        } else {
            executeSearch()
        }
    }

    func fetchUserZipCode(completion: @escaping (String) -> Void) {
        let locationURL = URL(string: "http://localhost:8080/getUserLocation")!

        URLSession.shared.dataTask(with: locationURL) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching user location: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let zipCode = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(zipCode)
                }
            }
        }.resume()
    }


    
    func executeSearch() {
        guard let url = URL(string: "http://localhost:8080/search") else { return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        queryItems.append(URLQueryItem(name: "category", value: selectedCategory))
        if conditionUsed { queryItems.append(URLQueryItem(name: "usedCondition", value: "true")) }
        if conditionNew { queryItems.append(URLQueryItem(name: "newCondition", value: "true")) }
        if conditionUnspecified { queryItems.append(URLQueryItem(name: "unspecifiedCondition", value: "true")) }

        // Adding shipping filters
        if pickup { queryItems.append(URLQueryItem(name: "localpickup", value: "true")) }
        if freeShipping { queryItems.append(URLQueryItem(name: "freeshipping", value: "true")) }

        // Adding distance
        if !distance.isEmpty { queryItems.append(URLQueryItem(name: "distance", value: distance)) } else {
            queryItems.append(URLQueryItem(name: "distance", value: "10"))
        }

        // Adding location zip code
        queryItems.append(URLQueryItem(name: "zipcode", value: zipCode))
        

        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else { return }
        
        URLSession.shared.dataTask(with: finalURL) { data, response, error in
                if let error = error {
                    print("Error making request: \(error)")
                    return
                }

            if let data = data {
                do {
                    let results = try JSONDecoder().decode([SearchResult].self, from: data)
                    if results.isEmpty{
                        self.searchResults = []
                        self.showingResults = true
                        print("No Results Found for this Search \n")
                    } else {
                        DispatchQueue.main.async {
                            self.searchResults = results
                            self.showingResults = true
                            print("Sample Search Result: \(results[0]) \n")
                        }
                    }
                } catch {
                    print("JSON Decoding Error: \(error)")
                }
            }
        }.resume()
    }
    func addToWishlist(item: SearchResult) {
        guard let url = URL(string: "http://localhost:8080/wishlist") else {
            print("Invalid URL")
            return
        }

        // Convert SearchResult to JSON
        let json: [String: Any] = [
            "itemId": item.itemId,
            "image": item.image ?? "",
            "title": item.title ?? "",
            "price": item.price ?? "",
            "shipping": item.shipping ?? "",
            "zip": item.zip ?? ""
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // Create a POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Item added to wishlist")
            }
        }.resume()
    }
    
    func removeFromWishlist(item: SearchResult) {
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

struct ChecklistToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}

struct WarningView: View {
    var body: some View {
        Text("Keyword is mandatory")
            .foregroundColor(.white)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
    }
}

struct SearchResult: Identifiable, Decodable {
    var id: String { itemId }
    let itemId: String
    let image: String?
    let title: String?
    let price: String?
    let shipping: String?
    let zip: String?
    let condition: String?
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case itemId, image, title, price, shipping, zip, condition
    }
}


struct ProductDetails: Codable {
    let Title: String
    let ProductImages: [String]
    let Price: Double
    let Location: String
    let ItemSpecifics: [ItemSpecific]
    let ReturnPolicy: ReturnPolicy
    let handlingTime: Int
    let shippingServiceCost: Double?
    let shipToLocations: [String]
    let expeditedShipping: Bool?
    let oneDayShippingAvailable: Bool?
    let FeedbackScore: Int
    let PositiveFeedbackPercent: Double
    let FeedbackRatingStar: String
    let TopRatedSeller: Bool?
    let StoreName: String?
    let StoreURL: String?
    let GlobalShipping: Bool
    
    struct ItemSpecific: Codable {
        let Name: String
        let Value: [String]
    }

    struct ReturnPolicy: Codable {
        let ReturnsAccepted: String?
        let ReturnsWithin: String?
        let Refund: String?
        let ShippingCostPaidBy: String?
    }
}

struct WishlistItem: Identifiable, Decodable {
    var id: String { _id }
    let _id: String
    let itemId: String
    let image: String
    let title: String
    let price: String
    let shipping: String
    let zip: String
    let __v: Int
}




// Reusable view for section headers
struct SectionHeaderView: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack{
            Image(systemName: systemImage)
            Text(title)
                .font(.headline)
                .padding(.vertical, 5)
        }
    }
}

// Reusable view for info rows
struct InfoRow: View {
    let label: String
    var value: String?
    var link: String?
    
    var body: some View {
        if value != nil || link != nil {
            HStack {
                Text(label)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer()
                if let link = link, let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                    Link(value ?? "", destination: url)
                        .frame(maxWidth: .infinity, alignment: .center)

                } else {
                    Text(value ?? "N/A")
                        .frame(maxWidth: .infinity, alignment: .center)

                }
            }
        }
    }
}





#Preview {
    ContentView()
}
