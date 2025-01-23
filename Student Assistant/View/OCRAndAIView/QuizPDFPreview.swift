//
//  QuizPdfPreview.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.01.2025.
//

import SwiftUI
import UniformTypeIdentifiers


struct QuizPDFPreview: View {
    // Textul din care generăm PDF-ul
    let extractedText: String
    
    // Stocăm PDF-ul generat
    @State private var pdfData: Data
    
    // Sheet pentru partajare (Share Sheet)
    @State private var isShareSheetPresented = false
    
    // Inițializare care generează PDF imediat
    init(extractedText: String) {
        self.extractedText = extractedText
        // Generăm PDF o singură dată și îl stocăm în @State
        self._pdfData = State(initialValue: Self.generatePDF(from: extractedText))
    }
    
    var body: some View {
        // Afișăm PDF-ul pe tot ecranul
        PDFKitRepresentedView(pdfData: pdfData)
            .edgesIgnoringSafeArea(.all) // ca să ocupe tot ecranul
            .navigationBarTitle("PDF Preview", displayMode: .inline)
            .toolbar {
                // Buton de share în dreapta sus
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Deschide sheet-ul
                        isShareSheetPresented = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            // Sheet pentru share
            .sheet(isPresented: $isShareSheetPresented) {
                ShareSheet(activityItems: [pdfData])
            }
    }
}

// MARK: - Generarea PDF-ului
extension QuizPDFPreview {
    static func generatePDF(from text: String) -> Data {
        let pdfMetaData = [
            kCGPDFContextTitle: "Quiz PDF",
            kCGPDFContextAuthor: "Student Assistant"
        ]
        
        // Define page dimensions (A4 size)
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margins: CGFloat = 20
        let textRect = CGRect(x: margins, y: margins, width: pageWidth - 2 * margins, height: pageHeight - 2 * margins)
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        let data = renderer.pdfData { context in
            // Text attributes
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .paragraphStyle: paragraphStyle
            ]
            
            // Break text into pages
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            var currentRange = NSRange(location: 0, length: 0)
            let textStorage = NSTextStorage(attributedString: attributedText)
            let textLayoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: CGSize(width: textRect.width, height: textRect.height))
            textContainer.lineFragmentPadding = 0
            textContainer.maximumNumberOfLines = 0
            
            textLayoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(textLayoutManager)
            
            repeat {
                context.beginPage()
                
                // Render the text within the current range that fits the page
                textLayoutManager.drawGlyphs(forGlyphRange: textLayoutManager.glyphRange(for: textContainer), at: textRect.origin)
                
                // Move to the next range
                let glyphRange = textLayoutManager.glyphRange(for: textContainer)
                currentRange = NSRange(location: glyphRange.location + glyphRange.length, length: attributedText.length - glyphRange.length)
            } while currentRange.location < attributedText.length
        }
        
        return data
    }
}
#Preview {
    QuizPDFPreview(extractedText: "Here is some sample text to be converted to a PDF. This text might be quiz questions, summaries, or any other study material.")
}
