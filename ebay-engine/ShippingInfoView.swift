//
//  ShippingInfoView.swift
//  ebay-engine
//
//  Created by Colin Wang on 12/7/23.
//

import SwiftUI

// Section for Shipping Info
struct ShippingInfoView: View {
    var productDetails: ProductDetails
    var shippingCost: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            Divider()
            
            SectionHeaderView(title: "Seller", systemImage: "storefront")
            
            Divider()
            
            InfoRow(label: "Store Name", value: productDetails.StoreName, link: productDetails.StoreURL)
            InfoRow(label: "Feedback Score", value: String(productDetails.FeedbackScore))
            InfoRow(label: "Popularity", value: String(productDetails.PositiveFeedbackPercent))
            
            Divider()
            
            SectionHeaderView(title: "Shipping Info", systemImage: "sailboat")
            
            Divider()

            InfoRow(label: "Shipping Cost", value: shippingCost)
            InfoRow(label: "Global Shipping", value: productDetails.GlobalShipping ? "Yes" : "No")
            InfoRow(label: "Handling Time", value: productDetails.handlingTime == 1 ? "\(productDetails.handlingTime) day" : "\(productDetails.handlingTime) days")
            
            Divider()
            
            SectionHeaderView(title: "Return Policy", systemImage: "return")
            
            Divider()

            InfoRow(label: "Policy", value: productDetails.ReturnPolicy.ReturnsAccepted)
            InfoRow(label: "Refund Mode", value: productDetails.ReturnPolicy.Refund)
            InfoRow(label: "Return Within", value: productDetails.ReturnPolicy.ReturnsWithin)
            InfoRow(label: "Shipping Cost Paid By", value: productDetails.ReturnPolicy.ShippingCostPaidBy)
        }
        .padding(.top,0)
    }
}
