//
//  AppSentenceDropArea.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 20/06/26.
//

import SwiftUI

struct DropZoneFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { current, _ in current }
    }
}

struct AppSentenceDropArea: View {
    var roundIndex: Int
    var sentence: String
    var vocabWord: String
    var missingWordMeaning: String
    var meaning: String
    var droppedWord: String?
    var isDropped: Bool
    var isCorrect: Bool
    var vocabDictionary: [String: String]
    var onRemove: () -> Void
    
    @State private var activeWordIndex: Int? = nil
    @State private var isDropZonePressed: Bool = false
    
    private enum SentenceElement {
        case word(String)
        case dropZone
    }
    
    private var sentenceWords: [SentenceElement] {
        var elements: [SentenceElement] = []
        
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: vocabWord))\\b"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: sentence, options: [], range: NSRange(location: 0, length: sentence.utf16.count)),
           let range = Range(match.range, in: sentence) {
            
            let before = String(sentence[..<range.lowerBound])
            let after = String(sentence[range.upperBound...])
            
            elements.append(contentsOf: before.split(separator: " ").map { SentenceElement.word(String($0)) })
            elements.append(.dropZone)
            elements.append(contentsOf: after.split(separator: " ").map { SentenceElement.word(String($0)) })
        } else {
            elements = sentence.split(separator: " ").map { SentenceElement.word(String($0)) }
            elements.append(.dropZone)
        }
        return elements
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Sentence with blank using AppFlowLayout — centered
            HStack {
                Spacer(minLength: 0)
                AppFlowLayout(spacing: 8) {
                    ForEach(Array(sentenceWords.enumerated()), id: \.offset) { index, element in
                        switch element {
                        case .word(let wordText):
                            let cleanWord = wordText.trimmingCharacters(in: .punctuationCharacters).lowercased()
                            let tooltipMeaning = vocabDictionary[cleanWord]
                            
                            AppWordTip(
                                text: wordText,
                                tooltipText: tooltipMeaning ?? "",
                                textStyle: .appHeadlinev2,
                                textColor: .primary,
                                isPressed: activeWordIndex == index,
                                isVocab: tooltipMeaning != nil
                            )
                            .zIndex(activeWordIndex == index ? 1 : 0)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if tooltipMeaning != nil {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        activeWordIndex = (activeWordIndex == index) ? nil : index
                                    }
                                }
                            }
                        case .dropZone:
                            dropZone
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.shapeRadius)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: 4)
        )
        .zIndex(activeWordIndex != nil ? 100 : 0)
    }
    
    private var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.vocabShapeRadius)
                .stroke(
                    isDropped
                        ? (isCorrect ? Color.green : Color.red)
                        : Color.brandColorPrimaryTeal,
                    style: StrokeStyle(lineWidth: 1.5, dash: isDropped ? [] : [5, 4])
                )
                .background(Color.clear)

            if isDropped, let text = droppedWord {
                HStack(spacing: 6) {
                    Text(text)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(isCorrect ? .green : .red)
                    if !isCorrect {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
                .padding(.horizontal, 16)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "hand.point.up.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.brandColorPrimaryTeal)
                    Text("tarik kesini")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.brandColorPrimaryTeal)
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(height: 40)
        .fixedSize(horizontal: true, vertical: true)
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: DropZoneFramePreferenceKey.self,
                    value: [roundIndex: geo.frame(in: .named("GameSpace"))]
                )
            }
        )
        .appTooltip(missingWordMeaning, isVisible: isDropZonePressed, y: -55)
        .onTapGesture {
            if isDropped && !isCorrect {
                onRemove()
            } else if !isDropped {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isDropZonePressed.toggle()
                }
            }
        }
        .onChange(of: isDropped) { _, newValue in
            if newValue {
                withAnimation(.spring()) {
                    isDropZonePressed = false
                }
            }
        }
        .onChange(of: activeWordIndex) { _, _ in
            withAnimation(.spring()) {
                isDropZonePressed = false
            }
        }
        .onChange(of: isDropZonePressed) { _, newValue in
            if newValue {
                withAnimation(.spring()) {
                    activeWordIndex = nil
                }
            }
        }
    }
}


