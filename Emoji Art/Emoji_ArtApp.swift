//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Julian Miño on 14/01/2024.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(name: "Main")
    @StateObject var paletteStore2 = PaletteStore(name: "Second")
    @StateObject var paletteStore3 = PaletteStore(name: "Third")
    @StateObject var paletteStore4 = PaletteStore(name: "Forth")
    
    var body: some Scene {
        WindowGroup {
//            PaletteManager(stores: [paletteStore, paletteStore2, paletteStore3, paletteStore4])
            EmojiArtDocumentView(document: defaultDocument)
                .environmentObject(paletteStore)
        }
    }
}
