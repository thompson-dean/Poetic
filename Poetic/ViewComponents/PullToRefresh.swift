//
//  PullToRefresh.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/09/11.
//

import SwiftUI

struct PullToRefresh: View {
    
    @ObservedObject var viewModel: PoemViewModel
    
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 70) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            viewModel.simpleHapticSuccess()
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.down")
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}
