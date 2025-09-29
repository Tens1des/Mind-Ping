//
//  Services.swift
//  Mind Ping
//
//  Storage, question provider, and app state.
//

import Foundation
import SwiftUI

final class LocalStorageService {
    private let reflectionsFilename = "reflections.json"

    private var reflectionsURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(reflectionsFilename)
    }

    func loadReflections() -> [Reflection] {
        guard let data = try? Data(contentsOf: reflectionsURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Reflection].self, from: data)) ?? []
    }

    func saveReflections(_ items: [Reflection]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(items) {
            try? data.write(to: reflectionsURL)
        }
    }
}

final class DailyQuestionProvider {
    // For now, embed a short seed; later replace with full 150 and/or remote updates.
    private let questionsSeed: [String] = [
        "What feeling accompanied you most often today?",
        "What made you smile today?",
        "What are you grateful for today?"
    ]

    func questionFor(date: Date) -> String {
        // Deterministic rotation by day to avoid repeats in short window
        let dayIndex = abs(date.yyyyMMdd.hashValue)
        let idx = dayIndex % max(questionsSeed.count, 1)
        return questionsSeed[idx]
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var username: String = UserDefaults.standard.string(forKey: "username") ?? "Alex Johnson" {
        didSet { UserDefaults.standard.set(username, forKey: "username") }
    }
    @Published var textInput: String = ""
    @Published var selectedEmojis: [String] = []
    @Published private(set) var todayQuestion: String = ""
    @Published private(set) var savedToday: Reflection?
    @Published var selectedDate: Date = Date()

    private let storage = LocalStorageService()
    private let provider = DailyQuestionProvider()
    private var reflections: [Reflection] = []
    @Published var selectedThemeIndex: Int = UserDefaults.standard.integer(forKey: "themeIndex") {
        didSet { UserDefaults.standard.set(selectedThemeIndex, forKey: "themeIndex") }
    }
    @Published var languageCode: String = UserDefaults.standard.string(forKey: "languageCode") ?? "en" {
        didSet { UserDefaults.standard.set(languageCode, forKey: "languageCode") }
    }
    @Published var textSize: String = UserDefaults.standard.string(forKey: "textSize") ?? "Normal" {
        didSet { UserDefaults.standard.set(textSize, forKey: "textSize") }
    }
    @Published var avatarName: String = UserDefaults.standard.string(forKey: "avatarName") ?? "" {
        didSet { UserDefaults.standard.set(avatarName, forKey: "avatarName") }
    }

    // Theme colors
    private let themeColors: [Color] = [Color.purple, Color.green, Color.orange, Color.cyan, Color.black]
    
    var currentThemeColor: Color {
        return themeColors[selectedThemeIndex]
    }
    
    var currentThemeBackground: Color {
        switch selectedThemeIndex {
        case 0: return Color(red: 1.0, green: 0.95, blue: 0.98) // pink
        case 1: return Color(red: 0.95, green: 1.0, blue: 0.95) // light green
        case 2: return Color(red: 1.0, green: 0.97, blue: 0.9) // light orange
        case 3: return Color(red: 0.95, green: 0.98, blue: 1.0) // light cyan
        case 4: return Color.black.opacity(0.95) // black
        default: return Color(red: 1.0, green: 0.95, blue: 0.98)
        }
    }

    // Adaptive UI helpers for strokes and fills
    var currentStrokeColor: Color {
        return selectedThemeIndex == 4 ? Color.white.opacity(0.2) : currentThemeColor.opacity(0.2)
    }

    var currentCardFill: Color {
        return selectedThemeIndex == 4 ? Color.white.opacity(0.06) : Color.white.opacity(0.03)
    }

    var currentFieldFill: Color {
        return selectedThemeIndex == 4 ? Color.white.opacity(0.08) : Color.white.opacity(0.05)
    }

    var currentTextColor: Color {
        return selectedThemeIndex == 4 ? Color.white : Color.primary
    }

    // First launch date (for "Reflecting since {Mon YYYY}")
    @Published private(set) var firstLaunchDate: Date = {
        let ts = UserDefaults.standard.double(forKey: "firstLaunchTimestamp")
        if ts > 0 {
            return Date(timeIntervalSince1970: ts)
        } else {
            let now = Date()
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "firstLaunchTimestamp")
            return now
        }
    }()

