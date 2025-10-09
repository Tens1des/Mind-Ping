//
//  AchievementsView.swift
//  Mind Ping
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                profileCard
                statsRow
                progressCard
                ForEach(app.achievements) { item in
                    achievementRow(item)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(app.currentThemeBackground.ignoresSafeArea())
        .onAppear { app.markHistoryViewed() }
    }

    private var header: some View {
        HStack {
            Text("Your Profile").font(.headline).foregroundStyle(.black)
            Spacer()
            Image(systemName: "gearshape")
        }
        .padding(.top, 12)
    }

    private var profileCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(app.currentThemeColor.opacity(0.15)).frame(width: 56, height: 56)
                if let uiImage = UIImage(named: app.avatarName), !app.avatarName.isEmpty {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .font(.system(size: 36))
                        .foregroundStyle(app.currentThemeColor)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(app.username).font(.headline).foregroundStyle(.black)
                Text(app.reflectingSinceString)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(app.currentThemeColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(app.allReflectionsSorted.count)", title: "Reflections", icon: "bolt")
            statCard(value: "\(streak())", title: "Day Streak", icon: "flame")
        }
    }

    private func statCard(value: String, title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(app.currentThemeColor)
            Text(value).font(.title2).bold().foregroundStyle(.black)
            Text(title).font(.subheadline).foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.2), lineWidth: 1))
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Overall Progress").foregroundStyle(app.currentThemeColor)
                Spacer()
                Text("\(min(100, streak() * 100 / 31))%")
            }
            Text("Day Streak")
                .font(.caption)
                .foregroundStyle(.secondary)
            ProgressView(value: Double(streak()), total: 31)
                .tint(app.currentThemeColor)
            HStack {
                Spacer()
                Text("\(streak()) / 31 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.2), lineWidth: 1))
    }

    private func achievementRow(_ a: Achievement) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle().fill((a.isUnlocked ? Color.green.opacity(0.18) : app.currentThemeColor.opacity(0.12))).frame(width: 44, height: 44)
                Image(systemName: a.isUnlocked ? "checkmark.circle.fill" : "sparkles")
                    .foregroundStyle(a.isUnlocked ? .green : app.currentThemeColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(a.title)
                    .font(.headline)
                    .foregroundStyle(.black)
                Text(a.description)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(a.isUnlocked ? Color.green.opacity(0.12) : Color.white.opacity(0.03))
        )
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.2), lineWidth: 1))
    }

    private func streak() -> Int {
        // compute longest streak (same as in service, but simple view-side for display)
        let calendar = Calendar.current
        let keys = Dictionary(grouping: app.allReflectionsSorted, by: { $0.date.yyyyMMdd }).keys
        let dates = keys.compactMap { key -> Date? in
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.date(from: key)
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
}

#Preview {
    AchievementsView().environmentObject(AppState())
}


