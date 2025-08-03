#!/usr/bin/env swift

import Foundation

struct SimpleCodeQualityAnalyzer {
    func analyze(at path: String) {
        var isDirectory: ObjCBool = false
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
            print("❌ Path does not exist: \(path)")
            return
        }
        
        if isDirectory.boolValue {
            analyzeDirectory(at: path)
        } else if path.hasSuffix(".swift") {
            _ = analyzeFile(path)
            print("📊 Analysis Complete: Single file analyzed")
        } else {
            print("❌ Not a Swift file or directory: \(path)")
        }
    }
    
    func analyzeDirectory(at path: String) {
        print("🔍 Analyzing Swift files in directory: \(path)")
        
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: path) else {
            print("❌ Could not access directory: \(path)")
            return
        }
        
        var swiftFiles: [String] = []
        var totalIssues = 0
        
        while let file = enumerator.nextObject() as? String {
            if file.hasSuffix(".swift") && !file.contains("/.build/") && !file.contains("/DerivedData/") {
                swiftFiles.append(file)
                let fullPath = (path as NSString).appendingPathComponent(file)
                let issues = analyzeFile(fullPath)
                totalIssues += issues
            }
        }
        
        print("\n📊 Analysis Complete:")
        print("   Files analyzed: \(swiftFiles.count)")
        print("   Issues found: \(totalIssues)")
        
        if totalIssues == 0 {
            print("✅ No issues found! Your code meets quality standards.")
        } else {
            print("⚠️  Found \(totalIssues) potential issues. Review the detailed output above.")
        }
    }
    
    private func analyzeFile(_ path: String) -> Int {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("❌ Could not read file: \(path)")
            return 0
        }
        
        let lines = content.components(separatedBy: .newlines)
        var issues = 0
        let fileName = (path as NSString).lastPathComponent
        
        print("\n📄 Analyzing: \(fileName)")
        
        for (lineNumber, line) in lines.enumerated() {
            let lineIndex = lineNumber + 1
            
            // Force unwrapping detection
            if line.contains("!") && !line.contains("!=") && !line.contains("// !") && !line.contains("\"") {
                let forceUnwrapPattern = #"[a-zA-Z_][a-zA-Z0-9_]*\s*!"#
                if line.range(of: forceUnwrapPattern, options: .regularExpression) != nil {
                    print("  ⚠️  Line \(lineIndex): Force unwrapping detected")
                    print("     Code: \(line.trimmingCharacters(in: .whitespaces))")
                    print("     Suggestion: Use optional binding or nil coalescing")
                    issues += 1
                }
            }
            
            // TODO/FIXME detection
            if line.contains("TODO") || line.contains("FIXME") {
                print("  💡 Line \(lineIndex): Unresolved TODO/FIXME comment")
                print("     Code: \(line.trimmingCharacters(in: .whitespaces))")
                issues += 1
            }
            
            // Long line detection (>120 characters)
            if line.count > 120 {
                print("  💡 Line \(lineIndex): Line too long (\(line.count) characters)")
                print("     Suggestion: Break into multiple lines")
                issues += 1
            }
            
            // Potential retain cycle
            if line.contains("self.") && (line.contains("{") || line.contains("closure")) && 
               !line.contains("[weak self]") && !line.contains("[unowned self]") && 
               !line.contains("//") {
                print("  ⚠️  Line \(lineIndex): Potential retain cycle (missing weak/unowned self)")
                print("     Code: \(line.trimmingCharacters(in: .whitespaces))")
                issues += 1
            }
            
            // Magic numbers (numbers > 10)
            let magicNumberPattern = #"[^a-zA-Z0-9_]([1-9][0-9]{2,})[^a-zA-Z0-9_]"#
            if line.range(of: magicNumberPattern, options: .regularExpression) != nil &&
               !line.contains("//") && !line.contains("let") && !line.contains("var") && !line.contains("=") {
                print("  💡 Line \(lineIndex): Magic number detected")
                print("     Code: \(line.trimmingCharacters(in: .whitespaces))")
                print("     Suggestion: Extract to named constant")
                issues += 1
            }
            
            // Missing accessibility labels for UI elements
            if (line.contains("Button(") || line.contains("Image(")) && 
               !line.contains("accessibility") && !line.contains("//") {
                print("  💡 Line \(lineIndex): UI element missing accessibility label")
                print("     Code: \(line.trimmingCharacters(in: .whitespaces))")
                print("     Suggestion: Add .accessibilityLabel() modifier")
                issues += 1
            }
            
            // Hardcoded strings that might need localization
            if line.contains("Text(\"") && !line.contains("systemImage") && !line.contains("//") && 
               !line.contains("NSLocalizedString") {
                print("  💡 Line \(lineIndex): Hardcoded text (consider localization)")
                print("     Code: \(line.trimmingCharacters(in: .whitespaces))")
                issues += 1
            }
        }
        
        if issues == 0 {
            print("  ✅ No issues found in this file")
        }
        
        return issues
    }
}

// Main execution
let args = CommandLine.arguments

if args.count < 2 {
    print("""
    Moji Slicer Code Quality Analyzer (Demo)
    
    Usage: swift run_code_quality.swift <path>
    
    Examples:
        swift run_code_quality.swift ./MyProject
        swift run_code_quality.swift ./ContentView.swift
        
    Analyzes Swift code for:
    • Force unwrapping (!)
    • TODO/FIXME comments  
    • Long lines (>120 characters)
    • Potential retain cycles
    • Magic numbers
    • Missing accessibility labels
    • Hardcoded strings
    """)
    exit(1)
}

let path = args[1]
let analyzer = SimpleCodeQualityAnalyzer()

print("🚀 Moji Slicer Code Quality Analyzer")
print("=====================================")

analyzer.analyze(at: path)