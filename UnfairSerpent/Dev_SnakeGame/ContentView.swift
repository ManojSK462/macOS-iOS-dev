import SwiftUI

// MARK: - Logic (The Brain)
@Observable
class Game {
    
    var snake: [Point] = [Point(x: 10, y: 10)]
    var food = Point(x: 5, y: 5)
    var currentDirection: Direction = .right
    let gridSize = 20
    var timer: Timer?
    var isAlive = true
    var highScore: Int = UserDefaults.standard.integer(forKey: "highScore")
    var score: Int { snake.count - 1 }
    var isPaused = false
    
    
    
    
    // Safety check: Prevents turning 180 degrees into yourself
    func changeDirection(to newDirection: Direction) {
        switch (currentDirection, newDirection) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            break
        default:
            currentDirection = newDirection
        }
    }
    
    func move() {
        var newHead = snake[0]

        switch currentDirection {
        case .up:    newHead.y -= 1
        case .down:  newHead.y += 1
        case .left:  newHead.x -= 1
        case .right: newHead.x += 1
        }

        // Logic for hitting walls (Game Over)
        if newHead.x < 0 || newHead.x >= gridSize || newHead.y < 0 || newHead.y >= gridSize {
            gameOver()
            return
        }

        // Logic for hitting self
        if snake.contains(newHead) {
            gameOver()
            return
        }

        snake.insert(newHead, at: 0)

        if newHead == food {
            spawnFood()
        } else {
            snake.removeLast()
        }
    }
    
    func startGame() {
        // Reset game state
        snake = [Point(x: 10, y: 10)]
        currentDirection = .right
        isAlive = true
        isPaused = false
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            self.move()
        }
    }
    
    func gameOver() {
        timer?.invalidate()
        timer = nil
        
        let currentScore = snake.count - 1
        if currentScore > highScore {
            highScore = currentScore
            UserDefaults.standard.set(highScore, forKey: "highScore")
        }
        
        
        isAlive = false
    }
    
    func spawnFood() {
        food = Point(x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize))
    }
    
    func togglePause(){
        if isPaused {
            isPaused = false
            timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                self.move()
            }}
            else{
                isPaused  = true
                timer?.invalidate()
                timer = nil
            }
    }
    
}

// MARK: - View (The Face)
struct ContentView: View {
    @State private var game = Game()
    let cellSize: CGFloat = 15
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Score: \(game.snake.count - 1)")
                .font(.largeTitle)
                .bold()
            
            Text("High Score: \(game.highScore)")
                .font(.headline)
                .foregroundColor(.black)
            
            // Game Board
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(.black)
                    .frame(width: CGFloat(game.gridSize) * cellSize,
                           height: CGFloat(game.gridSize) * cellSize)
                
                // Food
                Circle()
                    .fill(.red)
                    .frame(width: cellSize, height: cellSize)
                    .offset(x: CGFloat(game.food.x) * cellSize,
                            y: CGFloat(game.food.y) * cellSize)
                
                // Snake
                ForEach(0..<game.snake.count, id: \.self) { index in
                    let part = game.snake[index]
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.green)
                        .frame(width: cellSize, height: cellSize)
                        .offset(x: CGFloat(part.x) * cellSize,
                                y: CGFloat(part.y) * cellSize)
                }
                if !game.isAlive {
                    VStack(spacing: 20) {
                        Text("GAME OVER !!")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.red)
                        
                        Text("Final Score: \(game.snake.count - 1)")
                            .font(.title2)
                            .foregroundColor(.white)

                        Button(action: {
                            game.startGame()
                        }) {
                            Text("PLAY AGAIN")
                                .font(.headline)
                                .bold()
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .frame(width: CGFloat(game.gridSize) * cellSize,
                           height: CGFloat(game.gridSize) * cellSize)
                }
                
                
            }
            .border(Color.gray, width: 2)
            
            // Controls
            VStack(spacing: 10) {
                Button("UP") { game.changeDirection(to: .up) }
                    .buttonStyle(.borderedProminent)
                    
                
                HStack(spacing: 20) {
                    Button("LEFT") { game.changeDirection(to: .left) }
                        .buttonStyle(.borderedProminent)
                    
                    Button("RIGHT") { game.changeDirection(to: .right) }
                        .buttonStyle(.borderedProminent)
                }
                
                Button("DOWN") { game.changeDirection(to: .down) }
                    .buttonStyle(.borderedProminent)
                
                Button("START GAME") {
                    game.startGame()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
                .tint(.blue)
            }
            
            HStack(spacing: 30) {
                    Button(game.isPaused ? "RESUME" : "PAUSE") {
                        game.togglePause()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(!game.isAlive) // Can't pause if you're already dead!

                    Button("RESTART") {
                        game.startGame()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            
        }
        .padding()
    }
}

// MARK: - Supporting Types
struct Point: Hashable {
    var x: Int
    var y: Int
}

enum Direction {
    case up, down, left, right
}

#Preview {
    ContentView()
}
