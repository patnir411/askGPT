//
//  ContentView.swift
//  AskGPT Context Extension
//
//  Created by Niral Patel on 9/28/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        ChatView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(VisualEffectView())
    }
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var messages: [Message] = []
    private let ollamaService = OllamaService()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        ollamaService.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMessages in
                self?.messages = newMessages
            }
            .store(in: &cancellables)
    }
    
    func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        Task {
            let input = userInput
            userInput = ""
            await ollamaService.sendMessage(input)
        }
        
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}


struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What's on your mind?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.messages) { message in
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
                        .padding(12)
                        .background(Color.blue)
                        .clipShape(Circle())
                }.buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isInputFocused = true
            }
        }
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        Text(message.content)
            .padding()
            .background(message.role == .user ? Color.blue.opacity(0.6) : Color.gray.opacity(0.3))
            .cornerRadius(10)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }
}

//#Preview {
//    if #available(macOS 14.0, *) {
//        ContentView()
//    } else {
//        // Fallback on earlier versions
//    }
//}
