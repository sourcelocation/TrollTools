//
//  DebToIPA.swift
//  TrollTools
//
//  Created by exerhythm on 21.10.2022.
//

import ArArchiveKit
import Zip
import SWCompression
import UIKit

class DebExtractor {
    private static let fm = FileManager.default
    private static var tempDir: URL { fm.temporaryDirectory }
    
    /// Extracts deb
    static func extractDeb(_ url: URL, to extractedDir: URL, statusUpdate: (String) -> ()) throws -> URL {
        statusUpdate("Reading .deb")
        let reader = try ArArchiveReader(archive: Array<UInt8>(Data(contentsOf: url)))
        var foundData = false
        for (header, dataInts) in reader {
            guard header.name.contains("data.tar") else { continue }
            let dataURL = tempDir.appendingPathComponent(header.name)
            
            // Write data to disk
            statusUpdate("Creating data from ints")
            let data = Data(dataInts)
            try data.write(to: dataURL, options: .atomic)
            
            statusUpdate("Decompressing data archive")
            let decompressedData: Data?
            switch DecompressionMethod(rawValue: header.name.components(separatedBy: ".").last ?? "") {
            case .lzma:
                foundData = true
                statusUpdate("Decompressing LZMA data.\nThis might take a while")
                decompressedData = try LZMA.decompress(data: data)
            case .gz:
                foundData = true
                statusUpdate("Unarchiving Gzip archive.\nThis might take a while")
                decompressedData = try GzipArchive.unarchive(archive:data)
            case .bzip2:
                foundData = true
                statusUpdate("Decompressing BZip2 data.\nThis might take a while")
                decompressedData = try BZip2.decompress(data:data)
            case .xz:
                foundData = true
                statusUpdate("Unarchiving XZ archive.\nThis might take a while")
                decompressedData = try XZArchive.unarchive(archive:data)
            case .none:
                throw ConversionError.unsupportedCompression
            }
            
            statusUpdate("Opening .tar")
            try decompressedData!.write(to: extractedDir.appendingPathExtension("tar"))
            let tarContainer = try TarContainer.open(container: decompressedData!)
            
            statusUpdate("Creating files")
            for entry in tarContainer {
                if entry.info.type == .directory {
                    try fm.createDirectory(at: extractedDir.appendingPathComponent(entry.info.name), withIntermediateDirectories: true)
                } else if entry.info.type == .regular {
                    try entry.data?.write(to: extractedDir.appendingPathComponent(entry.info.name))
                } else if entry.info.type == .symbolicLink {
                    try fm.createSymbolicLink(at: extractedDir.appendingPathComponent(entry.info.name), withDestinationURL: URL(fileURLWithPath: entry.info.linkName))
                } else {
                    throw ConversionError.unknownFiletypeInsideTar
                }
                print(entry.info)
            }
        }
        
        if !foundData {
            throw ConversionError.noDataFound
        }
        return extractedDir
    }
    
    static func cleanup() throws {
        for url in try fm.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil) {
            try fm.removeItem(at: url)
        }
    }
}

enum DecompressionMethod: String {
    case gz, lzma, bzip2, xz
}

enum ConversionError: Error {
    case noDataFound
    case noPermission
    case unknownFiletypeInsideTar
    case unsupportedCompression
}
