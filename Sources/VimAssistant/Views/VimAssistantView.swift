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

    @State
    private var animateGradient = false

    private var displayResponse: Bool {
        speechRecognizer.transcript.isNotEmpty
    }

    private var animation: Animation {
        if animateGradient {
            .easeOut(duration: 2).repeatForever()
        } else {
            .easeOut(duration: 2)
        }
    }

    /// Initializer.
    /// - Parameter enabled: flag indicating if the assistant should be enabled or not
    public init?(vim: Vim, _ enabled: Bool = false) {
        if !enabled { return nil }
        self.vim = vim
    }

    public var body: some View {
        VStack {
            inputView
            responseView
        }
    }

    var inputView: some View {

        HStack {
            Image(systemName: "apple.intelligence")
                .padding()
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    .angularGradient(
                        colors: [.red, .yellow, .green, .blue, .purple, .red],
                        center: .center, startAngle: .zero, endAngle: .degrees(360)
                    )
                )
                .font(.title)

            TextField(text: $inputText, prompt: Text("Type or tap microphone to use the AI assistant.")) {
                Image(systemName: "microphone")
            }
                .textFieldStyle(.plain)

            microphoneButton
                .padding()
        }
        .background(Color.black.opacity(0.65))
        .cornerRadius(8)
        .overlay {
            overlayView
        }
        .padding([.leading, .top, .trailing])
    }


    // The stroke gradient
    private var gradient: Gradient {
        .init(colors: animateGradient ? [.red, .orange] : [.teal, .purple])
    }

    // The gradient style
    private var gradientStyle: some ShapeStyle {
        LinearGradient(
            gradient: gradient,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // The overlay view of the text box that animates the stroke
    private var overlayView: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(gradientStyle, lineWidth: 4)
            .hueRotation(.degrees(animateGradient ? 45 : 0))
            .animation(animation, value: animateGradient)
    }

    private var microphoneButton: some View {
        Button(action: {
            animateGradient.toggle()
            speechRecognizer.run.toggle()
        }) {
            Image(systemName: "microphone")
                .font(.title)
        }
        .buttonStyle(.plain)
    }

    var responseView: some View {

        VStack(spacing: 4) {
            if displayResponse {
                Text(speechRecognizer.transcript)
                    .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .padding()
                HStack {
                    Spacer()
                    goodResponseButton
                    badResponseButton
                }
                .padding([.bottom, .trailing])
            }
        }
        .background(Color.black.opacity(0.65))
        .cornerRadius(8)
        .padding([.leading, .bottom, .trailing])

    }

    var goodResponseButton: some View {
        Button(action: {
            // TODO: Report a good response
        }) {
            Image(systemName: "hand.thumbsup")
                .buttonStyle(.plain)
        }
    }

    var badResponseButton: some View {
        Button(action: {
            // TODO: Report a bad response
        }) {
            Image(systemName: "hand.thumbsdown")
        }
    }
}

#Preview {
    VimAssistantView(vim: .init(), true)
}
