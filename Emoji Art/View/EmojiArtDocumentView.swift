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
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
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
                paletteEmojiSize / zoom
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
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background)
            .position(Emoji.Position.zero.in(geometry))
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .position(emoji.position.in(geometry))
        }
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom, body: { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            })
            .onEnded { endingPinchScale in
                zoom *= endingPinchScale
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan, body: { value, gesturePan, _ in
                gesturePan = value.translation
            })
            .onEnded { value in
                pan += value.translation
            }
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(name: "Preview"))
}
