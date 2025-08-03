#!/usr/bin/env swift

//
//  run_code_quality.swift
//  Simple script to run code quality analysis
//

import Foundation

// Import the analyzer (in a real scenario, this would be compiled as a framework)
let analyzerCode = """
// This would normally import the compiled framework
// For demo purposes, we'll create a simple analyzer here

struct SimpleCodeQualityAnalyzer {
    func analyzeProject(at path: String) {
        print("🔍 Analyzing Swift files in: \\(path)")
        
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: path) else {
            print("❌ Could not access directory: \\(path)")
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
        
        print("📊 Analysis Complete:")
        print("   Files analyzed: \\(swiftFiles.count)")
        print("   Issues found: \\(totalIssues)")
        
        if totalIssues == 0 {
            print("✅ No issues found! Your code meets quality standards.")
        } else {
            print("⚠️  Found \\(totalIssues) potential issues. Review the detailed output above.")
        }
    }
    
    private func analyzeFile(_ path: String) -> Int {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return 0
        }
        
        let lines = content.components(separatedBy: .newlines)
        var issues = 0
        
        print("\\n📄 Analyzing: \\(path)")
        
        for (lineNumber, line) in lines.enumerated() {
            // Force unwrapping detection
            if line.contains("!") && !line.contains("!=") && !line.contains("// !") {
                let forceUnwrapPattern = #"[a-zA-Z_][a-zA-Z0-9_]*!"#
                if line.range(of: forceUnwrapPattern, options: .regularExpression) != nil {
                    print("  ⚠️  Line \\(lineNumber + 1): Force unwrapping detected")
                    print("     Suggestion: Use optional binding or nil coalescing")
                    issues += 1
                }
            }
            
            // TODO/FIXME detection
            if line.contains("TODO") || line.contains("FIXME") {
                print("  💡 Line \\(lineNumber + 1): Unresolved TODO/FIXME comment")
                issues += 1
            }
            
            // Long line detection
            if line.count > 120 {
                print("  💡 Line \\(lineNumber + 1): Line too long (\\(line.count) characters)")
                issues += 1
            }
            
            // Potential retain cycle
            if line.contains("self.") && line.contains("{") && !line.contains("[weak self]") && !line.contains("[unowned self]") {
                print("  ⚠️  Line \\(lineNumber + 1): Potential retain cycle (missing weak/unowned self)")
                issues += 1
            }
            
            // Magic numbers
            let magicNumberPattern = #"\\b([0-9]{2,})\\b"#
            if line.range(of: magicNumberPattern, options: .regularExpression) != nil &&
               !line.contains("//") && !line.contains("let") && !line.contains("var") {
                print("  💡 Line \\(lineNumber + 1): Magic number detected")
                issues += 1
            }
        }
        
        return issues
    }
}

// Main execution
let args = CommandLine.arguments

if args.count < 2 {
    print(\"\"\"
    Moji Slicer Code Quality Analyzer (Demo)
    
    Usage: swift run_code_quality.swift <path>
    
    Example:
        swift run_code_quality.swift ./MyProject
        swift run_code_quality.swift ./ContentView.swift
    \"\"\")
    exit(1)
}

let path = args[1]
let analyzer = SimpleCodeQualityAnalyzer()

print("🚀 Moji Slicer Code Quality Analyzer")
print("=====================================")

if FileManager.default.fileExists(atPath: path) {
    analyzer.analyzeProject(at: path)
} else {
    print("❌ Path does not exist: \\(path)")
    exit(1)
}
"""

// For the actual script, we'll write this to a file
print("Creating code quality analysis script...")

let scriptContent = """
#!/usr/bin/env swift

import Foundation

struct SimpleCodeQualityAnalyzer {
    func analyzeProject(at path: String) {
        print("🔍 Analyzing Swift files in: \\(path)")
        
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: path) else {
            print("❌ Could not access directory: \\(path)")
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
        
        print("📊 Analysis Complete:")
        print("   Files analyzed: \\(swiftFiles.count)")
        print("   Issues found: \\(totalIssues)")
        
        if totalIssues == 0 {
            print("✅ No issues found! Your code meets quality standards.")
        } else {
            print("⚠️  Found \\(totalIssues) potential issues. Review the detailed output above.")
        }
    }
    
    private func analyzeFile(_ path: String) -> Int {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return 0
        }
        
        let lines = content.components(separatedBy: .newlines)
        var issues = 0
        
        print("\\n📄 Analyzing: \\(path)")
        
        for (lineNumber, line) in lines.enumerated() {
            // Force unwrapping detection
            if line.contains("!") && !line.contains("!=") && !line.contains("// !") {
                let forceUnwrapPattern = #"[a-zA-Z_][a-zA-Z0-9_]*!"#
                if line.range(of: forceUnwrapPattern, options: .regularExpression) != nil {
                    print("  ⚠️  Line \\(lineNumber + 1): Force unwrapping detected")
                    print("     Suggestion: Use optional binding or nil coalescing")
                    issues += 1
                }
            }
            
            // TODO/FIXME detection
            if line.contains("TODO") || line.contains("FIXME") {
                print("  💡 Line \\(lineNumber + 1): Unresolved TODO/FIXME comment")
                issues += 1
            }
            
            // Long line detection
            if line.count > 120 {
                print("  💡 Line \\(lineNumber + 1): Line too long (\\(line.count) characters)")
                issues += 1
            }
            
            // Potential retain cycle
            if line.contains("self.") && line.contains("{") && !line.contains("[weak self]") && !line.contains("[unowned self]") {
                print("  ⚠️  Line \\(lineNumber + 1): Potential retain cycle (missing weak/unowned self)")
                issues += 1
            }
            
            // Magic numbers
            let magicNumberPattern = #"\\\\b([0-9]{2,})\\\\b"#
            if line.range(of: magicNumberPattern, options: .regularExpression) != nil &&
               !line.contains("//") && !line.contains("let") && !line.contains("var") {
                print("  💡 Line \\(lineNumber + 1): Magic number detected")
                issues += 1
            }
        }
        
        return issues
    }
}

// Main execution
let args = CommandLine.arguments

if args.count < 2 {
    print(\"\"\"
    Moji Slicer Code Quality Analyzer (Demo)
    
    Usage: swift run_code_quality.swift <path>
    
    Example:
        swift run_code_quality.swift ./MyProject
        swift run_code_quality.swift ./ContentView.swift
    \"\"\")
    exit(1)
}

let path = args[1]
let analyzer = SimpleCodeQualityAnalyzer()

print("🚀 Moji Slicer Code Quality Analyzer")
print("=====================================")

if FileManager.default.fileExists(atPath: path) {
    analyzer.analyzeProject(at: path)
} else {
    print("❌ Path does not exist: \\(path)")
    exit(1)
}
"""

// Write the script
let scriptURL = URL(fileURLWithPath: "run_code_quality.swift")
try scriptContent.write(to: scriptURL, atomically: true, encoding: .utf8)

print("✅ Script created: run_code_quality.swift")
print("🚀 Run with: swift run_code_quality.swift <path>")