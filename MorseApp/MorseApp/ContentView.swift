import UIKit
import AVFoundation
import CoreAudio

class MorseCodeViewController: UIViewController, AVAudioPlayerDelegate {
    
    // Morse code dictionary
    let morseCodeDictionary: [String: String] = [
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
        "F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
        "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
        "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
        "U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--",
        "Z": "--..",
        "1": ".----", "2": "..---", "3": "...--", "4": "....-", "5": ".....",
        "6": "-....", "7": "--...", "8": "---..", "9": "----.", "0": "-----"
    ]
    
    // Outlets
    var morseTextView: UITextView!
    var englishLabel: UILabel!
    var dotButton: UIButton!
    var dashButton: UIButton!
    var translateButton: UIButton!
    var playButton: UIButton!
    
    // Audio player
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // Function to set up the user interface
    func setupUI() {
        // Morse Text View
        morseTextView = UITextView()
        morseTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(morseTextView)
        NSLayoutConstraint.activate([
            morseTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            morseTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            morseTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            morseTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // English Label
        englishLabel = UILabel()
        englishLabel.translatesAutoresizingMaskIntoConstraints = false
        englishLabel.textAlignment = .center
        view.addSubview(englishLabel)
        NSLayoutConstraint.activate([
            englishLabel.topAnchor.constraint(equalTo: morseTextView.bottomAnchor, constant: 20),
            englishLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            englishLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            englishLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Dot Button
        dotButton = UIButton(type: .system)
        dotButton.setTitle(".", for: .normal)
        dotButton.addTarget(self, action: #selector(dotButtonPressed(_:)), for: .touchUpInside)
        dotButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dotButton)
        NSLayoutConstraint.activate([
            dotButton.topAnchor.constraint(equalTo: englishLabel.bottomAnchor, constant: 20),
            dotButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dotButton.widthAnchor.constraint(equalToConstant: 50),
            dotButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Dash Button
        dashButton = UIButton(type: .system)
        dashButton.setTitle("-", for: .normal)
        dashButton.addTarget(self, action: #selector(dashButtonPressed(_:)), for: .touchUpInside)
        dashButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dashButton)
        NSLayoutConstraint.activate([
            dashButton.topAnchor.constraint(equalTo: englishLabel.bottomAnchor, constant: 20),
            dashButton.leadingAnchor.constraint(equalTo: dotButton.trailingAnchor, constant: 20),
            dashButton.widthAnchor.constraint(equalToConstant: 50),
            dashButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Translate Button
        translateButton = UIButton(type: .system)
        translateButton.setTitle("Translate", for: .normal)
        translateButton.addTarget(self, action: #selector(translateButtonPressed(_:)), for: .touchUpInside)
        translateButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(translateButton)
        NSLayoutConstraint.activate([
            translateButton.topAnchor.constraint(equalTo: dotButton.bottomAnchor, constant: 20),
            translateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            translateButton.widthAnchor.constraint(equalToConstant: 100),
            translateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Play Button
        playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: translateButton.bottomAnchor, constant: 20),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Function to translate Morse code to English
    func translateToEnglish(morseCode: String) -> String {
        var englishText = ""
        let morseToEnglish = invertDictionary(dict: morseCodeDictionary)
        let characters = morseCode.components(separatedBy: " ")
        
        for char in characters {
            if let englishChar = morseToEnglish[char] {
                englishText += englishChar
            } else {
                // Handle unrecognized Morse code characters here
                englishText += "?"
            }
        }
        return englishText
    }
    
    // Function to invert a dictionary
    func invertDictionary(dict: [String: String]) -> [String: String] {
        var invertedDict = [String: String]()
        for (key, value) in dict {
            invertedDict[value] = key
        }
        return invertedDict
    }
    
    func playMorseCode(morseCode: String) {
            var audioArray: [String] = []
            for char in morseCode {
                if char == "." {
                    audioArray.append("shortpeep")
                } else if char == "-" {
                    audioArray.append("longpeep")
                }
                // Add pause between characters
                audioArray.append("shortpause2")
            }
            
            var audioFiles: [URL] = []
            for sound in audioArray {
                if let path = Bundle.main.path(forResource: sound, ofType: "wav") {
                    let url = URL(fileURLWithPath: path)
                    audioFiles.append(url)
                }
            }
            
            var currentIndex = 0
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "MorseCodePlaybackQueue")
            
            for url in audioFiles {
                dispatchGroup.enter()
                dispatchQueue.async {
                    do {
                        let audioPlayer = try AVAudioPlayer(contentsOf: url)
                        audioPlayer.delegate = self // Assigning delegate
                        audioPlayer.prepareToPlay()
                        audioPlayer.play()
                        usleep(UInt32(audioPlayer.duration * 1_000_000)) // Sleep until sound finishes playing
                    } catch {
                        print("Error playing sound")
                    }
                    dispatchGroup.leave()
                }
                currentIndex += 1
            }
            
            dispatchGroup.notify(queue: .main) {
                print("Playback finished")
            }
        }

    
    // Actions
    @objc func dotButtonPressed(_ sender: UIButton) {
        morseTextView.text += "."
    }
    
    @objc func dashButtonPressed(_ sender: UIButton) {
        morseTextView.text += "-"
    }
    
    @objc func translateButtonPressed(_ sender: UIButton) {
        let morseCode = morseTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let translatedText = translateToEnglish(morseCode: morseCode)
        englishLabel.text = translatedText
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
            let selectedPhrase = "HELLO WORLD" // Example phrase, replace it with your phrase selection logic
            var morseCode = ""
            for char in selectedPhrase.uppercased() {
                if let code = morseCodeDictionary[String(char)] {
                    morseCode += code + " "
                }
            }
            playMorseCode(morseCode: morseCode)
        }
}
