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
                if document.background.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position(Emoji.Position.zero.in(geometry))
                }
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .onTapGesture(count: 2) {
                zoomToFit(document.bbox, in: geometry)
            }
            .dropDestination(for: CustomTransferable.self) { transferable, location in
                return drop(transferable, at: location, in: geometry)
            }
            .onChange(of: document.background.failureReason) { _, newValue in
                showBackgroundFailureAlert = newValue != nil
            }
            .onChange(of: document.background.uiImage, { _, newValue in
                zoomToFit(newValue?.size, in: geometry)
            })
            .alert(
                "Set Background",
                isPresented: $showBackgroundFailureAlert,
                presenting: document.background.failureReason,
                actions: { _ in
                    Button("OK", role: .cancel) { }
                },
                message: { reason in
                    Text(reason)
                })
        }
    }
    
    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
        if let size {
            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: -rect.midX * zoom,
                    height: -rect.midY * zoom
                )
            }
        }
    }
    
    @State private var showBackgroundFailureAlert = false
    
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
        if let uiImage = document.background.uiImage {
            Image(uiImage: uiImage)
                .position(Emoji.Position.zero.in(geometry))
        }
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
