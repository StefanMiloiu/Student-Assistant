//
//  PDFKitRepresentedView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.01.2025.
//


import SwiftUI
import PDFKit

struct PDFKitRepresentedView: UIViewRepresentable {
    let pdfData: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: pdfData)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // No update needed in this simple case
    }
}