//
//  CustomTransferable.swift
//  Emoji Art
//
//  Created by Julian Miño on 17/01/2024.
//

import CoreTransferable

enum CustomTransferable: Transferable {
    case string(String)
    case url(URL)
    case data(Data)
    
    init(url: URL) {
        if let imageData = url.dataSchemeImageData {
            self = .data(imageData)
        } else {
            self = .url(url)
        }
    }
    
    init(string: String) {
        if string.hasPrefix("http"), let url = URL(string: string) {
            self = .url(url)
        } else {
            self = .string(string)
        }
    }
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { CustomTransferable(string: $0) }
        ProxyRepresentation { CustomTransferable(url: $0) }
        ProxyRepresentation { CustomTransferable.data($0) }
    }
}
