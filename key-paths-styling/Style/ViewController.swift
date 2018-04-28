//
//  ViewController.swift
//  Style
//
//  Created by Damian Malarczyk on 28/04/2018.
//  Copyright © 2018 dmcyk. All rights reserved.
//

import UIKit

class StateLabel: UILabel {

    enum State: Int {

        case idle
        case valid
        case invalid

        static let end: Int = State.invalid.rawValue + 1
    }

    var state: State = .idle
}

let baseStyle = DefaultStyleDefinition<UILabel>
    .styling(\UILabel.layer.borderColor, UIColor.blue.cgColor)
    .styling(\.layer.borderWidth, 2)

let styleDefinition = StyleDefinition<StateLabel, StateLabel.State>
    .styling(
        \.textColor,
        [
            .valid: .green,
            .invalid: .red
        ],
        default: .black
    ).styling(
        \.font,
        [
            .valid: .systemFont(ofSize: 15),
            .invalid: .systemFont(ofSize: 25)
        ],
        default: .systemFont(ofSize: 10)
    ).styling(
        \.textAlignment,
        [
            .valid: .left
        ],
        default: .center
    ).styling(
        \.backgroundColor,
        [
            .valid: .darkGray,
            .invalid: .black
        ],
        default: .lightGray
    )

class ViewController: UIViewController {

    @IBOutlet var stateLabel: StateLabel! {
        didSet {
            applyStyle()
        }
    }

    @IBAction func onStateChangeAction(_ sender: UIButton) {
        stateLabel.state = StateLabel.State(
            rawValue: (stateLabel.state.rawValue + 1) % StateLabel.State.end
        )!

        applyStyle()
    }

    func applyStyle() {
        baseStyle.apply(to: stateLabel)
        styleDefinition.apply(for: stateLabel.state, to: stateLabel)
    }
}
