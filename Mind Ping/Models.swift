//
//  Models.swift
//  Mind Ping
//
//  Domain models for questions, reflections and profile.
//

import Foundation

struct Question: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

struct EmojiChoice: Identifiable, Codable, Hashable {
    let id: UUID
    let value: String

    init(id: UUID = UUID(), value: String) {
        self.id = id
        self.value = value
    }
}

struct Reflection: Identifiable, Codable {
    let id: UUID
    let date: Date // day-level grouping
    var question: String
    var text: String
    var emojis: [String]

    init(id: UUID = UUID(), date: Date = Date(), question: String, text: String, emojis: [String]) {
        self.id = id
        self.date = date
        self.question = question
        self.text = text
        self.emojis = emojis
    }
}

struct UserProfile: Codable {
    var name: String
}

struct Achievement: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    var isUnlocked: Bool

    static var all: [Achievement] {
        return [
            Achievement(id: 1, title: "First Step", description: "Complete your first reflection.", isUnlocked: false),
            Achievement(id: 2, title: "Diary Started", description: "Answered questions for 3 consecutive days.", isUnlocked: false),
            Achievement(id: 3, title: "Week of Awareness", description: "Answered daily for 7 consecutive days.", isUnlocked: false),
            Achievement(id: 4, title: "Positive Outlook", description: "Used emojis with positive emotions 5 times.", isUnlocked: false),
            Achievement(id: 5, title: "Honest Journal", description: "Wrote a text response to every question for the day.", isUnlocked: false),
            Achievement(id: 6, title: "Combo Expression", description: "Answered with text and emojis in one day.", isUnlocked: false),
            Achievement(id: 7, title: "Full Week", description: "Completed entries every day of a week.", isUnlocked: false),
            Achievement(id: 8, title: "Lunar Observer", description: "Answered for 30 consecutive days.", isUnlocked: false),
            Achievement(id: 9, title: "Emotional Spectrum", description: "Used at least 5 different emojis.", isUnlocked: false),
            Achievement(id: 10, title: "Inspiring Moment", description: "Wrote an especially long or detailed response.", isUnlocked: false),
            Achievement(id: 11, title: "Story Collected", description: "Viewed all previous reflections at least once.", isUnlocked: false),
            Achievement(id: 12, title: "Master of Reflection", description: "Completed 100 days of reflections.", isUnlocked: false)
        ]
    }
}

extension Date {
    var yyyyMMdd: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}


