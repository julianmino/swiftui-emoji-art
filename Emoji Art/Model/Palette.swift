//
//  Palette.swift
//  Emoji Art
//
//  Created by Julian Miño on 27/01/2024.
//

import Foundation

struct Palette: Identifiable, Codable, Hashable {
    var name: String
    var emojis: String
    var id = UUID()
    
    static var builtins: [Palette] { [
        Palette(name: "Vehicles", emojis: "🚗🚕🚙🚌🚎🏎️🚓🚑🚒🚐🛻🚚🚛🚜🛴🚲🏍️🛵✈️🚁🚀🛶🚤⛵🛳️🚢🚂🚆🚇🚊🚞🚉🚄🚅🚈🚝🚋🚃"),
        Palette(name: "Instruments", emojis: "🎻🎸🎺🎹🎷🥁🎤🎧🎚️🎛️🎶🎵🎼🪕🎭🪘🎺📯🎙️🎚️🎛️🪙🎚️🎤🎻🪕🪘🥁🪢🪕🎸🎷"),
        Palette(name: "Animals", emojis: "🦛🦏🦓🐪🐫🦒🦔🦘🦘🦘🦇🦉🦢🦩🦚🦜🦔🐓🦢🦩🦚🦜🦇🦉🦤🦦🦥🦨"),
        Palette(name: "Sports", emojis: "⚽🏀🏈⚾🎾🏐🏉🎱🏓🏸🥅🏒🏑🥍🏏🪃🏹🎳⛳🏌️‍♂️🏌️‍♀️🏇🏆🥇🥈🥉🎽🏋️‍♂️🏋️‍♀️🤼‍♂️🤼‍♀️🤸‍♂️🤸‍♀️🤺🥋"),
        Palette(name: "Flora", emojis: "🌷🌹🌺🌸🌼🌻🍁🍂🍃🍄🌰🌲🌳🌴🌵🌾🌿☘️🍀🍃🍂🍁🍇🍈🍉🍊🍋🍌🍍🍎🍏🍐🍑🍒🍓🍅🍆🌽")
    ]
    }
}
