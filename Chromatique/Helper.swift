//
//  Helper.swift
//  Chromatique
//
//  Created by Martin Pluisch on 23.05.24.
//

import SwiftUI

struct Pressable: ViewModifier {
    let action: (PressEvent) -> Void

    func body(content: Content) -> some View {
        content
            .background(PressHandler(action: action))
    }
}

extension View {
    func pressable(action: @escaping (PressEvent) -> Void) -> some View {
        self.modifier(Pressable(action: action))
    }
}

struct PressHandler: UIViewRepresentable {
    let action: (PressEvent) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap))
        view.addGestureRecognizer(tapRecognizer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject {
        let action: (PressEvent) -> Void

        init(action: @escaping (PressEvent) -> Void) {
            self.action = action
        }

        @objc func handleTap() {
            action(.select)
        }
    }
}

enum PressEvent {
    case select
}

struct IdleTimerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
}

extension View {
    func disableIdleTimer() -> some View {
        self.modifier(IdleTimerModifier())
    }
}
