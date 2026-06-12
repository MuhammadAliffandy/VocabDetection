//
//  PhoneticService.swift
//  Vocab
//
//  Converts English words to Indonesian-style phonetic spelling
//  so Indonesian learners know how to pronounce English words.
//  Example: "chair" → "ceir", "shoe" → "syu", "keyboard" → "kibord"
//

import Foundation

struct PhoneticService {

    // Apply in order — most specific patterns FIRST
    private static let rules: [(pattern: String, replacement: String)] = [
        // ── Trigraphs ──────────────────────────────────────────
        ("tch",  "c"),
        ("igh",  "ai"),
        ("dge",  "j"),
        ("sce",  "s"),
        ("sci",  "s"),
        ("sch",  "sk"),
        ("thr",  "dr"),
        ("squ",  "skw"),

        // ── Digraphs – consonants ──────────────────────────────
        ("ch",   "c"),
        ("sh",   "sy"),
        ("ph",   "f"),
        ("gh",   "f"),      // tough, rough
        ("ck",   "k"),
        ("kn",   "n"),
        ("wr",   "r"),
        ("wh",   "w"),
        ("ng",   "ng"),
        ("nk",   "ngk"),
        ("qu",   "kw"),
        ("mb",   "m"),      // silent b: lamb, comb
        ("mn",   "m"),      // autumn
        ("gn",   "n"),      // sign
        ("tion", "syen"),
        ("sion", "syen"),
        ("ture", "cer"),
        ("dge",  "j"),

        // ── Vowel digraphs / diphthongs ────────────────────────
        ("ea",   "i"),
        ("ee",   "i"),
        ("oo",   "u"),
        ("ou",   "au"),
        ("ow",   "au"),     // cow / how
        ("oi",   "oi"),
        ("oy",   "oi"),
        ("ai",   "ei"),
        ("ay",   "ei"),
        ("ie",   "ai"),
        ("oa",   "o"),
        ("ue",   "yu"),
        ("ew",   "yu"),
        ("aw",   "o"),
        ("au",   "o"),
        ("ui",   "ui"),

        // ── Single vowel contextual ────────────────────────────
        // (processed after digraphs so we only hit single letters)
        ("a",    "e"),
        ("e",    "e"),
        ("i",    "i"),
        ("o",    "o"),
        ("u",    "a"),
        ("y",    "i"),

        // ── Consonants that differ ─────────────────────────────
        ("c",    "k"),
        ("j",    "j"),
        ("v",    "v"),
        ("x",    "ks"),
        ("z",    "z"),
        ("q",    "k"),
    ]

    /// Convert one English word to Indonesian phonetic spelling.
    static func convert(_ word: String) -> String {
        var text = word.lowercased()
        // Remove trailing silent-e pattern: consonant + e at end of word
        // e.g. "bike" → "bik", "stone" → "ston"
        if text.count > 3,
           let last = text.last, last == "e",
           let secondLast = text.dropLast().last, !"aeiou".contains(secondLast) {
            text = String(text.dropLast())
        }

        var result = ""
        var idx = text.startIndex

        while idx < text.endIndex {
            var matched = false
            for rule in rules {
                let pat = rule.pattern
                guard text.distance(from: idx, to: text.endIndex) >= pat.count else { continue }
                let end = text.index(idx, offsetBy: pat.count)
                if text[idx..<end] == pat {
                    result += rule.replacement
                    idx = end
                    matched = true
                    break
                }
            }
            if !matched {
                result += String(text[idx])
                idx = text.index(after: idx)
            }
        }

        return result
    }

    /// Convert a multi-word phrase (e.g. "computer keyboard") word by word.
    static func phonetic(for phrase: String) -> String {
        let words = phrase
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        return words.map { convert($0) }.joined(separator: " ")
    }
}
