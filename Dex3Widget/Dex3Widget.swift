

import WidgetKit
import SwiftUI
import CoreData

struct Provider: AppIntentTimelineProvider {
    var randomPokemon: Pokemon {
        let context = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        var pokemonResults: [Pokemon] = []
        
        do {
            pokemonResults = try context.fetch(fetchRequest)
        } catch {
            print("Couldn't fetch: \(error)")
        }
        
        guard let randonPokemon = pokemonResults.randomElement() else {
            return SamplePokemon.samplePokemon
        }
        
        return randonPokemon
    }
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            pokemon: SamplePokemon.samplePokemon
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            pokemon: randomPokemon
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                pokemon: randomPokemon
            )
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let pokemon: Pokemon
}

struct Dex3WidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetSize
    var entry: Provider.Entry

    var body: some View {
        switch widgetSize {
        case .systemSmall:
            WidgetPokemon(widgetSize: .small)
                .environmentObject(entry.pokemon)
            
        case .systemMedium:
            WidgetPokemon(widgetSize: .medium)
                .environmentObject(entry.pokemon)
            
        case .systemLarge:
            WidgetPokemon(widgetSize: .large)
                .environmentObject(entry.pokemon)
            
        default:
            WidgetPokemon(widgetSize: .large)
                .environmentObject(entry.pokemon)
        }
    }
}

struct Dex3Widget: Widget {
    let kind: String = "Dex3Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Dex3WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

#Preview(as: .systemMedium) {
    Dex3Widget()
} timeline: {
    SimpleEntry(
        date: .now,
        pokemon: SamplePokemon.samplePokemon
    )
}
