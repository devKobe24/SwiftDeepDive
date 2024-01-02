//
//  Dount.swift
//  SwiftDonut
//
//  Created by Minseong Kang on 1/2/24.
//

import Foundation
import Darwin

struct Dount {
	func showDount() {
		var bigA: Double = 0
		var bigB: Double = 0
		var i: Double?
		var j: Double?
		
		var k: Int?
		
		var arrayZ: [Double] = []
		var arrayB: [Character] = []
		
		print("\u{1B}[2J")
		
		while true {
			arrayB = [Character](repeating: " ", count: 1760)
			arrayZ = [Double](repeating: 0, count: 1760)
			
			for strideJ in stride(from: 0.0, to: 6.28, by: 0.07) {
				for strideI in stride(from: 0.0, to: 6.28, by: 0.02) {
					j = strideJ
					i = strideI
					
					guard let j = j else { return }
					guard let i = i else { return }
					
					let c: Double = sin(i)
					let d: Double = cos(j)
					let e: Double = sin(bigA)
					let f: Double = sin(j)
					let g: Double = cos(bigA)
					let h: Double = d + 2
					let bigD: Double = 1 / (((c * h * e) + (f * g)) + 5)
					let l: Double = cos(i)
					let m: Double = cos(bigB)
					let n: Double = sin(bigB)
					let t: Double = ((c * h * g) - (f * e))
					
					let x: Int = Int((40 + ((30 * bigD) * ((l * h * m) - (t * n)))))
					let y: Int = Int((12 + ((15 * bigD) * ((l * h * n) + (t * m)))))
					let o: Int = Int((x + (80 * y)))
					let bigN: Int = Int(((((((8 * (((f * e) - (c * d * g))) * m) - (c * d * e)) - (f * g)) - (l * d * n)))))
					
					if y < 22, y > 0, x > 0, bigD > arrayZ[Int(o)] {
						arrayZ[Int(o)] = bigD
						let characters = "...,,,ooo000"
						let index = characters.index(characters.startIndex, offsetBy: max(0, Int(bigN)))
						arrayB[Int(o)] = characters[index]
					}
				}
			}
			
			print("\u{1B}[H", terminator: "")
			
			for elementK in 0..<1761 {
				k = elementK
				guard let k = k else { return }
				
				let charToPrint = (k % 80 == 0) ? "\n" : String(arrayB[k])
				print(charToPrint, terminator: "")
				
				bigA += 0.00005
				bigB += 0.00003
			}
			usleep(30000)
		}
	}
}