    var reflectingSinceString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return "Reflecting since \(f.string(from: firstLaunchDate))"
    }

    // Achievements state
    @Published private(set) var achievements: [Achievement] = Achievement.all

    init() {
        reflections = storage.loadReflections()
        refreshToday()
        loadTodaySaved()
    }

    func refreshToday(now: Date = Date()) {
        todayQuestion = provider.questionFor(date: now)
    }

    func loadTodaySaved(now: Date = Date()) {
        savedToday = reflections.first { $0.date.yyyyMMdd == now.yyyyMMdd }
        if let saved = savedToday {
            textInput = saved.text
            selectedEmojis = saved.emojis
        }
    }

    func toggleEmoji(_ emoji: String) {
        if let idx = selectedEmojis.firstIndex(of: emoji) {
            selectedEmojis.remove(at: idx)
        } else {
            selectedEmojis.append(emoji)
        }
    }

    func saveToday(now: Date = Date()) {
        let reflection = Reflection(
            date: now,
            question: todayQuestion,
            text: textInput.trimmingCharacters(in: .whitespacesAndNewlines),
            emojis: selectedEmojis
        )

        // replace or append for the day
        if let idx = reflections.firstIndex(where: { $0.date.yyyyMMdd == now.yyyyMMdd }) {
            reflections[idx] = reflection
        } else {
            reflections.append(reflection)
        }
        storage.saveReflections(reflections)
        savedToday = reflection
        recomputeAchievements()
    }

    // MARK: - History helpers

    var allReflectionsSorted: [Reflection] {
        reflections.sorted { $0.date > $1.date }
    }

    var reflectionsForSelectedDate: [Reflection] {
        let key = selectedDate.yyyyMMdd
        return allReflectionsSorted.filter { $0.date.yyyyMMdd == key }
    }

    func setSelectedDate(_ date: Date) {
        selectedDate = date
    }

    func emojisFor(date: Date, limit: Int = 3) -> [String] {
        let key = date.yyyyMMdd
        let all = reflections
            .filter { $0.date.yyyyMMdd == key }
            .flatMap { $0.emojis }
        // keep order of appearance, make unique
        var seen: Set<String> = []
        var result: [String] = []
        for e in all {
            if !seen.contains(e) {
                seen.insert(e)
                result.append(e)
            }
            if result.count >= limit { break }
        }
        return result
    }

    // MARK: - Achievements
    private func recomputeAchievements() {
        var updated = Achievement.all
        let calendar = Calendar.current

        // Helpers
        let byDay: [String: [Reflection]] = Dictionary(grouping: reflections, by: { $0.date.yyyyMMdd })
        let sortedUniqueDays = byDay.keys.sorted()

        func maxConsecutiveDays() -> Int {
            let dates = sortedUniqueDays.compactMap { key -> Date? in
                let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"; return formatter.date(from: key)
            }.sorted()
            guard !dates.isEmpty else { return 0 }
            var best = 1, cur = 1
            for i in 1..<dates.count {
                if let d = calendar.date(byAdding: .day, value: 1, to: dates[i-1]), calendar.isDate(d, inSameDayAs: dates[i]) {
                    cur += 1; best = max(best, cur)
                } else { cur = 1 }
            }
            return best
        }

        let totalDays = byDay.count
        let consecutive = maxConsecutiveDays()

        // 1 First Step: at least 1 reflection
        updated[0].isUnlocked = !reflections.isEmpty
        // 2 Diary Started: 3 consecutive days
        updated[1].isUnlocked = consecutive >= 3
        // 3 Week of Awareness: 7 consecutive days
        updated[2].isUnlocked = consecutive >= 7
        // 4 Positive Outlook: positive emojis >= 5
        let positiveSet: Set<String> = ["😀","😄","😊","🥰","😍","🤩","😎","😇","😌","😁","😺","😻"]
        let positiveCount = reflections.flatMap { $0.emojis }.filter { positiveSet.contains($0) }.count
        updated[3].isUnlocked = positiveCount >= 5
        // 5 Honest Journal: wrote text for all questions of the day (we have 1 question) -> text not empty on any saved day
        updated[4].isUnlocked = byDay.values.contains { day in day.contains { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } }
        // 6 Combo Expression: both text and emojis in one day
        updated[5].isUnlocked = byDay.values.contains { day in day.contains { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !$0.emojis.isEmpty } }
        // 7 Full Week: every day of a 7-day week (same as 3 but named)
        updated[6].isUnlocked = consecutive >= 7
        // 8 Lunar Observer: 30 consecutive days
        updated[7].isUnlocked = consecutive >= 30
        // 9 Emotional Spectrum: at least 5 distinct emojis overall
        updated[8].isUnlocked = Set(reflections.flatMap { $0.emojis }).count >= 5
        // 10 Inspiring Moment: especially long text (>=120 chars)
        updated[9].isUnlocked = reflections.contains { $0.text.count >= 120 }
        // 11 Story Collected: opened history at least once (toggle externally)
        // Keep as is; expose method to mark seen
        // 12 Master of Reflection: 100 days with any reflection
        updated[11].isUnlocked = totalDays >= 100

        achievements = updated
    }

    func markHistoryViewed() {
        var updated = achievements
        if updated.indices.contains(10) { updated[10].isUnlocked = true }
        achievements = updated
    }
}


