//
//  OCRManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 21.01.2025.
//

import Foundation
import Vision
import PDFKit
import CoreImage

func preprocessImage(_ uiImage: UIImage) -> UIImage? {
    guard let cgImage = uiImage.cgImage else { return nil }
    let ciImage = CIImage(cgImage: cgImage)
    
    // 1. Crește contrastul
    let contrastFilter = CIFilter(name: "CIColorControls")!
    contrastFilter.setValue(ciImage, forKey: kCIInputImageKey)
    contrastFilter.setValue(1.2, forKey: kCIInputContrastKey) // ajustare
    
    // 2. Binarizare / Threshold (nu există un filtru nativ, dar există implementări custom)
    // -> Exemplu de pseudo-threshold:
    guard let contrastedImage = contrastFilter.outputImage else { return nil }
    
    // 3. Convertește înapoi la UIImage
    let context = CIContext()
    if let outputCGImage = context.createCGImage(contrastedImage, from: contrastedImage.extent) {
        return UIImage(cgImage: outputCGImage)
    }
    
    return nil
}

struct OCRManager {
    
    func performImageOCR(on image: UIImage, completion: @escaping (String) -> Void) {
        let processedImage = preprocessImage(image) ?? image
        
        guard let cgImage = processedImage.cgImage else {
            completion("")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                completion("")
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            let fullText = recognizedStrings.joined(separator: " ")
            completion(fullText)
        }
        
        // Configure the request for better accuracy
        request.recognitionLanguages = ["en-US", "fr-FR", "ro-RO"]
        request.recognitionLevel = .accurate
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing OCR: \(error.localizedDescription)")
            completion("")
        }
    }
    
    /// Extracts text from a PDF. If the page is a scanned image (no recognized text),
    /// it renders the page as an image and applies OCR.
    func extractTextFromPDF(url: URL) async -> String {
        guard let pdfDocument = PDFDocument(url: url) else { return "" }
        
        var allText = ""
        let pageCount = pdfDocument.pageCount
        
        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            
            // 1. Încercare extragere text nativ
            if let pageText = page.string, !pageText.isEmpty {
                print("Extracted text from page \(pageIndex): \(pageText)")
                allText += pageText + "\n"
            } else {
                print("No embedded text found on page \(pageIndex). Falling back to OCR.")
                // 2. OCR fallback
                if let pageImage = renderPDFPageToImage(page: page) {
                    print("Rendered page \(pageIndex) to image successfully.")
                    let recognizedText: String = await withCheckedContinuation { continuation in
                        performImageOCR(on: pageImage) { ocrText in
                            continuation.resume(returning: ocrText)
                        }
                    }
                    print("Recognized text from page \(pageIndex): \(recognizedText)")
                    allText += recognizedText + "\n"
                } else {
                    print("Failed to render page \(pageIndex) to image.")
                }
            }
        }
        return allText
    }
    
    // MARK: - Private Helpers
    
    /// Renders a PDF page into a UIImage.
    private func renderPDFPageToImage(page: PDFPage) -> UIImage? {
        // Determine the page's bounds
        let pageRect = page.bounds(for: .mediaBox)
        
        // Create a renderer at the page size
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        // Render the PDF page into a UIImage
        let image = renderer.image { ctx in
            // White background by default
            UIColor.white.set()
            ctx.fill(pageRect)
            
            // Transform the context to account for any PDF rotation or scaling
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            guard let cgContext = UIGraphicsGetCurrentContext() else { return }
            page.draw(with: .mediaBox, to: cgContext)
        }
        return image
    }
}
