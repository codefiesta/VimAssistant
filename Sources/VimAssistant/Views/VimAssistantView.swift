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

    /// Initializer.
    /// - Parameter enabled: flag indicating if the assistant should be enabled or not
    init?(vim: Vim, _ enabled: Bool = false) {
        if !enabled { return nil }
        self.vim = vim
    }

    public var body: some View {

        HStack {
            Image(systemName: "apple.intelligence")
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    .angularGradient(
                        colors: [.red, .yellow, .green, .blue, .purple, .red],
                        center: .center, startAngle: .zero, endAngle: .degrees(360)
                    )
                )

            TextField(text: $inputText, prompt: Text("Type here to use the assistant.")) {
                Image(systemName: "microphone")

            }
            .textFieldStyle(.plain)
            microPhoneButton
        }
        .padding()
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
