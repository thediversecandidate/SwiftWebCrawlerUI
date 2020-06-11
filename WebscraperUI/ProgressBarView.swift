//
//  ProgressBarView.swift
//  WebscraperUI
//
//  Created by Derrick Alford on 5/16/20.
//  Copyright © 2020 thediversecandidate. All rights reserved.
//

import SwiftUI

// A PROGRESS BAR FEATURE
// used to track the overall crawl progress and the QOS(qaulity of service) of the crawl.

struct ProgressBarView: View {
    var value: Double
    var background = Color.black
    var fill = Color.blue
    var lineWidth: CGFloat = 5
    var body: some View {
        GeometryReader() { geometry in
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(self.background)
                Rectangle()
                    .fill(self.fill)
                    .offset(x: self.lineWidth, y: self.lineWidth)
                    .frame(width: (geometry.size.width - self.lineWidth * 2) * CGFloat(min(1, self.value)), height: geometry.size.height - self.lineWidth * 2)
            }
        }
    }
}

// THE VIEW OF THE PROGRESS BAR
struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView(value: 0.13)
            .frame(width: 300, height: 40)
    }
}
