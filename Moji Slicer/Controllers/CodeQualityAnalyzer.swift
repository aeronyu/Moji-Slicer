//
//  CodeQualityAnalyzer.swift
//  Moji Slicer
//
//  Code Quality Agent for macOS Swift applications
//  Specializes in reviewing Swift code for maintainability, correctness, performance, safety, and user experience
//

import Foundation
import SwiftUI

/// Severity levels for code quality issues
enum CodeQualitySeverity: String, CaseIterable {
    case critical = "Critical"
    case warning = "Warning"
    case suggestion = "Suggestion"
    
    var emoji: String {
        switch self {
        case .critical: return "🚨"
        case .warning: return "⚠️"
        case .suggestion: return "💡"
        }
    }
}

/// Categories of code quality analysis
enum CodeQualityCategory: String, CaseIterable {
    case correctnessAndSafety = "Correctness & Safety"
    case styleAndBestPractices = "Style & Best Practices"
    case architectureAndModularity = "Architecture & Modularity"
    case performance = "Performance"
    case securityAndPrivacy = "Security & Privacy"
    case accessibilityAndHIG = "Accessibility & HIG"
    case testing = "Testing"
    case documentation = "Documentation"
}

/// A code quality issue found during analysis
struct CodeQualityIssue {
    let category: CodeQualityCategory
    let severity: CodeQualitySeverity
    let title: String
    let description: String
    let file: String
    let line: Int?
    let column: Int?
    let suggestion: String?
    let codeExample: String?
    
    var formattedLocation: String {
        if let line = line, let column = column {
            return "\(file):\(line):\(column)"
        } else if let line = line {
            return "\(file):\(line)"
        } else {
            return file
        }
    }
}

/// Results of code quality analysis
struct CodeQualityReport {
    let files: [String]
    let issues: [CodeQualityIssue]
    let analysisDate: Date
    let executionTime: TimeInterval
    
    var criticalCount: Int { issues.filter { $0.severity == .critical }.count }
    var warningCount: Int { issues.filter { $0.severity == .warning }.count }
    var suggestionCount: Int { issues.filter { $0.severity == .suggestion }.count }
    
    var summary: String {
        """
        Code Quality Analysis Summary
        ============================
        Files analyzed: \(files.count)
        Issues found: \(issues.count)
        - 🚨 Critical: \(criticalCount)
        - ⚠️ Warnings: \(warningCount)
        - 💡 Suggestions: \(suggestionCount)
        
        Analysis completed in \(String(format: "%.2f", executionTime))s
        """
    }
}

/// Main Code Quality Analyzer for Swift/SwiftUI applications
@Observable
class CodeQualityAnalyzer {
    private var issues: [CodeQualityIssue] = []
    private var currentFile: String = ""
    
    /// Analyze a Swift file for code quality issues
    func analyzeFile(at path: String) throws -> [CodeQualityIssue] {
        guard FileManager.default.fileExists(atPath: path) else {
            throw CodeQualityError.fileNotFound(path)
        }
        
        let content = try String(contentsOfFile: path, encoding: .utf8)
        return analyzeCode(content, fileName: path)
    }
    
    /// Analyze Swift code content
    func analyzeCode(_ code: String, fileName: String) -> [CodeQualityIssue] {
        issues = []
        currentFile = fileName
        
        let lines = code.components(separatedBy: .newlines)
        
        // Run all analysis categories
        analyzeCorrectnessAndSafety(lines)
        analyzeStyleAndBestPractices(lines)
        analyzeArchitectureAndModularity(lines)
        analyzePerformance(lines)
        analyzeSecurityAndPrivacy(lines)
        analyzeAccessibilityAndHIG(lines)
        analyzeTesting(lines)
        analyzeDocumentation(lines)
        
        return issues
    }
    
    /// Analyze multiple files and generate a comprehensive report
    func analyzeProject(at projectPath: String) throws -> CodeQualityReport {
        let startTime = Date()
        var allIssues: [CodeQualityIssue] = []
        var analyzedFiles: [String] = []
        
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: projectPath)
        
