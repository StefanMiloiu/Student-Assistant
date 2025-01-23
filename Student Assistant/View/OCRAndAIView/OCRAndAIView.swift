//
//  OCRAndAIView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 21.01.2025.
//

import SwiftUI

struct OCRAndAIView: View {
    @State private var selectedImage: UIImage?
    @State private var selectedPDFURL: URL?
    @State private var extractedText: String = ""
    @State private var summary: String = ""
    @State private var quiz: String = ""
    
    private var aiManager = OpenAIManager()
    private var ocrManager = OCRManager()
    @State private var showImagePicker = false
    @State private var showPDFPicker = false
    @State private var showGeneratedQuiz: Bool = false
    @State private var showSummary: Bool = false
    @State private var isLoading: Bool = false
    @State private var isLoadingQuiz: Bool = false
    @State private var isLoadingSummary: Bool = false
    
    func performOCRAsync(on image: UIImage) async -> String {
        await withCheckedContinuation { continuation in
            ocrManager.performImageOCR(on: image) { recognizedText in
                continuation.resume(returning: recognizedText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // MARK: - Pickers
                Text("OCR & AI Assistant")
                    .font(.title)
                    .padding(.top, 20)
                
                HStack(spacing: 16) {
                    Button(action: {
                        showImagePicker = true
                    }, label: {
                        Label("Pick Image", systemImage: "photo")
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    })
                    
                    Button(action: {
                        showPDFPicker = true
                    }, label: {
                        Label("Pick PDF", systemImage: "doc.text.fill")
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    })
                }
                .padding(.horizontal)
                
                if selectedImage == nil && selectedPDFURL == nil {
                    Text("Please select an image or PDF file to proceed.")
                        .foregroundColor(.secondary)
                        .padding()
                        .background(.red.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                if (selectedImage != nil || selectedPDFURL != nil)
                    && extractedText.isEmpty {
                    Text("Could not extract text.")
                        .foregroundColor(.secondary)
                        .padding()
                        .background(.red.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // MARK: - Selected Image Preview
                if let image = selectedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding()
                        
                        // Remove Image Button
                        Button(action: {
                            selectedImage = nil
                            extractedText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                                .padding(8)
                        }
                    }
                }
                
                // MARK: - Selected PDF Preview
                if let pdfURL = selectedPDFURL {
                    ZStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.title2)
                            Text(pdfURL.lastPathComponent)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        
                        // Remove PDF Button
                        Button(action: {
                            selectedPDFURL = nil
                            extractedText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                                .padding()
                        }
                    }
                }
                
                // MARK: - Summarize Button + Summary
                Button(action: {
                    Task {
                        isLoadingSummary.toggle()
                        summary = await aiManager.summarizeText(extractedText)
                        showSummary.toggle()
                        isLoadingSummary.toggle()
                    }
                }) {
                    if isLoadingSummary {
                        ProgressView("Processing...")
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(10)
                    } else {
                        Text("Summarize Text")
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(extractedText.isEmpty ? Color.gray : Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .disabled(extractedText.isEmpty)
                
                // MARK: - Generate Quiz Button + Quiz
                Button(action: {
                    Task {
                        isLoadingQuiz.toggle()
                        quiz = await aiManager.generateQuiz(for: extractedText)
                        showGeneratedQuiz.toggle()
                        isLoadingQuiz.toggle()
                    }
                }) {
                    if isLoadingQuiz {
                        ProgressView("Processing...")
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(10)
                    } else {
                        Text("Generate Quiz")
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(extractedText.isEmpty ? Color.gray : Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .disabled(extractedText.isEmpty)
                Spacer()
            }
        }
        // Image Picker
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
                .onDisappear {
                    if let img = selectedImage {
                        Task {
                            isLoading = true
                            extractedText = await performOCRAsync(on: img)
                            isLoading = false
                        }
                    }
                }
        }
        // PDF Picker
        .sheet(isPresented: $showPDFPicker) {
            PDFPickerView(selectedPDFURL: $selectedPDFURL)
                .onDisappear {
                    if let pdfURL = selectedPDFURL {
                        // Rulează extragerea asincron, cu un spinner
                        Task {
                            isLoading = true
                            let text = await ocrManager.extractTextFromPDF(url: pdfURL)
                            extractedText = text
                            isLoading = false
                        }
                    }
                }
        }
        // Generated Summary
        .sheet(isPresented: $showSummary) {
            NavigationView {
                QuizPDFPreview(extractedText: summary)
            }
        }
        // Generated Quiz
        .sheet(isPresented: $showGeneratedQuiz) {
            NavigationView {
                QuizPDFPreview(extractedText: quiz)
            }
        }
    }
}

//Preview
#Preview {
    OCRAndAIView()
}
