//
//  ContentView.swift
//  GoonBowlingTracker
//
//  Created by Kevin Blanchard on 5/28/23.
//

import SwiftUI
import CoreData

class NumbersOnly: ObservableObject {
    
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber && Int(value) != 0 }
            
            if value != filtered {
                value = filtered
            }
        }
    }
    func GetBowlingScore() -> Int16 {
        let score = Int16(value) ?? 0
        return 0...300 ~= score ? score : 0
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var Score: NumbersOnly = NumbersOnly()


    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BowlingScore.time, ascending: true)],
        animation: .default)
    private var scores: FetchedResults<BowlingScore>

    var body: some View {
        
        VStack {
            HStack {
                Text("Total Average: ")
                Text(String(calculateAverage()))
            }

            HStack {
                Text("Add Score")
                TextField("Score", text: $Score.value)
                    .keyboardType(.decimalPad)
            }
            Divider()

            NavigationView {
                List {
                    ForEach(scores) { item in
                        NavigationLink {
                            Text("Score: \(item.score) on \n \(item.time!, formatter: itemFormatter)")
                        } label: {
//                            Text(item.time!, formatter: itemFormatter)
                            Text(String(item.score))
                        }
                    }
                    .onDelete(perform: deleteItems)
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
                }
                Text("Select an item")
            }
            
        }
    }
    
    private func calculateAverage() -> Int {
        var total = 0
        var count = 0
        for score in scores {
            total += Int(score.score)
            count += 1
        }
        return count <= 0 ? 0 : total / count
        
    }

    private func addItem() {
        withAnimation {
            let newScore = BowlingScore(context: viewContext)
            newScore.score = Score.GetBowlingScore()
            newScore.time = Date()

            do {
                try viewContext.save()
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
