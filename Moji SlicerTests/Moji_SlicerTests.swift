//
//  Moji_SlicerTests.swift
//  Moji SlicerTests
//
//  Created by Aaron Yu on 7/24/25.
//

import Testing
@testable import Moji_Slicer

struct Moji_SlicerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

// MARK: - Code Quality Analyzer Tests

struct CodeQualityAnalyzerTests {
    
    private let analyzer = CodeQualityAnalyzer()
    
    // MARK: - Correctness & Safety Tests
    
    @Test func testForceUnwrappingDetection() async throws {
        let code = """
        let value = optionalValue!
        let result = someFunction()!.property
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let forceUnwrapIssues = issues.filter { $0.title == "Force Unwrapping Detected" }
        
        #expect(forceUnwrapIssues.count == 2)
        #expect(forceUnwrapIssues.first?.severity == .warning)
        #expect(forceUnwrapIssues.first?.category == .correctnessAndSafety)
    }
    
    @Test func testRetainCycleDetection() async throws {
        let code = """
        someMethod { 
            self.doSomething() 
        }
        let closure = { self.property = value }
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let retainCycleIssues = issues.filter { $0.title == "Potential Retain Cycle" }
        
        #expect(retainCycleIssues.count >= 1)
        #expect(retainCycleIssues.first?.severity == .warning)
    }
    
    @Test func testMainActorValidation() async throws {
        let code = """
        @Observable
        class ViewModel {
            @Published var isLoading = false
            @State private var count = 0
        }
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "ViewModel.swift")
        let mainActorIssues = issues.filter { $0.title == "UI State Without MainActor" }
        
        #expect(mainActorIssues.count >= 1)
        #expect(mainActorIssues.first?.category == .correctnessAndSafety)
    }
    
    @Test func testArrayBoundsChecking() async throws {
        let code = """
        let item = array[0]
        let value = items[42]
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let arrayAccessIssues = issues.filter { $0.title == "Direct Array Index Access" }
        
        #expect(arrayAccessIssues.count == 2)
        #expect(arrayAccessIssues.first?.severity == .suggestion)
    }
    
    // MARK: - Style & Best Practices Tests
    
    @Test func testNamingConventions() async throws {
        let code = """
        func CalculateTotal() -> Double { return 0.0 }
        func ValidateInput() { }
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let namingIssues = issues.filter { $0.title == "Function Naming Convention" }
        
        #expect(namingIssues.count == 2)
        #expect(namingIssues.first?.category == .styleAndBestPractices)
    }
    
    @Test func testLongLineDetection() async throws {
        let longLine = String(repeating: "a", count: 150)
        let code = "let veryLongVariableName = \"\(longLine)\""
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let longLineIssues = issues.filter { $0.title == "Line Too Long" }
        
        #expect(longLineIssues.count == 1)
        #expect(longLineIssues.first?.severity == .suggestion)
    }
    
    @Test func testMagicNumberDetection() async throws {
        let code = """
        view.frame.width = 320
        let timeout = 5000
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let magicNumberIssues = issues.filter { $0.title == "Magic Number Detected" }
        
        #expect(magicNumberIssues.count >= 1)
    }
    
    @Test func testTODOFIXMEDetection() async throws {
        let code = """
        // TODO: Implement this feature
        // FIXME: This is broken
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let todoIssues = issues.filter { $0.title == "Unresolved TODO/FIXME" }
        
        #expect(todoIssues.count == 2)
        #expect(todoIssues.first?.severity == .warning)
    }
    
    // MARK: - Architecture & Modularity Tests
    
    @Test func testSingletonDetection() async throws {
        let code = """
        class ServiceManager {
            static let shared = ServiceManager()
            static var shared2 = ServiceManager()
        }
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let singletonIssues = issues.filter { $0.title == "Singleton Pattern Detected" }
        
        #expect(singletonIssues.count == 2)
        #expect(singletonIssues.first?.category == .architectureAndModularity)
    }
    
    // MARK: - Performance Tests
    
    @Test func testStringConcatenationDetection() async throws {
        let code = """
        result = result + item
        let message = "Hello " + name + "!"
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let stringIssues = issues.filter { $0.title == "String Concatenation in Loop" }
        
        #expect(stringIssues.count >= 1)
        #expect(stringIssues.first?.category == .performance)
    }
    
    @Test func testSynchronousIODetection() async throws {
        let code = """
        let image = NSImage(contentsOf: url)
        let data = Data(contentsOf: fileURL)
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let ioIssues = issues.filter { $0.title == "Synchronous I/O Operation" }
        
        #expect(ioIssues.count == 2)
        #expect(ioIssues.first?.severity == .warning)
    }
    
