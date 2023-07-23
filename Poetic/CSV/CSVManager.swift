//
//  CSVManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/22.
//

import Foundation
import CodableCSV

protocol CSVParsing {
    func parseCSV(fileName: String, fileType: String) -> [CSVPoem]
}

class CSVManager: CSVParsing {
    
    static let shared = CSVManager()
    
    private init() {}
    
    func parseCSV(fileName: String, fileType: String) -> [CSVPoem] {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("File not found")
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = CSVDecoder {
                $0.headerStrategy = .firstLine
                $0.delimiters.row = "\r\n"
                $0.nilStrategy = .empty
            }
            let result = try decoder.decode([CSVPoem].self, from: data)
            return result
        } catch {
            print("Failed to parse CSV: \(error)")
            return []
        }
    }
}
