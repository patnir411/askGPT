//
//  ContentView.swift
//  AskGPT Context Extension
//
//  Created by Niral Patel on 9/28/23.
//
import SwiftUI
import Foundation
import UIKit

struct FocusedTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.placeholder = placeholder
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusedTextField
        
        init(_ parent: FocusedTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}


struct ChatView: View {
    @State private var userInput: String = ""
    @State private var messages: [String] = ["What's on your mind sir?"]
    
    var body: some View {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(messages, id: \.self) { message in
                                Text(message)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: geometry.size.width * 0.8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(height: geometry.size.height * 0.3)
                    Spacer()
                    
                    TextField("awaiting response, the world is in your palm...", text: $userInput, onCommit: {
                        sendMessage()
                    })
                    .foregroundColor(.white) // Placeholder and input text color
                    .padding(10) // Padding around the text
                    .textFieldStyle(PlainTextFieldStyle()) // Remove default appearance
                    .frame(width: geometry.size.width * 0.8) // 80% of screen width
                    .frame(maxWidth: .infinity, alignment: .center) // Center the TextField
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
