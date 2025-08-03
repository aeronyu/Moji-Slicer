//
//  CodeQualityView.swift
//  Moji Slicer
//
//  SwiftUI interface for the Code Quality Analyzer
//

import SwiftUI
import UniformTypeIdentifiers

struct CodeQualityView: View {
    @State private var analyzer = CodeQualityAnalyzer()
    @State private var report: CodeQualityReport?
    @State private var isAnalyzing = false
    @State private var showingFilePicker = false
    @State private var selectedPath: String = ""
    @State private var analysisError: String?
    @State private var selectedCategory: CodeQualityCategory?
    @State private var selectedSeverity: CodeQualitySeverity?
    
    var filteredIssues: [CodeQualityIssue] {
        guard let report = report else { return [] }
        
        return report.issues.filter { issue in
            let categoryMatch = selectedCategory == nil || issue.category == selectedCategory
            let severityMatch = selectedSeverity == nil || issue.severity == selectedSeverity
            return categoryMatch && severityMatch
        }
    }
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            if let report = report {
                reportView(report)
            } else {
                emptyState
            }
        }
        .navigationTitle("Code Quality Analyzer")
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.folder, .swiftSource],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .task {
            // Auto-analyze current project on load
            await analyzeCurrentProject()
        }
    }
    
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Analysis Controls
            VStack(alignment: .leading, spacing: 8) {
                Text("Analysis")
                    .font(.headline)
                
                Button(action: { showingFilePicker = true }) {
                    Label("Select Files/Folder", systemImage: "folder.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: { Task { await analyzeCurrentProject() } }) {
                    HStack {
                        if isAnalyzing {
                            ProgressView()
                                .controlSize(.mini)
                        }
                        Label("Analyze Project", systemImage: "magnifyingglass.circle")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAnalyzing)
            }
            
            Divider()
            
            // Filters
            VStack(alignment: .leading, spacing: 8) {
                Text("Filters")
                    .font(.headline)
                
                // Category Filter
                Picker("Category", selection: $selectedCategory) {
                    Text("All Categories").tag(CodeQualityCategory?.none)
                    ForEach(CodeQualityCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category as CodeQualityCategory?)
                    }
                }
                .pickerStyle(.menu)
                
                // Severity Filter
                Picker("Severity", selection: $selectedSeverity) {
                    Text("All Severities").tag(CodeQualitySeverity?.none)
                    ForEach(CodeQualitySeverity.allCases, id: \.self) { severity in
                        HStack {
                            Text(severity.emoji)
                            Text(severity.rawValue)
                        }.tag(severity as CodeQualitySeverity?)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Divider()
            
            // Summary
            if let report = report {
                summaryView(report)
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 250)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Ready to Analyze")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Select files or folders to analyze Swift code quality")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Analyze Current Project") {
                Task { await analyzeCurrentProject() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAnalyzing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func summaryView(_ report: CodeQualityReport) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Summary")
                .font(.headline)
            
            HStack {
                Text("Files:")
                Spacer()
                Text("\(report.files.count)")
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("🚨 Critical:")
                Spacer()
                Text("\(report.criticalCount)")
                    .fontWeight(.medium)
                    .foregroundColor(report.criticalCount > 0 ? .red : .secondary)
            }
            
            HStack {
                Text("⚠️ Warnings:")
                Spacer()
                Text("\(report.warningCount)")
                    .fontWeight(.medium)
                    .foregroundColor(report.warningCount > 0 ? .orange : .secondary)
            }
            
            HStack {
                Text("💡 Suggestions:")
                Spacer()
                Text("\(report.suggestionCount)")
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Total:")
                Spacer()
                Text("\(report.issues.count)")
                    .fontWeight(.bold)
            }
            
            Text("Analyzed in \(String(format: "%.2f", report.executionTime))s")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
    
    private func reportView(_ report: CodeQualityReport) -> VStack<TupleView<some View>> {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Code Quality Report")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Analyzed \(report.files.count) files • \(filteredIssues.count) issues")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Export buttons
                HStack {
                    Button("Export Markdown") {
                        exportReport(format: .markdown)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Export JSON") {
                        exportReport(format: .json)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            
            Divider()
            
            // Issues List
            if filteredIssues.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("No Issues Found!")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Your code meets all quality standards for the selected filters.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(groupedIssues.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                        if let issues = groupedIssues[category], !issues.isEmpty {
                            Section(category.rawValue) {
                                ForEach(issues, id: \.file) { issue in
                                    issueRow(issue)
                                }
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
    }
    
    private var groupedIssues: [CodeQualityCategory: [CodeQualityIssue]] {
        Dictionary(grouping: filteredIssues) { $0.category }
    }
    
    private func issueRow(_ issue: CodeQualityIssue) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(issue.severity.emoji)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(issue.title)
                        .fontWeight(.medium)
                    
                    Text(issue.formattedLocation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(issue.severity.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(severityColor(issue.severity).opacity(0.2))
                    .foregroundColor(severityColor(issue.severity))
                    .clipShape(Capsule())
            }
            
            Text(issue.description)
                .font(.callout)
                .foregroundColor(.primary)
            
            if let suggestion = issue.suggestion {
                Text("💡 \(suggestion)")
                    .font(.callout)
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
            
            if let codeExample = issue.codeExample {
                Text(codeExample)
                    .font(.caption.monospaced())
                    .padding(8)
                    .background(.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func severityColor(_ severity: CodeQualitySeverity) -> Color {
        switch severity {
        case .critical: return .red
        case .warning: return .orange
        case .suggestion: return .blue
        }
    }
    
    // MARK: - Actions
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                selectedPath = url.path
                Task { await analyzeSelectedPath() }
            }
        case .failure(let error):
            analysisError = error.localizedDescription
        }
    }
    
    @MainActor
    private func analyzeCurrentProject() async {
        isAnalyzing = true
        analysisError = nil
        
        do {
            // Analyze the current project directory
            let projectPath = Bundle.main.bundlePath
            let parentPath = (projectPath as NSString).deletingLastPathComponent
            let report = try analyzer.analyzeProject(at: parentPath)
            self.report = report
        } catch {
            analysisError = error.localizedDescription
        }
        
        isAnalyzing = false
    }
    
    @MainActor
    private func analyzeSelectedPath() async {
        guard !selectedPath.isEmpty else { return }
        
        isAnalyzing = true
        analysisError = nil
        
        do {
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: selectedPath, isDirectory: &isDirectory)
            
            if isDirectory.boolValue {
                let report = try analyzer.analyzeProject(at: selectedPath)
                self.report = report
            } else {
                let issues = try analyzer.analyzeFile(at: selectedPath)
                let url = URL(fileURLWithPath: selectedPath)
                let report = CodeQualityReport(
                    files: [url.lastPathComponent],
                    issues: issues,
                    analysisDate: Date(),
                    executionTime: 0.0
                )
                self.report = report
            }
        } catch {
            analysisError = error.localizedDescription
        }
        
        isAnalyzing = false
    }
    
    private func exportReport(format: ExportFormat) {
        guard let report = report else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [format == .markdown ? .text : .json]
        panel.nameFieldStringValue = "code_quality_report.\(format.fileExtension)"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let content = format == .markdown ? report.markdownReport() : jsonReport(report)
                    try content.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Export failed: \(error)")
                }
            }
        }
    }
    
    private func jsonReport(_ report: CodeQualityReport) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(CodeQualityReportJSON(from: report))
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            return "{\"error\": \"Failed to encode report\"}"
        }
    }
}

enum ExportFormat {
    case markdown, json
    
    var fileExtension: String {
        switch self {
        case .markdown: return "md"
        case .json: return "json"
        }
    }
}

// MARK: - SwiftUI Extensions

extension UTType {
    static var swiftSource: UTType {
        UTType(filenameExtension: "swift") ?? .sourceCode
    }
}

#Preview {
    CodeQualityView()
        .frame(width: 1000, height: 700)
}