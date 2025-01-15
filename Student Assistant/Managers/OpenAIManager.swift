//
//  OpenAIManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import Foundation
import OpenAI

struct OpenAIManager {
    
    private let openAI: OpenAI
    
    init() {
        let openAIKey: String = {
            if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
               let plistData = FileManager.default.contents(atPath: path),
               let config = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
                return config["OpenAI_API_Key"] as? String ?? ""
            }
            return ""
        }()
        self.openAI = OpenAI(apiToken: openAIKey)
    }
    
    /// Function to send a message as a prompt and get a response
    func sendMessage(_ message: String) async -> String? {
        let query = ChatQuery(
            messages: [.init(role: .user, content: message)!],
            model: .gpt4_o_mini,
            maxTokens: 500
        )
        
        do {
            let result = try await openAI.chats(query: query)
            if let responseContent = result.choices.first?.message.content {
                return responseContent.string
            } else {
                print("No response content available.")
                return nil
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Helper function to gather assignments and exams information in a format suitable for study card generation
    func fetchDataForAssignmentsAndExams() -> String {
        let examRepo = ExamRepo()
        let assignmentRepo = AssignmentRepo()
        var summary: String = ""
        
        let exams: [Exam] = examRepo.fetchObject()
        let assignments: [Assignment] = assignmentRepo.fetchObject()
        
        summary += "Here is my schedule information:\n\nExams:\n"
        for exam in exams {
            summary += """
            - Subject: \(exam.examSubject ?? "No Subject")
              Date: \(exam.examDate?.formatted(date: .complete, time: .shortened) ?? "No Date")
              Location: \(exam.examLocation ?? "No Location")
            
            """
        }
        
        summary += "\nAssignments:\n"
        for assignment in assignments.filter({$0.assignmentStatus == .inProgress || $0.assignmentStatus == .pending}) {
            summary += """
            - Title: \(assignment.assignmentTitle ?? "No Title")
              Due Date: \(assignment.assignmentDate?.description ?? "No Date")
              Description: \(assignment.assignmentDescription ?? "No Description")
              Status: \(getStatusAsString(assignment.assignmentStatus))
            
            """
        }
        
        return summary
    }
    
    private func getStatusAsString(_ status: Status) -> String {
        switch status {
        case .completed:
            return "Completed"
        case .inProgress:
            return "In Progress"
        case .pending:
            return "Pending"
        case .failed:
            return "Failed"
        }
    }
    
    /// Function to generate flashcards based on provided content
    func generateStudyCards(from content: String) async -> [Flashcard]? {
        let prompt = """
        Generate concise study flashcards from the following content. Each flashcard should have a question and an answer that could help with memorization and understanding. Everything that is in the content try to make flashcard. Use the language that is in the content.
        
        Content:
        \(content)
        
        Format:
        - Question: [Write a question based on the content]
          Answer: [Write a concise answer based on the content]
        """
        
        let query = ChatQuery(
            messages: [.init(role: .user, content: prompt)!],
            model: .gpt4_o_mini,
            maxTokens: 500
        )
        
        do {
            let result = try await openAI.chats(query: query)
            guard let responseText = result.choices.first?.message.content else {
                return nil
            }
            
            // Parse responseText into flashcards
            return parseFlashcards(from: responseText.string ?? "Could not get string for chat response")
        } catch {
            print("Error generating flashcards: \(error.localizedDescription)")
            return nil
        }
    }
    
    func generateInteractiveStudyCards(from content: String) async -> [FlashcardInteractive]? {
        let prompt = """
            Generate interactive study flashcards from the content below. Each flashcard should have:
            - A question relevant to the content.
            - One correct answer.
            - Two incorrect answers that seem plausible.
            - The response should be in the language that is the content in.

            Format:
            - Question: [Your question]
              Answer: [Correct answer]
              WrongAnswer: [First incorrect answer]
              WrongAnswer: [Second incorrect answer]

            Content:
            \(content)
            """
        
        let query = ChatQuery(
            messages: [.init(role: .user, content: prompt)!],
            model: .gpt4_o_mini,
            maxTokens: 2000
        )
        
        do {
            let result = try await openAI.chats(query: query)
            guard let responseText = result.choices.first?.message.content else {
                return nil
            }
            
            // Parse responseText into flashcards
            print(responseText.string ?? "Could not get string for chat response")
            return parseInteractiveFlashcards(from: responseText.string ?? "Could not get string for chat response")
        } catch {
            print("Error generating flashcards: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func parseFlashcards(from response: String) -> [Flashcard] {
        var flashcards: [Flashcard] = []
        
        // Simple parsing based on "Question:" and "Answer:" keywords
        let components = response.components(separatedBy: "\n")
        var currentQuestion: String?
        
        for line in components {
            if line.starts(with: "- Question:") {
                currentQuestion = line.replacingOccurrences(of: "- Question: ", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.starts(with: "  Answer:"), let question = currentQuestion {
                let answer = line.replacingOccurrences(of: "  Answer: ", with: "").trimmingCharacters(in: .whitespaces)
                flashcards.append(Flashcard(question: question, answer: answer))
                currentQuestion = nil
            }
        }
        
        return flashcards
    }
    
    private func parseInteractiveFlashcards(from response: String) -> [FlashcardInteractive] {
        var flashcards: [FlashcardInteractive] = []
        
        // Split response text by lines
        let components = response.components(separatedBy: "\n")
        var currentQuestion: String?
        var correctAnswer: String?
        var wrongAnswers: [String] = []

        for line in components {
            if line.starts(with: "- Question:") {
                currentQuestion = line.replacingOccurrences(of: "- Question: ", with: "").trimmingCharacters(in: .whitespaces)
                correctAnswer = nil
                wrongAnswers.removeAll()
            } else if line.starts(with: "  Answer:") {
                correctAnswer = line.replacingOccurrences(of: "  Answer: ", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.starts(with: "  WrongAnswer:") {
                let wrongAnswer = line.replacingOccurrences(of: "  WrongAnswer: ", with: "").trimmingCharacters(in: .whitespaces)
                wrongAnswers.append(wrongAnswer)
            }
            
            // Check if we have a complete set to form a flashcard
            if let question = currentQuestion, let answerOne = correctAnswer, wrongAnswers.count == 2 {
                flashcards.append(
                    FlashcardInteractive(
                        question: question,
                        answerOne: answerOne,
                        answerTwo: wrongAnswers[0],
                        answerThree: wrongAnswers[1]
                    )
                )
                currentQuestion = nil
            }
        }
        
        return flashcards
    }
    
    func getStudyRecomandations() async -> String? {
        // Define possible topics for the advice
        let currentLanguage = Locale.preferredLanguages.first ?? "en"
        let topics = [
                "Study Tips: Provide a few short, unnumbered tips for effective learning and retention. Write each tip as a standalone sentence, separated by a single newline, without using any bullet points, dashes, or extra formatting. The language should be in \(currentLanguage).",
                "Lifestyle Tips: Suggest a few short, unnumbered lifestyle tips to maintain a healthy and balanced life. Write each tip as a standalone sentence, separated by a single newline, without using any bullet points, dashes, or extra formatting. The language should be in \(currentLanguage).",
                "Life Advice: Give a few pieces of general advice for personal growth and resilience. Write each piece as a standalone sentence, separated by a single newline, without using any bullet points, dashes, or extra formatting. The language should be in \(currentLanguage)."
            ]
        
        // Select a random topic
        let prompt = topics.randomElement() ?? topics[0] + " Each tip should be short and complete, without extra formatting. Limit the entire response to 100-150 tokens."
        let query = ChatQuery(
            messages: [.init(role: .user, content: prompt)!],
            model: .gpt4_o_mini,
            maxTokens: 150,
            temperature: 0.3
        )
        
        do {
            let result = try await openAI.chats(query: query)
            if let responseContent = result.choices.first?.message.content {
                print(responseContent)
                return responseContent.string
            } else {
                print("No response content available.")
                return nil
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
