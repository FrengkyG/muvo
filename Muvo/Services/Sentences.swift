//
//  Sentences.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI
import Foundation


class SentenceProvider {

    private let hotelSentences: [PracticeSentence] = [
        PracticeSentence(english: "I have a reservation under my name.", indonesian: "Saya punya reservasi atas nama saya.", category: .hotel, modelName: "soundclafHOT"),
        PracticeSentence(english: "I'd like to check in please.", indonesian: "Saya ingin check in.", category: .hotel, modelName: "soundclafHOT"),
        PracticeSentence(english: "Is breakfast included?", indonesian: "Apakah sarapan sudah termasuk?", category: .hotel, modelName: "soundclafHOT"),
        PracticeSentence(english: "There is a problem with my room.", indonesian: "Ada masalah dengan kamar saya.", category: .hotel, modelName: "soundclafHOT"),
        PracticeSentence(english: "I need a non smoking room please.", indonesian: "Saya butuh kamar non-smoking.", category: .hotel, modelName: "soundclafHOT")
    ]

    private let airportSentences: [PracticeSentence] = [
        PracticeSentence(english: "My luggage is missing.", indonesian: "Koper saya hilang.", category: .airport, modelName: "soundclafAIR"),
        PracticeSentence(english: "Where is the immigration counter?", indonesian: "Di mana konter imigrasi?", category: .airport, modelName: "soundclafAIR"),
        PracticeSentence(english: "I missed my flight.", indonesian: "Saya ketinggalan pesawat.", category: .airport, modelName: "soundclafAIR"),
        PracticeSentence(english: "Here is my passport and ticket.", indonesian: "Ini paspor dan tiket saya.", category: .airport, modelName: "soundclafAIR"),
        PracticeSentence(english: "I lost my boarding pass.", indonesian: "Saya kehilangan boarding pass.", category: .airport, modelName: "soundclafAIR")
    ]

    /// Returns a shuffled list of all available practice sentences.
    func getRandomizedSentences() -> [PracticeSentence] {
        return (hotelSentences + airportSentences).shuffled()
    }
}
