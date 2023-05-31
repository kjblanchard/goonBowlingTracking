//
//  ContentView.swift
//  GoonBowlingTrackerWatch Watch App
//
//  Created by Kevin Blanchard on 5/31/23.
//

import SwiftUI

//class NumbersOnly: ObservableObject {
//
//    @Published var value = "" {
//        didSet {
//            let filtered = value.filter { $0.isNumber && Int(value) != 0 }
//
//            if value != filtered {
//                let valueInt = Int(value) ?? -1
//                if valueInt < 0 {
//                    value = "0"
//                }
//                else if 0...300 ~= valueInt {
//                    value = filtered
//                }
//                else {
//                    value = "300"
//                }
//            }
//        }
//    }
//    func IsValidScore() -> Bool {
//        return 0...300 ~= Int(value) ?? -1
//    }
//
//    func GetBowlingScore() -> Int16 {
//        let score = Int16(value) ?? 0
//        return 0...300 ~= score ? score : 0
//    }
//}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
            
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
