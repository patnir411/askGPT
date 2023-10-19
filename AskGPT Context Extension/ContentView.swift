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
    @State private var messages: [String] = ["Hi! Ask away."]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                ScrollView {
                    VStack {
                        ForEach(messages, id: \.self) { message in
                            Text(message)
                                .font(.title) // Makes the text larger
                                .fontWeight(.bold) // Makes the text bold
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: geometry.size.height * 0.3) // 60% of the total height
                Spacer()
                HStack {
                    TextField("Type your message...", text: $userInput, onCommit: {
                        sendMessage()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 600)
                    Button("Send") {
                        sendMessage()
                    }
                }
                .padding(.bottom, 300)
            }
        }
    }
    
    func sendMessage() {
        // Append the user message to the messages array
        messages.append(userInput)
        
        // TODO: Send the message to the backend and get the response
        queryBackend(userInput: userInput) { response in
            messages.append(response)
        }
        // Clear the user input
        userInput = ""
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
            .background(Color.black.opacity(0.5))
    }
}

#Preview {
    ContentView()
}