        while let file = enumerator?.nextObject() as? String {
            if file.hasSuffix(".swift") && !file.contains("/.build/") && !file.contains("/DerivedData/") {
                let fullPath = (projectPath as NSString).appendingPathComponent(file)
                do {
                    let fileIssues = try analyzeFile(at: fullPath)
                    allIssues.append(contentsOf: fileIssues)
                    analyzedFiles.append(file)
                } catch {
                    print("Warning: Could not analyze file \(file): \(error)")
                }
            }
        }
        
        let executionTime = Date().timeIntervalSince(startTime)
        
        return CodeQualityReport(
            files: analyzedFiles,
            issues: allIssues,
            analysisDate: Date(),
            executionTime: executionTime
        )
    }
}

// MARK: - Analysis Categories Implementation

extension CodeQualityAnalyzer {
    
    /// 1. Correctness & Safety Analysis
    private func analyzeCorrectnessAndSafety(_ lines: [String]) {
        for (lineNumber, line) in lines.enumerated() {
            let lineIndex = lineNumber + 1
            
            // Force unwrapping detection
            if line.contains("!") && !line.contains("!=") && !line.contains("// !") {
                let forceUnwrapPattern = #"[a-zA-Z_][a-zA-Z0-9_]*!"#
                if line.range(of: forceUnwrapPattern, options: .regularExpression) != nil {
                    addIssue(
                        category: .correctnessAndSafety,
                        severity: .warning,
                        title: "Force Unwrapping Detected",
                        description: "Force unwrapping can cause crashes. Consider using optional binding or nil coalescing.",
                        line: lineIndex,
                        suggestion: "Use 'if let', 'guard let', or '??' operator instead",
                        codeExample: """
                        // Instead of: someOptional!
                        // Use: if let value = someOptional { ... }
                        // Or: someOptional ?? defaultValue
                        """
                    )
                }
            }
            
            // Retain cycle detection (simplified)
            if line.contains("self.") && (line.contains("{") || line.contains("closure")) {
                if !line.contains("[weak self]") && !line.contains("[unowned self]") {
                    addIssue(
                        category: .correctnessAndSafety,
                        severity: .warning,
                        title: "Potential Retain Cycle",
                        description: "Using 'self' in closures without weak/unowned reference can cause memory leaks.",
                        line: lineIndex,
                        suggestion: "Use [weak self] or [unowned self] in closure capture list",
                        codeExample: """
                        // Use: { [weak self] in
                        //   guard let self = self else { return }
                        //   self.doSomething()
                        // }
                        """
                    )
                }
            }
            
            // MainActor violations
            if line.contains("@Published") || line.contains("@State") || line.contains("@Observable") {
                if !currentFile.contains("View") && !line.contains("@MainActor") {
                    addIssue(
                        category: .correctnessAndSafety,
                        severity: .suggestion,
                        title: "UI State Without MainActor",
                        description: "UI-related state should be confined to the main actor.",
                        line: lineIndex,
                        suggestion: "Add @MainActor to class or property",
                        codeExample: "@MainActor class ViewModel: ObservableObject { ... }"
                    )
                }
            }
            
            // Array bounds checking
            if line.contains("[") && !line.contains("//") {
                let arrayAccessPattern = #"\[[0-9]+\]"#
                if line.range(of: arrayAccessPattern, options: .regularExpression) != nil {
                    addIssue(
                        category: .correctnessAndSafety,
                        severity: .suggestion,
                        title: "Direct Array Index Access",
                        description: "Direct array access can cause index out of bounds crashes.",
                        line: lineIndex,
                        suggestion: "Use safe array access or bounds checking",
                        codeExample: """
                        // Instead of: array[index]
                        // Use: array.indices.contains(index) ? array[index] : nil
                        // Or: array.first where { ... }
                        """
                    )
                }
            }
        }
    }
    
