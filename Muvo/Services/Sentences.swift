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
        PracticeSentence(english: "I have a reservation under my name.", indonesian: "Saya punya reservasi atas nama saya.", category: .hotel, modelName: "soundclafHOT", audioFileName: "reservation.wav"), // H1
        PracticeSentence(english: "I'd like to check in please.", indonesian: "Saya ingin check in.", category: .hotel, modelName: "soundclafHOT", audioFileName: "checkin.wav"), // H2
        PracticeSentence(english: "Is breakfast included?", indonesian: "Apakah sarapan sudah termasuk?", category: .hotel, modelName: "soundclafHOT", audioFileName: "breakfast.wav"), // H3
        PracticeSentence(english: "There is a problem with my room.", indonesian: "Ada masalah dengan kamar saya.", category: .hotel, modelName: "soundclafHOT", audioFileName: "problem.wav"), // H4
        PracticeSentence(english: "I need a non smoking room please.", indonesian: "Saya butuh kamar non-smoking.", category: .hotel, modelName: "soundclafHOT", audioFileName: "nonsmoke.wav") // H5
    ]

    private let airportSentences: [PracticeSentence] = [
        PracticeSentence(english: "My luggage is missing.", indonesian: "Koper saya hilang.", category: .airport, modelName: "soundclafAIR", audioFileName: "Lugguage.wav"), // A1
        PracticeSentence(english: "Where is the immigration counter?", indonesian: "Di mana konter imigrasi?", category: .airport, modelName: "soundclafAIR", audioFileName: "immigrationcounter.wav"), // A2
        PracticeSentence(english: "I missed my flight.", indonesian: "Saya ketinggalan pesawat.", category: .airport, modelName: "soundclafAIR", audioFileName: "myflight.wav"), // A3
        PracticeSentence(english: "Here is my passport and ticket.", indonesian: "Ini paspor dan tiket saya.", category: .airport, modelName: "soundclafAIR", audioFileName: "Passportandticket.wav"), // A4
        PracticeSentence(english: "I lost my boarding pass.", indonesian: "Saya kehilangan boarding pass.", category: .airport, modelName: "soundclafAIR", audioFileName: "boardingpass.wav") // A5
    ]
    
    private var group1: [PracticeSentence] {
        return [
            hotelSentences[0],
            hotelSentences[4],
            hotelSentences[2],
            airportSentences[1],
            airportSentences[4]
        ]
    }

    private var group2: [PracticeSentence] {
        return [
            hotelSentences[1],
            hotelSentences[3],
            airportSentences[2],
            airportSentences[0],
            airportSentences[3]
        ]
    }
    
    func getSentences(for group: Int) -> [PracticeSentence] {
        if group == 2 {
            return group2
        }
        return group1
    }
}
