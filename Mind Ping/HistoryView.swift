//
//  HistoryView.swift
//  Mind Ping
//
//  History tab with simple month grid and list of reflections for selected date.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var app: AppState
    @State private var currentMonthOffset: Int = 0

    private var monthDates: [Date] {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        var components = calendar.dateComponents([.year, .month], from: base)
        components.day = 1
        let startOfMonth = calendar.date(from: components) ?? base
        let range = calendar.range(of: .day, in: .month, for: startOfMonth) ?? 1..<31
        return range.compactMap { day in
            calendar.date(bySetting: .day, value: day, of: startOfMonth)
        }
    }

    private var monthTitle: String {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: base).capitalized
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            calendarCard
            Text("Recent Reflections (Selected dates)")
                .font(.subheadline)
                .padding(.horizontal, 16)
            listSection
            Spacer(minLength: 0)
        }
        .background(app.currentThemeBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(app.currentThemeColor.opacity(0.2)).frame(width: 40, height: 40)
                    if let uiImage = UIImage(named: app.avatarName), !app.avatarName.isEmpty {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle").foregroundStyle(app.currentThemeColor)
                    }
                }
                Text("Hello \(app.username)").font(.headline)
            }
            Spacer()
            Text(Date().formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var calendarCard: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { currentMonthOffset -= 1 }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthTitle).font(.headline)
                Spacer()
                Button(action: { currentMonthOffset += 1 }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal, 12)
            weekHeader
            monthGrid
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).stroke(app.currentThemeColor.opacity(0.25), lineWidth: 1.5))
        .padding(.horizontal, 16)
    }

    private var weekHeader: some View {
        let symbols = Calendar.current.shortWeekdaySymbols // Sun..Sat locale-based
        return HStack {
            ForEach(symbols, id: \.self) { s in
                Text(s.prefix(2)).font(.caption).frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        var components = calendar.dateComponents([.year, .month], from: base)
        components.day = 1
        let startOfMonth = calendar.date(from: components) ?? base
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) // 1..7

        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7
        let cells = Array(repeating: Date?.none, count: leadingEmpty) + monthDates.map { Optional($0) }
        let rows = stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<min($0+7, cells.count)]) }

        return VStack {
            ForEach(0..<rows.count, id: \.self) { row in
                HStack {
                    ForEach(0..<7, id: \.self) { col in
                        let date = col < rows[row].count ? rows[row][col] : nil
                        dayCell(date)
                    }
                }
            }
        }
    }

    private func dayCell(_ date: Date?) -> some View {
        Button(action: { if let d = date { app.setSelectedDate(d) } }) {
            ZStack {
                if let d = date {
                    let isSelected = app.selectedDate.yyyyMMdd == d.yyyyMMdd
                    VStack(spacing: 2) {
                        ZStack {
                    Circle()
                        .fill(isSelected ? app.currentThemeColor.opacity(0.25) : Color.clear)
                                .frame(width: 32, height: 32)
                            Text("\(Calendar.current.component(.day, from: d))")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                        HStack(spacing: 2) {
                            ForEach(app.emojisFor(date: d), id: \.self) { e in
                                Text(e).font(.system(size: 10))
                            }
                        }
                        .frame(height: 12)
                    }
                } else {
                    Text("")
                        .frame(width: 32, height: 32)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private var listSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(app.reflectionsForSelectedDate) { item in
                    reflectionCard(item)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
    }

    private func reflectionCard(_ r: Reflection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(r.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(app.currentThemeColor)
                    .font(.subheadline)
                Spacer()
                HStack(spacing: 8) {
                    ForEach(r.emojis, id: \.self) { e in Text(e) }
                }
            }
            Text(r.question)
                .font(.headline)
            if !r.text.isEmpty {
                Text(r.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).stroke(app.currentThemeColor.opacity(0.25), lineWidth: 1.5))
    }
}

#Preview {
    HistoryView().environmentObject(AppState())
}