    /// 2. Style & Best Practices Analysis
    private func analyzeStyleAndBestPractices(_ lines: [String]) {
        for (lineNumber, line) in lines.enumerated() {
            let lineIndex = lineNumber + 1
            
            // Naming conventions
            if line.contains("func ") {
                let funcPattern = #"func\s+([A-Z][a-zA-Z0-9_]*)"#
                if line.range(of: funcPattern, options: .regularExpression) != nil {
                    addIssue(
                        category: .styleAndBestPractices,
                        severity: .suggestion,
                        title: "Function Naming Convention",
                        description: "Function names should start with lowercase letter (camelCase).",
                        line: lineIndex,
                        suggestion: "Use camelCase for function names",
                        codeExample: "func calculateTotalAmount() { ... }"
                    )
                }
            }
            
            // Long lines
            if line.count > 120 {
                addIssue(
                    category: .styleAndBestPractices,
                    severity: .suggestion,
                    title: "Line Too Long",
                    description: "Lines should be shorter than 120 characters for better readability.",
                    line: lineIndex,
                    suggestion: "Break long lines into multiple lines or extract variables",
                    codeExample: nil
                )
            }
            
            // Magic numbers
            let magicNumberPattern = #"\b([0-9]{2,})\b"#
            if line.range(of: magicNumberPattern, options: .regularExpression) != nil &&
               !line.contains("//") && !line.contains("let") && !line.contains("var") {
                addIssue(
                    category: .styleAndBestPractices,
                    severity: .suggestion,
                    title: "Magic Number Detected",
                    description: "Consider extracting magic numbers into named constants.",
                    line: lineIndex,
                    suggestion: "Define constants for magic numbers",
                    codeExample: """
                    // Instead of: view.frame.width = 320
                    // Use: private let defaultWidth: CGFloat = 320
                    """
                )
            }
            
            // TODO/FIXME comments
            if line.contains("TODO") || line.contains("FIXME") {
                addIssue(
                    category: .styleAndBestPractices,
                    severity: .warning,
                    title: "Unresolved TODO/FIXME",
                    description: "TODO or FIXME comments indicate incomplete or problematic code.",
                    line: lineIndex,
                    suggestion: "Resolve the TODO/FIXME or create a proper issue",
                    codeExample: nil
                )
            }
        }
    }
    
    /// 3. Architecture & Modularity Analysis  
    private func analyzeArchitectureAndModularity(_ lines: [String]) {
        var hasPrivateMembers = false
        var classSize = 0
        var functionSize = 0
        var inFunction = false
        
        for (lineNumber, line) in lines.enumerated() {
            let lineIndex = lineNumber + 1
            
            // Check for private access control
            if line.contains("private ") || line.contains("fileprivate ") {
                hasPrivateMembers = true
            }
            
            // Count class/struct size
            if line.contains("class ") || line.contains("struct ") {
                classSize = 0
            } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                classSize += 1
            }
            
            // Function complexity
            if line.contains("func ") {
                inFunction = true
                functionSize = 0
            } else if inFunction && line.contains("}") && functionSize > 0 {
                if functionSize > 20 {
                    addIssue(
                        category: .architectureAndModularity,
                        severity: .warning,
                        title: "Large Function",
                        description: "Function is too large and complex. Consider breaking it down.",
                        line: lineIndex,
                        suggestion: "Extract smaller functions or use protocol composition",
                        codeExample: nil
                    )
                }
                inFunction = false
            } else if inFunction {
                functionSize += 1
            }
            
            // Singleton pattern detection
            if line.contains("static let shared") || line.contains("static var shared") {
                addIssue(
                    category: .architectureAndModularity,
                    severity: .suggestion,
                    title: "Singleton Pattern Detected",
                    description: "Singletons can make testing difficult. Consider dependency injection.",
                    line: lineIndex,
                    suggestion: "Use dependency injection instead of singletons",
                    codeExample: """
                    // Instead of: MyService.shared.doSomething()
                    // Use: init(service: MyServiceProtocol)
                    """
                )
            }
        }
        
        // Check for large classes
        if classSize > 200 {
            addIssue(
                category: .architectureAndModularity,
                severity: .warning,
                title: "Large Class/Struct",
                description: "Class/struct is too large. Consider breaking it into smaller components.",
                line: nil,
                suggestion: "Follow Single Responsibility Principle",
                codeExample: nil
            )
        }
        