    @Test func testInfficientCollectionOperations() async throws {
        let code = """
        for item in items {
            results.append(transform(item))
        }
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let collectionIssues = issues.filter { $0.title == "Inefficient Collection Building" }
        
        #expect(collectionIssues.count == 1)
    }
    
    // MARK: - Security & Privacy Tests
    
    @Test func testHardcodedSecretDetection() async throws {
        let code = """
        let password = "secret123"
        let api_key = "abc123def"
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let secretIssues = issues.filter { $0.title == "Potential Hardcoded Secret" }
        
        #expect(secretIssues.count == 2)
        #expect(secretIssues.first?.severity == .critical)
        #expect(secretIssues.first?.category == .securityAndPrivacy)
    }
    
    @Test func testUserDataLoggingDetection() async throws {
        let code = """
        print("User email: \\(user.email)")
        print("Phone number: \\(user.phone)")
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestFile.swift")
        let loggingIssues = issues.filter { $0.title == "Potential User Data Logging" }
        
        #expect(loggingIssues.count == 2)
        #expect(loggingIssues.first?.severity == .warning)
    }
    
    // MARK: - Accessibility & HIG Tests
    
    @Test func testMissingAccessibilityLabels() async throws {
        let code = """
        Button("Save") { }
        Image("icon")
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestView.swift")
        let accessibilityIssues = issues.filter { $0.title == "Missing Accessibility Label" }
        
        #expect(accessibilityIssues.count == 2)
        #expect(accessibilityIssues.first?.category == .accessibilityAndHIG)
    }
    
    @Test func testFixedFontSizeDetection() async throws {
        let code = """
        Text("Hello").font(.system(size: 16))
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "TestView.swift")
        let fontIssues = issues.filter { $0.title == "Fixed Font Size" }
        
        #expect(fontIssues.count == 1)
        #expect(fontIssues.first?.severity == .suggestion)
    }
    
    // MARK: - Testing Tests
    
    @Test func testNonDeterministicCodeDetection() async throws {
        let code = """
        let timestamp = Date()
        let id = UUID()
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "Service.swift")
        let testabilityIssues = issues.filter { 
            $0.title == "Non-Deterministic Date Creation" || 
            $0.title == "Non-Deterministic UUID Creation" 
        }
        
        #expect(testabilityIssues.count == 2)
        #expect(testabilityIssues.first?.category == .testing)
    }
    
    // MARK: - Documentation Tests
    
    @Test func testMissingDocumentationDetection() async throws {
        let code = """
        public func calculateTotal(items: [Item]) -> Double {
            return items.reduce(0) { $0 + $1.price }
        }
        
        public class PaymentProcessor {
            // Implementation
        }
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "API.swift")
        let docIssues = issues.filter { $0.title == "Missing Public API Documentation" }
        
        #expect(docIssues.count == 2)
        #expect(docIssues.first?.category == .documentation)
    }
    
    // MARK: - Integration Tests
    
    @Test func testCompleteAnalysis() async throws {
        let code = """
        import SwiftUI
        
        class ViewModel: ObservableObject {
            @Published var items: [String] = []
            
            func loadData() {
                let data = Data(contentsOf: URL(string: "https://api.example.com")!)!
                // TODO: Parse data
                for item in data {
                    items.append(String(item))
                }
            }
        }
        
        struct ContentView: View {
            var body: some View {
                Button("Load") { }
                    .font(.system(size: 14))
            }
        }
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "ContentView.swift")
        
        // Should find multiple categories of issues
        let categories = Set(issues.map { $0.category })
        #expect(categories.count >= 3)
        
        // Should find various severity levels
        let severities = Set(issues.map { $0.severity })
        #expect(severities.contains(.warning))
        #expect(severities.contains(.suggestion))
    }
    
    // MARK: - Report Generation Tests
    
    @Test func testReportGeneration() async throws {
        let code = """
        let value = optional!
        // TODO: Fix this
        """
        
        let issues = analyzer.analyzeCode(code, fileName: "Test.swift")
        let report = CodeQualityReport(
            files: ["Test.swift"],
            issues: issues,
            analysisDate: Date(),
            executionTime: 0.1
        )
        
        #expect(report.issues.count == 2)
        #expect(report.files.count == 1)
        #expect(report.criticalCount >= 0)
        #expect(report.warningCount >= 1)
        #expect(report.suggestionCount >= 0)
        
        // Test report formatting
        let markdownReport = report.markdownReport()
        #expect(markdownReport.contains("# Code Quality Analysis Report"))
        #expect(markdownReport.contains("Force Unwrapping"))
        
        let terminalOutput = report.terminalOutput()
        #expect(terminalOutput.contains("Analysis Summary"))
    }
}
