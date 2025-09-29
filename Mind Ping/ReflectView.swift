//
//  ReflectView.swift
//  Mind Ping
//
//  Main screen per design (logic; visuals to be aligned with final mocks).
//

import SwiftUI

struct ReflectView: View {
    @EnvironmentObject var app: AppState

    private let defaultEmojiRow: [String] = [
        "😀","😃","😄","😁","😆","😂","🙂","😊","😍","🥰",
        "😘","😗","😙","😚","😎","🤩","🤗","🤔","😌","😇",
        "😢","😭","😤","😠","😴","🤤","🤒","🤕","🤧","🤯"
    ]

    var body: some View {
        VStack(spacing: 24) {
            header
            questionCard
            inputCard
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
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
                Text("Hello \(app.username)")
                    .font(.headline)
            }
            Spacer()
            Text(Date().formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var questionCard: some View {
        VStack(spacing: 12) {
            Text("Today's question")
                .foregroundStyle(app.currentThemeColor)
                .font(.subheadline)
            Text(app.todayQuestion)
                .font(.title2).bold()
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.primary.opacity(0.05)))
        .padding(.top, 4)
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your Thoughts")
                .font(.system(size: 22, weight: .semibold))
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(app.currentThemeColor.opacity(0.25), lineWidth: 1.5)
                    )
                TextEditor(text: $app.textInput)
                    .frame(height: 120)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                if app.textInput.isEmpty {
                    Text("Share what's on your mind...")
                        .foregroundStyle(app.currentThemeColor.opacity(0.35))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("How do you feel?")
                    .font(.system(size: 22, weight: .semibold))
                emojiRow
                Button(action: { app.saveToday() }) {
                    Text("Save reflection")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .disabled(app.textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && app.selectedEmojis.isEmpty)
                .opacity((app.textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && app.selectedEmojis.isEmpty) ? 0.6 : 1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(app.currentThemeColor.opacity(0.25), lineWidth: 1.5)
        )
    }

    private var emojiRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(defaultEmojiRow, id: \.self) { emoji in
                    Button(action: { app.toggleEmoji(emoji) }) {
                        Text(emoji)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(app.selectedEmojis.contains(emoji) ? app.currentThemeColor.opacity(0.2) : Color.clear)
                            )
                    }
                }
             
            }
        }
    }

    private var saveButton: some View { EmptyView() }
}

#Preview {
    ReflectView().environmentObject(AppState())
}