        // Check for missing access control
        if !hasPrivateMembers && lines.count > 20 {
            addIssue(
                category: .architectureAndModularity,
                severity: .suggestion,
                title: "Missing Private Access Control",
                description: "Consider using private access control to encapsulate implementation details.",
                line: nil,
                suggestion: "Mark internal methods and properties as private",
                codeExample: nil
            )
        }
    }
    
    /// 4. Performance Analysis
    private func analyzePerformance(_ lines: [String]) {
        for (lineNumber, line) in lines.enumerated() {
            let lineIndex = lineNumber + 1
            
            // Expensive string operations
            if line.contains("+") && (line.contains("String") || line.contains("\"")) {
                addIssue(
                    category: .performance,
                    severity: .suggestion,
                    title: "String Concatenation in Loop",
                    description: "String concatenation in loops is inefficient. Use StringBuilder or string interpolation.",
                    line: lineIndex,
                    suggestion: "Use string interpolation or StringBuilder",
                    codeExample: """
                    // Instead of: result = result + item
                    // Use: result = "\\(result)\\(item)"
                    // Or: StringBuilder pattern
                    """
                )
            }
            
            // Synchronous I/O on main thread
            if (line.contains("NSImage(contentsOf:)") || line.contains("Data(contentsOf:)")) &&
               !line.contains("async") && !line.contains("Task") {
                addIssue(
                    category: .performance,
                    severity: .warning,
                    title: "Synchronous I/O Operation",
                    description: "Synchronous I/O operations can block the main thread.",
                    line: lineIndex,
                    suggestion: "Use async/await or background queues",
                    codeExample: """
                    // Use: Task {
                    //   let image = await loadImageAsync(from: url)
                    // }
                    """
                )
            }
            
            // Inefficient collection operations
            if line.contains("for ") && line.contains("append") {
                addIssue(
                    category: .performance,
                    severity: .suggestion,
                    title: "Inefficient Collection Building",
                    description: "Building collections in loops can be inefficient.",
                    line: lineIndex,
                    suggestion: "Use map, filter, or compactMap instead",
                    codeExample: """
                    // Instead of: for item in items { results.append(transform(item)) }
                    // Use: let results = items.map(transform)
                    """
                )
            }
            
            // Large image processing
            if line.contains("tiffRepresentation") || line.contains("pngData") {
                addIssue(
                    category: .performance,
                    severity: .suggestion,
                    title: "Image Data Processing",
                    description: "Image data processing should be done on background queues.",
                    line: lineIndex,
                    suggestion: "Move image processing to background queue",
                    codeExample: nil
                )
            }
        }
    }
    
    /// 5. Security & Privacy Analysis
    private func analyzeSecurityAndPrivacy(_ lines: [String]) {
        for (lineNumber, line) in lines.enumerated() {
            let lineIndex = lineNumber + 1
            
            // Hardcoded secrets
            if line.contains("password") || line.contains("api_key") || line.contains("secret") {
                if line.contains("=") && !line.contains("//") {
                    addIssue(
                        category: .securityAndPrivacy,
                        severity: .critical,
                        title: "Potential Hardcoded Secret",
                        description: "Secrets should not be hardcoded. Use Keychain or environment variables.",
                        line: lineIndex,
                        suggestion: "Store secrets in Keychain Services",
                        codeExample: """
                        // Use Keychain Services for sensitive data
                        SecItemAdd(query as CFDictionary, nil)
                        """
                    )
                }
            }
            
            // User data logging
            if line.contains("print(") && (line.contains("user") || line.contains("email") || line.contains("phone")) {
                addIssue(
                    category: .securityAndPrivacy,
                    severity: .warning,
                    title: "Potential User Data Logging",
                    description: "Avoid logging user data to console.",
                    line: lineIndex,
                    suggestion: "Remove or sanitize user data from logs",
                    codeExample: nil
                )
            }
            
            // File permissions
            if line.contains("FileManager") && line.contains("write") {
                addIssue(
                    category: .securityAndPrivacy,
                    severity: .suggestion,
                    title: "File Write Operation",
                    description: "Ensure proper sandboxing and file permissions for file operations.",
                    line: lineIndex,
                    suggestion: "Verify sandboxing compliance and user consent",
                    codeExample: nil
                )
            }
        }
    }
    
    /// 6. Accessibility & HIG Analysis
    private func analyzeAccessibilityAndHIG(_ lines: [String]) {
        for (lineNumber, line) in lines.enumerated() {
            let lineIndex = lineNumber + 1
            
            // Missing accessibility labels
            if line.contains("Button") || line.contains("Image") {
                if !line.contains("accessibility") && !line.contains("label") {
                    addIssue(
                        category: .accessibilityAndHIG,
                        severity: .warning,
                        title: "Missing Accessibility Label",
                        description: "Interactive elements should have accessibility labels.",
                        line: lineIndex,
                        suggestion: "Add .accessibilityLabel() modifier",
                        codeExample: """
                        Button("Save") { ... }
                            .accessibilityLabel("Save document")
                        """
                    )
                }
            }
            
            // Fixed font sizes
            if line.contains(".font(.system(size:") {
                addIssue(
                    category: .accessibilityAndHIG,
                    severity: .suggestion,
                    title: "Fixed Font Size",
                    description: "Use dynamic type for better accessibility.",
                    line: lineIndex,
                    suggestion: "Use .font(.title), .font(.body), etc. for dynamic type",
                    codeExample: """
                    // Instead of: .font(.system(size: 16))
                    // Use: .font(.body) or .font(.title2)
                    """
                )
            }
            
            // Color-only indicators
            if line.contains(".foregroundColor(.red)") || line.contains(".foregroundColor(.green)") {
                addIssue(
                    category: .accessibilityAndHIG,
                    severity: .suggestion,
                    title: "Color-Only Indicator",
                    description: "Don't rely solely on color to convey information.",
                    line: lineIndex,
                    suggestion: "Add icons, text, or other visual indicators",
                    codeExample: nil
                )
            }
        }
    }
    
    /// 7. Testing Analysis
    private func analyzeTesting(_ lines: [String]) {
        let hasTests = currentFile.contains("Test")
        
        if !hasTests {
            // Check for testable code patterns
            var hasPublicAPI = false
            var hasComplexLogic = false
            
            for (lineNumber, line) in lines.enumerated() {
                let lineIndex = lineNumber + 1
                
                if line.contains("public ") || line.contains("internal ") {
                    hasPublicAPI = true
                }
                
                if line.contains("if ") || line.contains("switch ") || line.contains("guard ") {
                    hasComplexLogic = true
                }
                
                // Untestable patterns
                if line.contains("Date()") && !line.contains("//") {
                    addIssue(
                        category: .testing,
                        severity: .suggestion,
                        title: "Non-Deterministic Date Creation",
                        description: "Direct Date() calls make testing difficult.",
                        line: lineIndex,
                        suggestion: "Inject date provider for testability",
                        codeExample: """
                        protocol DateProvider {
                            var now: Date { get }
                        }
                        """
                    )
                }
                
                if line.contains("UUID()") && !line.contains("//") {
                    addIssue(
                        category: .testing,
                        severity: .suggestion,
                        title: "Non-Deterministic UUID Creation",
                        description: "Direct UUID() calls make testing difficult.",
                        line: lineIndex,
                        suggestion: "Inject UUID provider for testability",
                        codeExample: nil
                    )
                }
            }
            
            if hasPublicAPI && hasComplexLogic {
                addIssue(
                    category: .testing,
                    severity: .warning,
                    title: "Missing Test Coverage",
                    description: "Complex public API should have corresponding tests.",
                    line: nil,
                    suggestion: "Add unit tests for public methods with complex logic",
                    codeExample: nil
                )
            }
        }
    }
    
    /// 8. Documentation Analysis
    private func analyzeDocumentation(_ lines: [String]) {
        var hasDocComment = false
        
        for (lineNumber, line) in lines.enumerated() {
            let lineIndex = lineNumber + 1
            
            // Check for documentation comments
            if line.contains("///") || line.contains("/**") {
                hasDocComment = true
            }
            
            // Public APIs without documentation
            if line.contains("public ") && (line.contains("func ") || line.contains("class ") || line.contains("struct ")) {
                if !hasDocComment {
                    addIssue(
                        category: .documentation,
                        severity: .suggestion,
                        title: "Missing Public API Documentation",
                        description: "Public APIs should have documentation comments.",
                        line: lineIndex,
                        suggestion: "Add /// documentation comments",
                        codeExample: """
                        /// Brief description of the function
                        /// - Parameter value: Description of parameter
                        /// - Returns: Description of return value
                        public func someFunction(value: String) -> Bool { ... }
                        """
                    )
                }
            }
            
            // Reset doc comment flag for next declaration
            if line.contains("func ") || line.contains("class ") || line.contains("struct ") {
                hasDocComment = false
            }
        }
    }
    
    /// Helper method to add issues
    private func addIssue(
        category: CodeQualityCategory,
        severity: CodeQualitySeverity,
        title: String,
        description: String,
        line: Int?,
        column: Int? = nil,
        suggestion: String? = nil,
        codeExample: String? = nil
    ) {
        let issue = CodeQualityIssue(
            category: category,
            severity: severity,
            title: title,
            description: description,
            file: currentFile,
            line: line,
            column: column,
            suggestion: suggestion,
            codeExample: codeExample
        )
        issues.append(issue)
    }
}

