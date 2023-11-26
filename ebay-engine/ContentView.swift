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
                            print("Performing Search")
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
                    NavigationLink(destination: ItemDetailView(itemId: result.itemId)) {
                        
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
                                HStack{
                                    Image(systemName: "heart")
                                        .foregroundColor(.red)
                                    Image(systemName: "chevron.right")
                                }
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
    
    struct ItemSpecific: Codable {
        let Name: String
        let Value: [String]
    }

    struct ReturnPolicy: Codable {
        let ReturnsAccepted: String?
        let ReturnsWithin: String?
    }
}



// Detailed view that fetches and shows the product details
struct ItemDetailView: View {
    let itemId: String
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
                        Text("Loading...")
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
                        Text("$\(details.Price, specifier: "%.2f")")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                            Text("Description")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .padding(.horizontal)
                        .padding(.vertical)
                        
                        
                        // Item specifics table
                        ForEach(details.ItemSpecifics, id: \.Name) { item in
                            HStack {
                                Text(item.Name + ":")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(item.Value.joined(separator: ", "))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Divider() // Horizontal divider after each item
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
            Text("Shipping Info Placeholder")
                .tabItem {
                    Label("Shipping", systemImage: "shippingbox")
                }

            // Photos Tab
            Text("Photos Placeholder")
                .tabItem {
                    Label("Photos", systemImage: "photo")
                }

            // Similar Tab
            Text("Similar Items Placeholder")
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

#Preview {
    ContentView()
}
