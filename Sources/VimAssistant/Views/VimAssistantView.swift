//
//  SwiftUIView.swift
//  VimAssistant
//
//  Created by Kevin McKee on 2/5/25.
//

import SwiftUI
import VimKit

public struct VimAssistantView: View {

    @State
    var inputText: String = ""

    /// Initializer.
    /// - Parameter enabled: flag indicating if the assistant should be enabled or not
    init?(_ enabled: Bool = false) {
        if !enabled { return nil }
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
    VimAssistantView(true)
}
