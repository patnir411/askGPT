//
//  ContentView.swift
//  AskGPT Context Extension
//
//  Created by Niral Patel on 9/28/23.
//

import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var messages: [Message] = [Message(content: "What's on your mind, sir?", isUser: false)]
    
    func sendMessage() {
        guard !userInput.isEmpty else { return }
        let userMessage = Message(content: userInput, isUser: true)
        messages.append(userMessage)
        userInput = ""
        
        // Simulate response (Replace with actual backend call)
        let responseMessage = Message(content: "Response from backend", isUser: false)
        messages.append(responseMessage)
    }
}

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What's on your mind, sir?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.messages.dropFirst()) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("The world is in your palm...", text: $viewModel.userInput)
                    .focused($isInputFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .onSubmit {
                        viewModel.sendMessage()
                    }
                
                Button(action: viewModel.sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isInputFocused = true
        }
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        Text(message.content)
            .padding()
            .background(message.isUser ? Color.blue.opacity(0.6) : Color.gray.opacity(0.3))
            .cornerRadius(10)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}

struct ContentView: View {
    var body: some View {
        ChatView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(VisualEffectView())
    }
}

//#Preview {
//    if #available(macOS 14.0, *) {
//        ContentView()
//    } else {
//        // Fallback on earlier versions
//    }
//}
