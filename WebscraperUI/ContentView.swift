//
//  ContentView.swift
//  WebscraperUI
//
//  Created by Derrick Alford on 4/20/20.
//  Copyright © 2020 thediversecandidate. All rights reserved.
//
import SafariServices
import SwiftUI
import Foundation


// Were going to need a few variables for our task.

// 1. Input URL to crawl
let startUrl = URL(string: "https://www.datacenterknowledge.com")!

// 2. Input wordToSearch or keyword.
var wordToSearch = "Hyperscale"

// 2a. webscraping etiquette
var maximumPagesToVisit = 100

// 3. Put visited/pagesToVisit in a list.


// VISUALIZING RESULTS.
// A way to observe the ScrapeResults using OOP


// ContentView
struct ContentView: View {
    @State var starterURL = startUrl.absoluteString
    @State var searchTerm =  "hyperscale"
    @State var limitCountText = "10"
    @State var crawler: Crawler?
    @ObservedObject var results: ScrapeResults
    
    
    var body: some View {
    
// UI/UX ELEMENTS
        
        VStack {
            VStack {
                HStack() {
                    Spacer()
                    Text("Search Term")
                    TextField("Hyperscale", text: $searchTerm)
                }
                .padding(.all)
                if results.isComplete { Text("All Done!") }
                HStack() {
                    Text("Enter")
                    TextField("Search:", text: $starterURL)
                    Spacer()
                    Button(action: {
                        self.search()
                    }) {
                        
                        Text(/*@START_MENU_TOKEN@*/"SEARCH"/*@END_MENU_TOKEN@*/)
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundColor(Color.blue)
                            .multilineTextAlignment(.center)
                            .padding(.all)
                        
                    }
                }
                .padding(.all)
                
                HStack() {
                    Text("Result Limit")
                    TextField("", text: $limitCountText)
                }
                .padding(.all)
                .frame(width: 250)
                
                ProgressBarView(value: self.results.progress)
                    .frame(width: 300, height: 30)
                    .padding()
                ProgressBarView(value: self.results.quality, fill: .green)
                    .frame(width: 300, height: 30)
                    .padding()
                ScrollView {
                    ForEach(results.results, id: \.self) { url in
                        Text(url.absoluteString)
                    }
                }
            }
        }
    }
   
    
// SEARCH FUNCTION LOGIC
    func search() {
        self.results.reset()
        self.crawler = Crawler(results: self.results)
        maximumPagesToVisit = Int(self.limitCountText) ?? 100
        wordToSearch = self.searchTerm
        if let url = URL(string: self.starterURL) {
            self.crawler?.crawl(url: url)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(results: ScrapeResults())
            .buttonStyle(/*@START_MENU_TOKEN@*/ /*@PLACEHOLDER=Button Style@*/DefaultButtonStyle()/*@END_MENU_TOKEN@*/)
            .brightness(/*@START_MENU_TOKEN@*/-2.4/*@END_MENU_TOKEN@*/)
    }
}

/*
 // INPUT YOUR PARAMETER'S HERE.
 
 // This is where an input screen should be inserted into the app!. (Derrick Alford)
 */

class Crawler {
    internal init(results: ScrapeResults) {
        self.results = results
    }
    
    var visitedPages: Set<URL> = []
    var pagesToVisit: Set<URL> = []
    var results: ScrapeResults
    
    
// CRAWLER CORE FUNCTION
// the spider that will crawl the page
    func crawl(url: URL) {
        guard visitedPages.count <= maximumPagesToVisit else {
            DispatchQueue.main.async {
                self.results.isComplete = true
            }
            print("🏁 Reached max number of pages to visit")
            return
        }
        //    guard let pageToVisit = pagesToVisit.popFirst() else {
        //        print("🏁 No more pages to visit")
        //         return
        //    }
        if visitedPages.contains(url) {
            if let url = pagesToVisit.popFirst() {
                crawl(url: url)
            } else {
                print("🏁 No more pages to visit")
            }
        } else {
            visit(page: url)
        }
    }

    // VISIT PAGE FUNCTION and working...output screen
    func visit(page url: URL) {
        results.add(url: url)
        visitedPages.insert(url)
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data, let document = String(data: data, encoding: .utf8)  {
                self.parse(document: document, url: url)
            } else if let err = error {
                print("Got an error on \(url): \(err)")
            }
            
            if let url = self.pagesToVisit.popFirst() {
                do { self.crawl(url: url) }
            }
        }
    // POSSIBLE OUTPUT SCREEN SHOWING PROGRESS
        print("🔎 Visiting page: \(url)")
        task.resume()
    }


    // PARSE DOCUMENT & URL FUNCTIONS
    //find the word condition: if the doc contains the word then print check icon and word from URL found.
    func parse(document: String, url: URL) {
        // search for word in document and url and if found print check icon, "Word", the word found and where it was found.
        func find(word: String) {
            if document.contains(word) {
    // POSSIBLE OUTPUT SCREEN SHOWING PROGRESS
                DispatchQueue.main.async {
                    self.results.keywordHitCount += 1
                }
                print("✅ Word '\(word)' found at page \(url)")
            }
        }
    // COLLECTING THE LINKS,
    //get the matches, trim the matches find the word to search and collect the links for each page to visit
        func collectLinks() -> [URL] {
            func getMatches(pattern: String, text: String) -> [String] {
                // used to remove the 'href="' & '"' from the matches
                func trim(url: String) -> String {
                    return String(url.dropLast()).substring(from: url.index(url.startIndex, offsetBy: "href=\"".count))
                }
                
                let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                let matches = regex.matches(in: text, options: [.reportCompletion], range: NSRange(location: 0, length: text.count))
                return matches.map { trim(url: (text as NSString).substring(with: $0.range)) }
            }
            
            let pattern = "href=\"(http://.*?|https://.*?)\""
            let matches = getMatches(pattern: pattern, text: document)
            return matches.compactMap { URL(string: $0) }
        }
        // find the word to search function
        find(word: wordToSearch)
        // collect the links for each page to visit.
        collectLinks().forEach { pagesToVisit.insert($0) }
    }





    // CALLED A FUNCTION CRAWL TO INITIATE THE crawl() this can be a UI action button


}