// MARK: - Error Types

enum CodeQualityError: LocalizedError {
    case fileNotFound(String)
    case invalidSwiftFile(String)
    case analysisFailure(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidSwiftFile(let path):
            return "Invalid Swift file: \(path)"
        case .analysisFailure(let reason):
            return "Analysis failed: \(reason)"
        }
    }
}

// MARK: - Report Formatting

extension CodeQualityReport {
    
    /// Generate a detailed markdown report
    func markdownReport() -> String {
        var report = """
        # Code Quality Analysis Report
        
        **Date**: \(DateFormatter.localizedString(from: analysisDate, dateStyle: .medium, timeStyle: .short))
        **Execution Time**: \(String(format: "%.2f", executionTime)) seconds
        **Files Analyzed**: \(files.count)
        
        ## Summary
        
        | Severity | Count |
        |----------|-------|
        | 🚨 Critical | \(criticalCount) |
        | ⚠️ Warning | \(warningCount) |
        | 💡 Suggestion | \(suggestionCount) |
        | **Total** | **\(issues.count)** |
        
        """
        
        // Group issues by category
        let groupedIssues = Dictionary(grouping: issues) { $0.category }
        
        for category in CodeQualityCategory.allCases {
            if let categoryIssues = groupedIssues[category], !categoryIssues.isEmpty {
                report += "\n## \(category.rawValue)\n\n"
                
                for issue in categoryIssues {
                    report += """
                    ### \(issue.severity.emoji) \(issue.title)
                    
                    **Severity**: \(issue.severity.rawValue)
                    **Location**: \(issue.formattedLocation)
                    
                    \(issue.description)
                    
                    """
                    
                    if let suggestion = issue.suggestion {
                        report += "**Suggestion**: \(suggestion)\n\n"
                    }
                    
                    if let codeExample = issue.codeExample {
                        report += """
                        **Example**:
                        ```swift
                        \(codeExample)
                        ```
                        
                        """
                    }
                }
            }
        }
        
        return report
    }
    
    /// Generate a concise terminal output
    func terminalOutput() -> String {
        var output = summary + "\n\n"
        
        if issues.isEmpty {
            output += "✅ No issues found!\n"
            return output
        }
        
        // Group by severity
        let criticalIssues = issues.filter { $0.severity == .critical }
        let warningIssues = issues.filter { $0.severity == .warning }
        let suggestionIssues = issues.filter { $0.severity == .suggestion }
        
        for issueGroup in [criticalIssues, warningIssues, suggestionIssues] {
            if !issueGroup.isEmpty {
                for issue in issueGroup {
                    output += "\(issue.severity.emoji) \(issue.formattedLocation): \(issue.title)\n"
                    output += "   \(issue.description)\n"
                    if let suggestion = issue.suggestion {
                        output += "   💡 \(suggestion)\n"
                    }
                    output += "\n"
                }
            }
        }
        
        return output
    }
}