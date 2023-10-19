//
//  ContentView.swift
//  AskGPT Context Extension
//
//  Created by Niral Patel on 9/28/23.
//
import SwiftUI

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
        
        // Clear the user input
        userInput = ""
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
