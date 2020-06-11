//
//  ScrapeResults.swift
//  WebscraperUI
//
//  Created by Derrick Alford on 5/16/20.
//  Copyright © 2020 thediversecandidate. All rights reserved.
//

import Foundation

// SCRAPE RESULTS FEATURE.
// we needed a way to observe the scraped results.
// An OO object oriented approach to create this was used by creating a class that could be reused as an object.

class ScrapeResults: ObservableObject {
    let semaphore = DispatchSemaphore(value: 1)
    var results: [URL] = []
    @Published var isComplete = false
    @Published var keywordHitCount = 0
    var progress: Double {
        Double(self.results.count) / Double(maximumPagesToVisit)
    }
    var quality: Double {
        Double(self.keywordHitCount) / Double(maximumPagesToVisit)
    }
    func reset() {
        self.results = []
        self.isComplete = false
        self.keywordHitCount = 0
    }
    func add(url: URL) {
        //semaphore.wait()
        results.append(url)
        //semaphore.signal()
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
