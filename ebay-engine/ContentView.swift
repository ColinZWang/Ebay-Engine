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
    @State private var distance: String = "10"
    @State private var customLocation: Bool = false

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
                            Text("All").tag("All")
                            // Add more categories here
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
                            CheckboxField(checked: $conditionUsed, title: "Used")
                            CheckboxField(checked: $conditionNew, title: "New")
                            CheckboxField(checked: $conditionUnspecified, title: "Unspecified")
                            }
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        Text("Shipping")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        HStack {
                            CheckboxField(checked: $pickup, title: "Pickup")
                            CheckboxField(checked: $freeShipping, title: "Free Shipping")
                            }
                        Spacer()
                    }
                    HStack {
                        Text("Distance:")
                        Spacer()
                        TextField("10", text: $distance)
                            .keyboardType(.numberPad)
                    }
                    
                    Toggle("Custom Location", isOn: $customLocation)
                    
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
                            // Clear action
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

struct CheckboxField: View {
    @Binding var checked: Bool
    var title: String

    var body: some View {
        Button(action: {
            self.checked.toggle()
        }) {
            HStack {
                Image(systemName: checked ? "checkmark.square.fill" : "square")
                    .foregroundColor(.gray)
                Text(title)
                    .foregroundColor(.black)
            }
        }
    }
}


#Preview {
    ContentView()
}
