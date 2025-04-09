//
//  PokemonQuizView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/9/25.
//
import SwiftUI

struct PokemonQuizView: View {
    @State private var currentQuestion: QuizQuestion?
    @State private var selectedAnswer: String?
    @State private var isAnswerCorrect: Bool?
    @State private var score = 0
    @State private var questionNumber = 0
    @State private var isLoading = false
    @State private var showingResults = false
    @State private var errorMessage: String?
    @State private var questions: [QuizQuestion] = []
    

    let quizQuestions: [QuizQuestion] = [
        QuizQuestion(
            question: "Which Pokémon is known as the Flame Pokémon?",
            answers: ["Charmander", "Squirtle", "Bulbasaur", "Pikachu"],
            correctAnswer: "Charmander"
        ),
        QuizQuestion(
            question: "Which type is super effective against Water?",
            answers: ["Fire", "Grass", "Ground", "Rock"],
            correctAnswer: "Grass"
        ),
        QuizQuestion(
            question: "Which of these evolves into Charizard?",
            answers: ["Charmander", "Charmeleon", "Chimchar", "Cyndaquil"],
            correctAnswer: "Charmeleon"
        ),
        QuizQuestion(
            question: "Which legendary Pokémon is known as the Time Pokémon?",
            answers: ["Palkia", "Dialga", "Giratina", "Arceus"],
            correctAnswer: "Dialga"
        ),
        QuizQuestion(
            question: "How many types of Pokémon are there in total as of Generation 8?",
            answers: ["15", "17", "18", "20"],
            correctAnswer: "18"
        ),
        QuizQuestion(
            question: "Which of these is NOT a starter Pokémon?",
            answers: ["Chikorita", "Froakie", "Eevee", "Torchic"],
            correctAnswer: "Eevee"
        ),
        QuizQuestion(
            question: "Which type is Pikachu?",
            answers: ["Normal", "Electric", "Fire", "Water"],
            correctAnswer: "Electric"
        ),
        QuizQuestion(
            question: "Which item is used to evolve Pikachu into Raichu?",
            answers: ["Thunder Stone", "Moon Stone", "Leaf Stone", "Water Stone"],
            correctAnswer: "Thunder Stone"
        ),
        QuizQuestion(
            question: "Which Pokémon has the Pokedex number #1?",
            answers: ["Pikachu", "Bulbasaur", "Mew", "Charizard"],
            correctAnswer: "Bulbasaur"
        ),
        QuizQuestion(
            question: "Which of these is a Ghost-type Pokémon?",
            answers: ["Jigglypuff", "Gengar", "Mewtwo", "Snorlax"],
            correctAnswer: "Gengar"
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if isLoading {
                        ProgressView("Loading quiz...")
                    } else if showingResults {
                        quizResults
                    } else if let question = currentQuestion {
                        questionView(for: question)
                    } else if let error = errorMessage {
                        errorView(error)
                    } else {
                        startQuizView
                    }
                }
                .padding()
            }
            .navigationTitle("Pokémon Quiz")
        }
    }
    
    private var startQuizView: some View {
        VStack(spacing: 30) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 70))
                .foregroundColor(.blue)
            
            Text("Test Your Pokémon Knowledge!")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Answer 10 questions about Pokémon to see how much of a Pokémon Master you really are!")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: startQuiz) {
                Text("Start Quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func questionView(for question: QuizQuestion) -> some View {
        VStack(spacing: 20) {
            Text("Question \(questionNumber) of 10")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(question.question)
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(spacing: 10) {
                ForEach(question.answers, id: \.self) { answer in
                    Button(action: {
                        selectAnswer(answer)
                    }) {
                        HStack {
                            Text(answer)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedAnswer == answer {
                                if let isCorrect = isAnswerCorrect {
                                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                                        .foregroundColor(isCorrect ? .green : .red)
                                } else {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedAnswer == answer ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                    }
                    .disabled(selectedAnswer != nil)
                }
            }
            
            if selectedAnswer != nil {
                Button(action: nextQuestion) {
                    Text(questionNumber >= 10 ? "Finish Quiz" : "Next Question")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
        }
    }
    
    private var quizResults: some View {
        VStack(spacing: 20) {
            if score >= 8 {
                Image(systemName: "star.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.yellow)
                
                Text("Pokémon Master!")
                    .font(.title)
                    .bold()
            } else if score >= 5 {
                Image(systemName: "star.leadinghalf.filled")
                    .font(.system(size: 70))
                    .foregroundColor(.yellow)
                
                Text("Great Job!")
                    .font(.title)
                    .bold()
            } else {
                Image(systemName: "book.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                
                Text("Keep Learning!")
                    .font(.title)
                    .bold()
            }
            
            Text("You scored \(score) out of 10")
                .font(.title2)
                .padding()
            
            Text(resultMessage)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: restartQuiz) {
                Text("Take Quiz Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.title)
                .bold()
            
            Text(message)
                .multilineTextAlignment(.center)
            
            Button(action: startQuiz) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private var resultMessage: String {
        switch score {
        case 10:
            return "Perfect score! You're a true Pokémon Master!"
        case 8...9:
            return "Amazing! You really know your Pokémon!"
        case 5...7:
            return "Good job! You have solid Pokémon knowledge!"
        case 3...4:
            return "Not bad! With a bit more studying, you'll be a Pokémon expert in no time!"
        default:
            return "Keep learning about Pokémon! Every Master starts somewhere!"
        }
    }
    
    private func startQuiz() {
        isLoading = true
        errorMessage = nil
        questions = quizQuestions.shuffled()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !questions.isEmpty {
                questionNumber = 1
                currentQuestion = questions[0]
                selectedAnswer = nil
                isAnswerCorrect = nil
                score = 0
                showingResults = false
            } else {
                errorMessage = "Could not load quiz questions. Please try again."
            }
            isLoading = false
        }
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isAnswerCorrect = (answer == currentQuestion?.correctAnswer)
        
        if isAnswerCorrect == true {
            score += 1
        }
    }
    
    private func nextQuestion() {
        if questionNumber < 10 {
            questionNumber += 1
            currentQuestion = questions[questionNumber - 1]
            selectedAnswer = nil
            isAnswerCorrect = nil
        } else {
            showingResults = true
        }
    }
    
    private func restartQuiz() {
        startQuiz()
    }
}

struct QuizQuestion {
    let question: String
    let answers: [String]
    let correctAnswer: String
}

#Preview {
    PokemonQuizView()
}
