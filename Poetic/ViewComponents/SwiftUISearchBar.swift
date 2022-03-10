//
//  SwiftUISearchBar.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/10.
//

import SwiftUI

struct SwiftUISearchBar: View {
    @Binding var searchTerm: String
     var body: some View {
         ZStack {
             Rectangle()
                 .foregroundColor(.gray.opacity(0.18))
             HStack {
                 Image(systemName: "magnifyingglass")
                 TextField("Search ..", text: $searchTerm)
             }
             .foregroundColor(.black)
             .padding(.leading, 10)
         }
             .frame(height: 40)
             .cornerRadius(10)
             .padding()
     }
 }
