//
//  CSVManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/22.
//

import Foundation
import CodableCSV

protocol CSVManagerDelegate {
    func parseCSV(fileName: String, fileType: String) async throws -> [CSVPoem]
}

class CSVManager: CSVManagerDelegate {
    func parseCSV(fileName: String, fileType: String) async throws -> [CSVPoem] {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            throw CSVError.fileNotFound
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = CSVDecoder {
            $0.headerStrategy = .firstLine
            $0.delimiters.row = "\r\n"
            $0.nilStrategy = .empty
        }
        let result = try decoder.decode([CSVPoem].self, from: data)
        return result
    }
}
