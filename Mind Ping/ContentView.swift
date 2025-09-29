//
//  ContentView.swift
//  Mind Ping
//
//  Created by Рома Котов on 29.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        TabView {
            ReflectView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Reflect")
                }
            HistoryView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
            AchievementsView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Achievements")
                }
            ProfileView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    ContentView()
}
