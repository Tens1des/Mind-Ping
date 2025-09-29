//
//  ProfileView.swift
//  Mind Ping
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var app: AppState
    @State private var nameInput: String = ""

    private let themeColors: [Color] = [Color.purple, Color.green, Color.orange, Color.cyan, Color.black]
    private let textSizes: [String] = ["Small", "Normal", "Large"]
    private let avatarNames: [String] = (1...10).map { "ava\($0)" }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                profileCard
                themeCard
                languageCard
                textSizeCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(app.currentThemeBackground.ignoresSafeArea())
        .onAppear { nameInput = app.username }
    }

    private var header: some View {
        HStack {
            Text("Settings").font(.headline).foregroundStyle(app.currentTextColor)
            Spacer()
            Image(systemName: "gearshape").foregroundStyle(app.currentTextColor)
        }
        .padding(.top, 12)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(app.reflectingSinceString)
                .foregroundStyle(app.currentThemeColor)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(app.currentThemeColor.opacity(0.15)).frame(width: 80, height: 80)
                    if let uiImage = UIImage(named: app.avatarName), !app.avatarName.isEmpty {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(app.currentThemeColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Name", text: $nameInput, onCommit: { app.username = nameInput })
                        .textFieldStyle(.roundedBorder)
                        .font(.headline)
                    Text("Tap to edit your name").font(.caption).foregroundStyle(app.selectedThemeIndex == 4 ? .white.opacity(0.7) : .secondary)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Choose your avatar").font(.headline).foregroundStyle(app.currentTextColor)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                    ForEach(avatarNames, id: \.self) { name in
                        Button(action: { app.avatarName = name }) {
                            ZStack {
                                Circle()
                                    .fill(app.avatarName == name ? app.currentThemeColor.opacity(0.2) : app.currentThemeColor.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(app.avatarName == name ? app.currentThemeColor : Color.clear, lineWidth: 2)
                                    )
                                if let uiImage = UIImage(named: name) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(app.currentCardFill))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(app.currentStrokeColor, lineWidth: 1))
    }

    private var themeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "paintpalette").foregroundStyle(app.currentTextColor)
                Text("Color Theme").font(.headline).foregroundStyle(app.currentTextColor)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(themeColors.enumerated()), id: \.offset) { idx, color in
                        Button(action: { app.selectedThemeIndex = idx }) {
                            Circle()
                                .fill(color)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Circle()
                                        .stroke(idx == app.selectedThemeIndex ? app.currentThemeColor : Color.clear, lineWidth: 3)
                                )
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(app.currentCardFill))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(app.currentStrokeColor, lineWidth: 1))
    }

    private var languageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "globe").foregroundStyle(app.currentTextColor)
                Text("Language").font(.headline).foregroundStyle(app.currentTextColor)
            }
            Text("Choose your preferred language").font(.subheadline).foregroundStyle(app.selectedThemeIndex == 4 ? .white.opacity(0.7) : .secondary)
            HStack {
                Text(app.languageCode == "en" ? "English" : app.languageCode.uppercased())
                    .font(.subheadline)
                    .foregroundStyle(app.currentTextColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(app.selectedThemeIndex == 4 ? .white.opacity(0.7) : .secondary)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12).fill(app.currentFieldFill))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(app.currentStrokeColor, lineWidth: 1))
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(app.currentCardFill))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(app.currentStrokeColor, lineWidth: 1))
    }

    private var textSizeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "textformat").foregroundStyle(app.currentTextColor)
                Text("Text Size").font(.headline).foregroundStyle(app.currentTextColor)
            }
            Text("Adjust reading comfort").font(.subheadline).foregroundStyle(app.selectedThemeIndex == 4 ? .white.opacity(0.7) : .secondary)
            HStack {
                Text(app.textSize)
                    .font(.subheadline)
                    .foregroundStyle(app.currentTextColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(app.selectedThemeIndex == 4 ? .white.opacity(0.7) : .secondary)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12).fill(app.currentFieldFill))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(app.currentStrokeColor, lineWidth: 1))
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(app.currentCardFill))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(app.currentStrokeColor, lineWidth: 1))
    }

    private var aboutCard: some View { EmptyView() }
}

#Preview {
    ProfileView().environmentObject(AppState())
}


