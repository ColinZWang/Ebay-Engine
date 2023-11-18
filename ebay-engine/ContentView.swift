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
    

    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section() {
                        HStack {
                            Text("Keyword:")
                            TextField("Required", text: $keyword)
                        }
                        VStack{
                            Spacer()
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            Spacer()
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        VStack {
                            Spacer()
                            Text("Condition")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            HStack {
                                Toggle("Used", isOn: $conditionUsed)
                                Toggle("New", isOn: $conditionNew)
                                Toggle("Unspecified", isOn: $conditionUnspecified)
                            }
                            .toggleStyle(ChecklistToggleStyle())
                            Spacer()
                        }

                        VStack {
                            Spacer()
                            Text("Shipping")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            HStack {
                                Toggle("Pickup", isOn: $pickup)
                                Toggle("Free Shipping", isOn: $freeShipping)
                            }
                            .toggleStyle(ChecklistToggleStyle())
                            Spacer()
                        }

                        HStack {
                            Text("Distance:")
                            Spacer()
                            TextField("10", text: $distance)
                                .keyboardType(.numberPad)
                        }

                        Toggle("Custom Location", isOn: $customLocation)
                        
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
                                print("Clicking Submit Button")
                                if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    keywordWarning = true
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
                                print("Clicking Clear Button")
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
                .navigationBarTitle("Product Search")
            }

            if keywordWarning {
                VStack {
                    Spacer() // Pushes the warning view to the bottom
                    WarningView()
                        .padding(.bottom, 30) // Add padding for better positioning
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    
    func performSearch() {
        guard let url = URL(string: "http://localhost:8080/search") else { return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        queryItems.append(URLQueryItem(name: "category", value: selectedCategory))
        // Add other parameters similarly
        
        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else { return }
        
        URLSession.shared.dataTask(with: finalURL) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                return
            }
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
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
        Text("Keyword is mandatory.")
            .foregroundColor(.white)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
    }
}



#Preview {
    ContentView()
}
