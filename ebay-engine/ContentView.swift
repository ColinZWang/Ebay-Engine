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
    let categories = ["All", "Art", "Baby", "Books", "Clothing, Shoes & Accessories", "Computers/Tablets & Networking", "Health & Beauty", "Music", "Video Games & Consoles"]

    var body: some View {
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
                            // Submit action
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        Spacer()
                        Button("Clear") {
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
                        }

                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        Spacer()
                    }
                }
            }
            .navigationBarTitle("Product Search")
        }
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




#Preview {
    ContentView()
}
