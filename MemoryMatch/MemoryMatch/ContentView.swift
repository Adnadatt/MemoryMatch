//
//  ContentView.swift
//  MemoryMatch
//
//  Created by Chen, Amanda M on 4/29/24.
//

import SwiftUI
import AVFAudio

struct card: Identifiable, Equatable, Hashable {
    var id = UUID()
    var symbol: String
    var isFlipped: Bool
    var backDegree: Double
    var frontDegree: Double
    var display: Bool
    init(sym: String) {
        id = UUID()
        symbol = sym
        isFlipped = false
        backDegree = 0.0
        frontDegree = -90.0
        display = true
    }
}

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var stopwatch = 0.0
    
    @State var easyCards: [card] = [card(sym: "tortoise"), card(sym: "tortoise.fill"), card(sym: "ant"), card(sym: "ant.fill"), card(sym: "hare"), card(sym: "hare.fill"), card(sym: "lizard"), card(sym: "lizard.fill"), card(sym: "ladybug"), card(sym: "ladybug.fill"), card(sym: "teddybear"), card(sym: "teddybear.fill")]
    
    @State var popCards: [card] = [card(sym: "finn"), card(sym: "finn"), card(sym: "homer"), card(sym: "homer"), card(sym: "ironman"), card(sym: "ironman"), card(sym: "jake"), card(sym: "jake"), card(sym: "ninjaturtle"), card(sym: "ninjaturtle"), card(sym: "supermario"), card(sym: "supermario")]
    
    @State var hardCards: [card] = [card(sym: "globe.americas"), card(sym: "globe.americas.fill"), card(sym: "globe.europe.africa"), card(sym: "globe.europe.africa.fill"), card(sym: "globe.asia.australia"), card(sym: "globe.asia.australia.fill"), card(sym: "globe.central.south.asia"), card(sym: "globe.central.south.asia.fill")]
    @State var cards = Array(repeating: card(sym: ""), count: 12)
    @State private var gameOn = false
    
    let width : CGFloat = 110
    let height : CGFloat = 160
    let durationAndDelay : CGFloat = 0.1
    
    func flipCard(index: Int) {
        cards[index].isFlipped = !cards[index].isFlipped
        if cards[index].isFlipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                cards[index].backDegree = 90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                cards[index].frontDegree = 0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay)) {
                cards[index].frontDegree = -90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                cards[index].backDegree = 0
            }
        }
    }
    
    let spacing: CGFloat = 0
    @State private var flipped = 0
    @State private var indexOne = -1
    @State private var indexTwo = -1
    @State private var score = 0
    @State private var time = 0.0
    @State private var bestTime = 0.0
    @State private var numGuesses = 0
    @State private var bestNumGuesses = 0
    
    @State private var sliderValue: Double = .zero
    var body: some View {
        
        VStack {
            
            if(!gameOn){
                //play game? screen
                
                Image("MemoryMatch")
                    .resizable()
                    .scaledToFit()
                
                
                Text("⭐️ CHOOSE THE DIFFICULTY ⭐️")
                    .font(.headline)
                    .padding()
                
                HStack{
                    Text("Easy")
                    Spacer()
                    Text("Mystery")
                    Spacer()
                    Text("Hard")
                    
                }
                .padding(.horizontal)
                
                
                
                Slider(value: $sliderValue, in: 0...2, step: 1)

                Button("Play Game?") {
                    
                    if(sliderValue == 0){
                        cards = easyCards
                    } else if (sliderValue == 1){
                        cards = popCards
                    } else if (sliderValue == 2){
                        cards = hardCards
                    }
                    
                    cards.shuffle()
                    gameOn = true
                    numGuesses = 0
                    playSound(soundName: "cardRiffle")
                }
                .tint(.indigo)
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
                
                Divider()
                    .overlay(Color.black.opacity(0.6))
                    .padding(.horizontal)

                VStack{
                    Text("🎯SCOREBOARD")
                        .font(.title2)
                        .padding(2)
                        .bold()
                    HStack {
                        Text("Time: \(String(format: "%g",time))s")
                        
                        Spacer()
                        
                        Text("Guesses: \(numGuesses)")
                    }
                    HStack {
                        Text("Best Time: \(String(format: "%g",bestTime))s")
                        
                        Spacer()
                        
                        Text("Least Guesses: \(bestNumGuesses)")
                    }
                }
                .padding(30)
            } else {
                Text("Time Remaining: \(String(format: "%g", stopwatch))")
                    .onReceive(timer){_ in
                        stopwatch += 0.1
                        
                    }
                
                // game in motion
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 102), spacing: spacing)]) {

                    ForEach(0..<cards.count, id: \.self) { index in
                        if(cards[index].display){
                            ZStack{

                                CardFront(width: width, height: height, symbol: cards[index].symbol, source: Int(sliderValue), degree: $cards[index].frontDegree)
                                CardBack(width: width, height: height, degree: $cards[index].backDegree)
                            }.onTapGesture {
                                playSound(soundName: "flipCard")
                                flipCard(index: index)
                                flipped += 1
                                
                                if(flipped == 1){
                                    indexOne = index
                                } else if (flipped == 2 && index != indexOne) {
                                    indexTwo = index
                                    if(cards[indexOne].symbol.contains(cards[indexTwo].symbol) || cards[indexTwo].symbol.contains(cards[indexOne].symbol)) {
                                        score += 1
                                        numGuesses += 1
                                        playSound(soundName: "correct")
                                        if (score == cards.count/2) {
                                            time = stopwatch
                                            stopwatch = 0
                                            score = 0
                                            
                                            
                                            if(bestTime == 0.0 || time < bestTime) {
                                                bestTime = time
                                            }
                                            if(bestNumGuesses == 0 || numGuesses < bestNumGuesses) {
                                                bestNumGuesses = numGuesses
                                            }
                                            
                                            gameOn = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            cards[indexOne].display = false
                                            cards[indexTwo].display = false
                                            indexOne = -1
                                            indexTwo = -1
                                        }
                                        
                                        
                                    }else{
                                        numGuesses += 1
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            flipCard(index: indexOne)
                                            flipCard(index: indexTwo)
                                            indexOne = -1
                                            indexTwo = -1
                                            playSound(soundName: "incorrect")
                                        }
                                        
                                    }
                                    flipped = 0
                                } else {
                                    flipped -= 1
                                }
                            }
                        } else {
                            Rectangle()
                                .fill(.white)
                                .frame(width: width, height: height)
                        }
                    }
                }
                
                
            }
        }
        .padding()
    }
    
    func playSound(soundName: String){
        guard let soundFile = NSDataAsset(name: soundName) else {
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            
        }
    }
}

struct CardFront : View {
    let width : CGFloat
    let height : CGFloat
    let symbol : String
    let source : Int
    @Binding var degree : Double
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
            
            if(source == 1){
                Image(symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("Amber"))
                    .frame(width: 70, height: 70)
            } else {
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("Amber"))
                    .frame(width: 90, height: 90)
            }
            
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardBack : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("Cerise"), lineWidth: 3)
                .frame(width: width, height: height)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue.opacity(0.2))
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("Cerise").opacity(0.7))
                .padding()
                .frame(width: width*1.1, height: height*1.05)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("Cerise").opacity(0.7), lineWidth: 3)
                .padding()
                .frame(width: width*1.1, height: height*1.05)
            
            Image(systemName: "seal.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Color("Cerise"))
            
            Image(systemName: "seal")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
            
            Image(systemName: "seal")
                .resizable()
                .frame(width: 85, height: 85)
                .foregroundColor(Color("Cerise"))
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
