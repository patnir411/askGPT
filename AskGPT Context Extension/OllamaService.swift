//
//  LlamaService.swift
//  AskGPT Context Extension
//
//  Created by Niral Patel on 7/26/24.
//

import Foundation
import Combine

struct Message: Codable, Identifiable {
    let id: UUID
    var role: Role
    var content: String
    var timestamp: String? = "x"
    
    init(id: UUID = UUID(), role: Role, content: String, timestamp: String? = "x") {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
    
    var dictionary: [String: String] {
        ["role": role.rawValue, "content": content]
    }
}

enum Role: String, Codable {
    case system
    case user
    case assistant
}

class OllamaService: ObservableObject {
    private let baseURL = "http://localhost:11434/api"
    private var session: URLSession
    @Published var messages: [Message] = []

    init() {
        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration)
    }

    func sendMessage(_ content: String) async {
        print("Send message request... content is \(content)")
        do {
            let userMessage = Message(role: .user, content: content)
            await MainActor.run {
                self.messages.append(userMessage)
            }
           

            guard let url = URL(string: "\(baseURL)/chat") else {
                throw NSError(domain: "InvalidURL", code: 0, userInfo: nil)
            }
            print("URL is \(url)")

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let allMessages = [Message(role: .system, content: "You are a friendly assistant")] + messages

            let parameters: [String: Any] = [
                "model": "llama3.1",
                "messages": allMessages.map { $0.dictionary },
                "stream": true
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)

            let (asyncBytes, _) = try await session.bytes(for: request)
            var accumulatedContent = ""
            for try await line in asyncBytes.lines {
                if let content = processStreamLine(line) {
                    accumulatedContent += content
                    await updateAssistantMessage(accumulatedContent)
                }
            }
        } catch {
            print("Error sending message: \(error)")
        }
    }

    private func processStreamLine(_ line: String) -> String? {
        let cleanedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedLine.isEmpty else { return nil }
        
        do {
            if let jsonData = cleanedLine.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
               let message = json["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            }
        } catch {
            print("Failed to decode JSON line: \(cleanedLine)")
            print("Error: \(error)")
        }
        return nil
    }

    @MainActor
    private func updateAssistantMessage(_ content: String) {
        if let lastMessage = self.messages.last, lastMessage.role == .assistant {
            self.messages[self.messages.count - 1].content = content
        } else {
            self.messages.append(Message(role: .assistant, content: content))
        }
    }
}
