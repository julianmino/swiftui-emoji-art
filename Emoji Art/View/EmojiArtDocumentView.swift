//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Julian Miño on 14/01/2024.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    @ObservedObject var document: EmojiArtDocument
    
    private let emojis = "🌳🌾🌻🚜🌄🐄🐦🏡🌷🍃🌞🍂🍁🚲🎣🌲🌼🌿🚶‍♂️🍎🍇🌰🐓🌺🍄🐑"
    
    private let paletteEmojiSize: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            ScrollingEmojis(emojis)
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                AsyncImage(url: document.background)
                    .position(Emoji.Position.zero.in(geometry))
                ForEach(document.emojis) { emoji in
                    Text(emoji.string)
                        .font(emoji.font)
                        .position(emoji.position.in(geometry))
                }
            }
            .dropDestination(for: CustomTransferable.self) { transferable, location in
                return drop(transferable, at: location, in: geometry)
            }
        }
    }
    
    private func drop(_ transferables: [CustomTransferable], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        guard let transferable = transferables.first else { return false }
        switch transferable {
        case .string(let emoji):
            document.addEmoji(
                emoji,
                emojiPosition(at: location, in: geometry),
                paletteEmojiSize
            )
            return true
        case .url(let url):
            document.setBackground(url)
            return true
        default:
            break
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int(location.x - center.x),
            y: Int(-(location.y - center.y))
        )
    }
}

struct ScrollingEmojis: View {
    let emojis: [String]
    
    init(_ emojis: String) {
        self.emojis = emojis.uniqued.map(String.init)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
}
