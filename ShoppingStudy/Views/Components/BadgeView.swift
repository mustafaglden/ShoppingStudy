//
//  BadgeView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct BadgeView: View {
    let count: Int
    let color: Color
    
    init(count: Int, color: Color = .red) {
        self.count = count
        self.color = color
    }
    
    var body: some View {
        if count > 0 {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}
