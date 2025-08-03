//
//  CodeQualityCLI.swift
//  Moji Slicer
//
//  Command-line interface for the Code Quality Analyzer
//

import Foundation

/// Command-line interface for running code quality analysis
@main
struct CodeQualityCLI {
    static func main() {
        let arguments = CommandLine.arguments
        
        if arguments.count < 2 {
            printUsage()
            exit(1)
        }
        
        let command = arguments[1]
        
        switch command {
        case "analyze":
            if arguments.count < 3 {
                print("Error: Missing file or directory path")
                printUsage()
                exit(1)
            }
            let path = arguments[2]
            let format = arguments.count > 3 ? arguments[3] : "terminal"
            
            do {
                try analyzeCode(at: path, format: format)
            } catch {
                print("Error: \(error.localizedDescription)")
                exit(1)
            }
            
        case "help", "--help", "-h":
            printUsage()
            
        case "version", "--version", "-v":
            print("Moji Slicer Code Quality Analyzer v1.0.0")
            
        default:
            print("Error: Unknown command '\(command)'")
            printUsage()
            exit(1)
        }
    }
    
    private static func analyzeCode(at path: String, format: String) throws {
        let analyzer = CodeQualityAnalyzer()
        let url = URL(fileURLWithPath: path)
        var isDirectory: ObjCBool = false
        
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            throw CodeQualityError.fileNotFound(path)
        }
        
        if isDirectory.boolValue {
            // Analyze entire project
            print("🔍 Analyzing project at: \(path)")
            let report = try analyzer.analyzeProject(at: path)
            printReport(report, format: format)
        } else {
            // Analyze single file
            print("🔍 Analyzing file: \(path)")
            let issues = try analyzer.analyzeFile(at: path)
            let report = CodeQualityReport(
                files: [url.lastPathComponent],
                issues: issues,
                analysisDate: Date(),
                executionTime: 0.0
            )
            printReport(report, format: format)
        }
    }
    
    private static func printReport(_ report: CodeQualityReport, format: String) {
        switch format.lowercased() {
        case "markdown", "md":
            print(report.markdownReport())
        case "json":
            printJSONReport(report)
        default:
            print(report.terminalOutput())
        }
    }
    
    private static func printJSONReport(_ report: CodeQualityReport) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(CodeQualityReportJSON(from: report))
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
    }
    
    private static func printUsage() {
        print("""
        Moji Slicer Code Quality Analyzer
        
        USAGE:
            swift CodeQualityCLI.swift <command> [options]
        
        COMMANDS:
            analyze <path> [format]     Analyze Swift code at path
                                       Formats: terminal (default), markdown, json
            help                       Show this help message
            version                    Show version information
        
        EXAMPLES:
            swift CodeQualityCLI.swift analyze ./MyProject
            swift CodeQualityCLI.swift analyze ./ContentView.swift markdown
            swift CodeQualityCLI.swift analyze ./src json
        
        ANALYSIS CATEGORIES:
            • Correctness & Safety (memory leaks, crashes, race conditions)
            • Style & Best Practices (SwiftLint-style rules)
            • Architecture & Modularity (separation of concerns, testability)
            • Performance (expensive patterns, inefficient collections)
            • Security & Privacy (data handling, keychain usage)
            • Accessibility & HIG (accessibility labels, dynamic type)
            • Testing (coverage assessment, test suggestions)
            • Documentation (missing docs, API documentation)
        
        SEVERITY LEVELS:
            🚨 Critical - Issues that must be fixed (crashes, security)
            ⚠️  Warning  - Issues that should be fixed (best practices)
            💡 Suggestion - Improvements for better code quality
        """)
    }
}

// MARK: - JSON Report Structure

struct CodeQualityReportJSON: Codable {
    let summary: SummaryJSON
    let issues: [IssueJSON]
    let metadata: MetadataJSON
    
    init(from report: CodeQualityReport) {
        self.summary = SummaryJSON(
            filesAnalyzed: report.files.count,
            totalIssues: report.issues.count,
            criticalCount: report.criticalCount,
            warningCount: report.warningCount,
            suggestionCount: report.suggestionCount
        )
        
        self.issues = report.issues.map { IssueJSON(from: $0) }
        
        self.metadata = MetadataJSON(
            analysisDate: report.analysisDate,
            executionTime: report.executionTime,
            analyzedFiles: report.files
        )
    }
}

struct SummaryJSON: Codable {
    let filesAnalyzed: Int
    let totalIssues: Int
    let criticalCount: Int
    let warningCount: Int
    let suggestionCount: Int
}

struct IssueJSON: Codable {
    let category: String
    let severity: String
    let title: String
    let description: String
    let file: String
    let line: Int?
    let column: Int?
    let suggestion: String?
    let codeExample: String?
    
    init(from issue: CodeQualityIssue) {
        self.category = issue.category.rawValue
        self.severity = issue.severity.rawValue
        self.title = issue.title
        self.description = issue.description
        self.file = issue.file
        self.line = issue.line
        self.column = issue.column
        self.suggestion = issue.suggestion
        self.codeExample = issue.codeExample
    }
}

struct MetadataJSON: Codable {
    let analysisDate: Date
    let executionTime: TimeInterval
    let analyzedFiles: [String]
}