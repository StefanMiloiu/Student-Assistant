//
//  PDFPickerView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 21.01.2025.
//


import SwiftUI
import UniformTypeIdentifiers

struct PDFPickerView: UIViewControllerRepresentable {
    @Binding var selectedPDFURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: PDFPickerView

        init(_ parent: PDFPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedPDFURL = urls.first
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.selectedPDFURL = nil
        }
    }
}
