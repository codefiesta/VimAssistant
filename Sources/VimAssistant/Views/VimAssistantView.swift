//
//  SwiftUIView.swift
//  VimAssistant
//
//  Created by Kevin McKee on 2/5/25.
//

import SwiftUI
import VimKit

public struct VimAssistantView: View {

    var vim: Vim

    @State
    var speechRecognizer = SpeechRecognizer()

    @State
    var inputText: String = .empty

    private var gradient = Gradient(
        colors: [
            Color(.teal),
            Color(.purple)
        ]
    )

    /// Initializer.
    /// - Parameter enabled: flag indicating if the assistant should be enabled or not
    public init?(vim: Vim, _ enabled: Bool = false) {
        if !enabled { return nil }
        self.vim = vim
    }

    public var body: some View {

        HStack(spacing: 4) {
            Image(systemName: "apple.intelligence")
                .padding()
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    .angularGradient(
                        colors: [.red, .yellow, .green, .blue, .purple, .red],
                        center: .center, startAngle: .zero, endAngle: .degrees(360)
                    )
                )

                TextField(text: $inputText, prompt: Text("Type or tap microphone to use the AI assistant.")) {
                    Image(systemName: "microphone")
                }
                .textFieldStyle(.plain)

            microPhoneButton
                .padding()
        }
        .background(Color.black.opacity(0.65))
        .cornerRadius(8)
        .overlay{
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        gradient: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 4
                )
        }
        .padding(24)
    }

    var microPhoneButton: some View {
        Button(action: {

        }) {
            Image(systemName: "microphone")
        }
        .buttonStyle(.plain)

    }
}

#Preview {
    VimAssistantView(vim: .init(), true)
}
