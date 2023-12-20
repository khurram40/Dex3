

import SwiftUI
import CoreData

struct PokemonDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var pokemon: Pokemon
    @State var showShiny = false
    
    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 6)
                
                AsyncImage(url: showShiny ? pokemon.shinySprite : pokemon.sprite) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 50)
                        .shadow(color: .black, radius: 6)
                } placeholder: {
                    ProgressView()
                }
            }
            
            Text("Types")
                .font(.title)
                .padding(.bottom, -5)
            
            HStack {
                if let types = pokemon.types {
                    ForEach(types, id: \.self) { type in
                        Text(type.capitalized)
                            .font(.title2)
                            .shadow(color: .white, radius: 5)
                            .padding([.top, .bottom], 7)
                            .padding([.leading, .trailing])
                            .background(Color(type.capitalized))
                            .cornerRadius(20)
                    }
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        pokemon.favorite.toggle()
                        
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                } label: {
                    if pokemon.favorite {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
                .font(.largeTitle)
                .foregroundStyle(.yellow)
                
            }
            .padding()
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -5)
            
            StatsView()
                .environmentObject(pokemon)
            
        }
        .navigationTitle(pokemon.name?.capitalized ?? "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShiny.toggle()
                } label: {
                    if showShiny {
                        Image(systemName:"wand.and.stars")
                    } else {
                        Image(systemName:"wand.and.stars.inverse")
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
    }
}

#Preview {
    PokemonDetail()
        .environmentObject(SamplePokemon.samplePokemon)
}
