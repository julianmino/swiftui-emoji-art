//
//  Extensions.swift
//  Emoji Art
//
//  Created by Julian Miño on 14/01/2024.
//

import SwiftUI

typealias CGOffset = CGSize

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), size: size)
    }
}

extension CGOffset {
    static func +(lhs: CGOffset, rhs: CGOffset) -> CGOffset {
        CGOffset(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func +=(lhs: inout CGOffset, rhs: CGOffset) {
        lhs = lhs + rhs
    }
}

extension String {
    var uniqued: String {
        reduce(into: "") { partialResult, element in
            if !partialResult.contains(element) {
                partialResult.append(element)
            }
        }
    }
}

extension AnyTransition {
    static let rollUp: AnyTransition = .asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top))
    static let rollDown: AnyTransition = .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
}

struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    var role: ButtonRole?
    let action: () -> Void
    
    init(title: String? = nil, systemImage: String? = nil, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role) {
            withAnimation {
                action()
            }
        } label: {
            if let title, let systemImage {
                Label(title, systemImage: systemImage)
            } else if let title {
                Text(title)
            } else if let systemImage {
                Image(systemName: systemImage)
            }
        }

    }
}

extension URL {
    // some search engines give out a url which has yet another reference to the actual image url embedded in it
    // (e.g. https://searchresult.searchengine.com?imgurl=https://actualimageurl.jpg)
    // this property returns the first embedded url it finds (if any)
    // if there is no embedded url, it returns self
    
    var imageURL: URL {
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems {
            for queryItem in queryItems {
                if let value = queryItem.value, value.hasPrefix("http"), let imgurl = URL(string: value) {
                    return imgurl
                }
            }
        }
        return self
    }

    // returns the image data for data scheme url (if applicable)
    // for example, "data:image/jpeg;base64,<base 64 encoded image data>"
    // (this is as opposed to, for example, "https://stanford.edu/image.jpg")
    // images are rarely passed around using data schemes
    // it generally only makes sense for small images (thumbnails, etc.)
    
    var dataSchemeImageData: Data? {
        let urlString = absoluteString
        // is this a data scheme url with some sort of image as the mime type?
        if urlString.hasPrefix("data:image") {
            // yes, find the comma that separates the meta info from the image data
            if let comma = urlString.firstIndex(of: ","), comma < urlString.endIndex {
                let meta = urlString[..<comma]
                // we can only handle base64 encoded data
                if meta.hasSuffix("base64") {
                    let data = String(urlString.suffix(after: comma))
                    // get the data
                    if let imageData = Data(base64Encoded: data) {
                        return imageData
                    }
                }
            }
        }
        // not a data scheme or the data doesn't seem to be a base64 encoded image
        return nil
    }
}

extension Collection {
    // this will crash if after >= endIndex
    func suffix(after: Self.Index) -> Self.SubSequence {
        suffix(from: index(after: after))
    }
}
