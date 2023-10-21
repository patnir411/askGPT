//
//  ContentView.swift
//  AskGPT Context Extension
//
//  Created by Niral Patel on 9/28/23.
//
import SwiftUI
import Foundation

struct ChatView: View {
    @State private var userInput: String = ""
    @State private var messages: [String] = ["What's on your mind sir?"]
    @FocusState private var isInputFocused: Bool
    
    init() {
        self.isInputFocused = true
    }
    
    var body: some View {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(messages, id: \.self) { message in
                                if message == "What's on your mind sir?" {
                                    Text(message)
                                        .font(.system(size: 36))  // Makes this specific text much larger
                                        .fontWeight(.bold)
                                        .padding()
                                } else {
                                    Text(message)
                                        .font(.title)  // Keeps other texts at the original size
                                        .fontWeight(.bold)
                                        .padding()
                                }
                            }
                        }
                        .frame(maxWidth: geometry.size.width * 0.8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(height: geometry.size.height * 0.3)
                    Spacer()
                    
                    TextField("the world is in your palm...", text: $userInput, onCommit: {
                        sendMessage()
                    })
                    .focused($isInputFocused)
                    .font(.title) // Increase font size
                    .foregroundColor(.white) // Placeholder and input text color
                    .padding(20) // Increase padding around the text
                    .textFieldStyle(PlainTextFieldStyle()) // Remove default appearance
                    .frame(height: 50) // Set minimum height
                    .frame(width: geometry.size.width * 0.8, alignment: .center) // 80% of screen width, center'd
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .padding(.bottom, 300)
                }
            }
        }
    
    func sendMessage() {
        // Append the user message to the messages array
        messages.append(userInput)
        
        // TODO: Send the message to the backend and get the response
//        queryBackend(userInput: userInput) { response in
//            messages.append(response)
//        }
//        self.isInputFocused = false
        userInput = ""
        self.isInputFocused = true

    }
    
    func queryBackend(userInput: String, completion: @escaping (String) -> Void) {
        // TODO: URL below points to self-set server (current: KRISHNA)
        let url = URL(string: "http://127.0.0.1:5001/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // Change to POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Update the JSON payload to use the "message" field
        let json: [String: Any] = ["message": userInput]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let response = json["response"] as? String {
                completion(response)
            }
        }
        
        task.resume()
    }
}

struct ContentView: View {
    var body: some View {
        ChatView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.8))
    }
}

#Preview {
    ContentView()
}
