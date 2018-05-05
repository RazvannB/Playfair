//
//  main.swift
//  playfair
//
//  Created by Razvan Balint on 08/04/16.
//  Copyright © 2016 Razvan Balint. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}

func + (left: Character, right: Character) -> String {
    return "\(left)\(right)"
}

func + (left: String, right: Character) -> String {
    return "\(left)\(right)"
}


let cypheredText: String = "GYPRG YLYAF VUPSX HVHHZ FZXGT ZHKRB ZFKCL VKDMX BRYLS NWKHZ NXNXR FEOBW XHFRW BSNLP KHWOE FSYMX SQUT"
    .stringByReplacingOccurrencesOfString(" ", withString: "", options: .CaseInsensitiveSearch, range: nil)
let alphabet: String = "ABCDEFGHIKLMNOPQRSTUVWXYZ"
let knownWord: String = "SIGUR"
var possibleKeys = Dictionary<String, String>()

func playfair(a: Character, _ b: Character, _ table: [[Character]]) -> String {
    
    var result = String()
    
    //  Remember the current location of a and b
    var aLoc = (line: Int, column: Int)(Int(), Int())
    var bLoc = (line: Int, column: Int)(Int(), Int())
    
    for (index1, arr) in table.enumerate() {
        for (index2, char) in arr.enumerate() {
            if char == a {
                aLoc = (index1, index2)
            } else if char == b {
                bLoc = (index1, index2)
            }
        }
    }
    
    if aLoc.line == bLoc.line {
        //  If the two characters are on the same line
        if aLoc.column == 0 {
            result.append(table[aLoc.line][4])
        } else {
            result.append(table[aLoc.line][aLoc.column - 1])
        }
        
        if bLoc.column == 0 {
            result.append(table[bLoc.line][4])
        } else {
            result.append(table[bLoc.line][bLoc.column - 1])
        }
    } else if aLoc.column == bLoc.column {
        //  If the two charcters are on the same column
        if aLoc.line == 0 {
            result.append(table[4][aLoc.column])
        } else {
            result.append(table[aLoc.line - 1][aLoc.column])
        }
        
        if bLoc.line == 0 {
            result.append(table[4][bLoc.column])
        } else {
            result.append(table[bLoc.line - 1][bLoc.column])
        }
    } else {
        //  If the two charcters have nothing in common
        result.append(table[aLoc.line][bLoc.column])
        result.append(table[bLoc.line][aLoc.column])
    }
    
    return result
}

func decypher(table: [[Character]]) -> (status: Bool, decryptedMessage: String?) {
    
    var decryptedMessage = String()
    
    //  Generate pairs of elements (1, 2), (3, 4), etc
    let toDecrypt = Array(Zip2Sequence(
        cypheredText.characters.enumerate().filter({
            (index, char) -> Bool in
            return index % 2 == 0
        }),
        cypheredText.characters.enumerate().filter({
            (index, char) -> Bool in
            return index % 2 == 1
        })
        ))
    
    //  Actual playfair algorithm
    decryptedMessage = toDecrypt.map({ playfair($0.1, $1.1, table) }).reduce(decryptedMessage, combine: {$0 + $1} )
    
    if decryptedMessage.containsString(knownWord) {
        return (true, decryptedMessage)
    }
    
    return (false, nil)
}

//  Eliminate the duplicate characters inside a key
func simplfyKey(key: String) -> String {
    var newKey = String()
    newKey.append(key[0])
    for i in 1..<key.characters.count {
        if !key[0...i-1].characters.contains(key[i]) {
            newKey.append(key[i])
        }
    }
    
    return newKey
}

func createTable(key: String) {
    print(key)
    
    var table = [[Character]]()
    var alphabetCopy = String()
    let key = simplfyKey(key)
    
    //  Eliminate the characters in key
    for char in alphabet.characters {
        if !key.characters.contains(char) {
            alphabetCopy.append(char)
        }
    }
    
    //  Initialize 5x5 table
    for _ in 0..<5 {
        table.append([Character](count: 5, repeatedValue: "."))
    }
    
    //  Populate table
    for i in 0..<5 {
        for j in 0..<5 {
            let keyIndex = i * 5 + j
            if keyIndex < key.characters.count {
                //  First add the key...
                table[i][j] = key[keyIndex]
            } else {
                //  ...then add the remaining of the alfphabet
                table[i][j] = alphabetCopy[alphabetCopy.startIndex]
                alphabetCopy.removeAtIndex(alphabetCopy.startIndex)
            }
        }
    }
    
    //  Now we decypher the code based on the current table
    let answer = decypher(table)
    if answer.status {
        possibleKeys[key] = answer.decryptedMessage
    }
}

//  Generate all the possible keys
func bruteForce() {
    
    for i in alphabet.characters {
        for j in alphabet.characters {
            for k in alphabet.characters {
                for l in alphabet.characters {
                    
                    let key = i + j + k + l
                    createTable(key)
                    
                }
            }
        }
    }
}

func main() {
    bruteForce()
    for (key, value) in possibleKeys {
        print("\(key): \(value)")
    }
}

main()
