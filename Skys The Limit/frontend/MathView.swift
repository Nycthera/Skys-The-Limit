//
//  Math.swift
//  Skys The Limit
//
//  Created by Chris  on 10/11/25.
//

import Foundation
import SwiftUI
import SwiftMath

struct MathView: UIViewRepresentable {
    var equation: String = ""
    var font: MathFont = .latinModernFont
    var textAlignment: MTTextAlignment = .center
    var fontSize: CGFloat = 30
    var labelMode: MTMathUILabelMode = .text
    var insets: MTEdgeInsets = MTEdgeInsets()

    func makeUIView(context: Context) -> MTMathUILabel {
        let view = MTMathUILabel()
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }

    func updateUIView(_ view: MTMathUILabel, context: Context) {
        view.latex = equation
        let font = MTFontManager().font(withName: font.rawValue, size: fontSize)
        view.font = font
        view.textAlignment = textAlignment
        view.labelMode = labelMode
        view.textColor = MTColor(Color.primary)
        view.contentInsets = insets
        view.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: MTMathUILabel, context: Context) -> CGSize? {
        // Enable line wrapping by passing proposed width to the label
        if let width = proposal.width, width.isFinite, width > 0 {
            let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            return size
        }
        return nil
    }
}

