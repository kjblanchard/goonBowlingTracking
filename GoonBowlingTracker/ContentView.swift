//
//  ContentView.swift
//  GoonBowlingTracker
//
//  Created by Kevin Blanchard on 5/28/23.
//

import SwiftUI
import CoreData

public class NumbersOnly: ObservableObject {
    
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber && Int(value) != 0 }
            
            if value != filtered {
                let valueInt = Int(value) ?? -1
                if valueInt < 0 {
                    value = "0"
                }
               else if 0...300 ~= valueInt {
                    value = filtered
                }
                else {
                   value = "300"
                }
            }
        }
    }
    func IsValidScore() -> Bool {
        return 0...300 ~= Int(value) ?? -1
    }
        
    func GetBowlingScore() -> Int16 {
        let score = Int16(value) ?? 0
        return 0...300 ~= score ? score : 0
    }
    
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var Score: NumbersOnly = NumbersOnly()
    @State var Average: Int = 0
    @FocusState private var scoreIsFocused: Bool


    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BowlingScore.time, ascending: true)],
        animation: .default)
    private var scores: FetchedResults<BowlingScore>

    var body: some View {
        
            NavigationView {
                List {
                    HStack {
                        Text("Total Average: ")
                        Text(String(Average))
                    }

                    HStack {
                        Text("Add Score")
                        TextField("Score", text: $Score.value)
                            .keyboardType(.decimalPad)
                            .focused($scoreIsFocused)
                    }
                    Section {
                        ForEach(LastFiveRange(), id:\.self) { index in
                            let item = scores[index]
                            NavigationLink {
                                Text("Score: \(item.score) on \n \(item.time!, formatter: itemFormatter)")
                                .navigationTitle("Score Details")
                            } label: {
                                Text(String(item.score))
                            }
                        }
                        .onDelete(perform: deleteItems)
                            
                    } header: {
                       Text("Recent Games")
                    }
                    Section {
                        ForEach(scores) { item in
                            
                            NavigationLink {
                                Text("Score: \(item.score) on \n \(item.time!, formatter: itemFormatter)")
                                .navigationTitle("Score Details")
                            } label: {
                                Text(String(item.score))
                            }
                        }
                        .onDelete(perform: deleteItems)
                        
                    } header: {
                        Text("History")
                    }
                }
                .toolbar {
    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
    #endif
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Score", systemImage: "plus")
                        }
                    }
                    ToolbarItem {
                        Button(action: refresh) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    }
                }
                .navigationTitle("Home")
                Text("Select an item")
            }.onAppear(perform: calculateAverage)
            
    }
    
    private func calculateAverage() {
        var total = 0
        var count = 0
        for score in scores {
            total += Int(score.score)
            count += 1
        }
//        Average =
        Average = count <= 0 ? 0 : total / count
        
    }
    
    private func LastFiveRange() -> Range<Int> {
        let count = scores.count
        return (0..<5 ~= count) ? 0..<count : 0..<5
      
    }
    
    private func refresh() {
        calculateAverage()
        scoreIsFocused = false
        
    }

    private func addItem() {
        scoreIsFocused = false
        guard Score.IsValidScore() else {
            return
        }
        withAnimation {
            let newScore = BowlingScore(context: viewContext)
            newScore.score = Score.GetBowlingScore()
            newScore.time = Date()

            do {
                try viewContext.save()
                calculateAverage()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { scores[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                calculateAverage()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
