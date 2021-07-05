//
//  Install.swift
//  Install Templates
//
//  Created by Sameh Mabrouk on 29/06/2020.
//

import Foundation

let templates = [
    "Component and Factory.xctemplate",
    "Feature module.xctemplate"
]

let destinationRelativePath = "/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/File Templates/smapps"

let fileManager = FileManager.default

func printInConsole(_ message: Any) {
    print("====================================")
    print("\(message)")
    print("====================================")
}

func installTemplates() {
    print("Installing Templates")
    
    for template in templates {
        installTemplate(templateName: template)
    }
}

func installTemplate(templateName: String) {
    print("================ Template \(templateName) ================")
    do {
        let destinationPath = bash(command: "xcode-select", arguments: ["--print-path"]).appending(destinationRelativePath)
        
        if fileManager.fileExists(atPath: "\(destinationPath)/\(templateName)") {
            try fileManager.removeItem(atPath: destinationPath + "/\(templateName)")
            
            print("Removed existing template for \(templateName)")
        }
        
        try fileManager.createDirectory(at: URL(fileURLWithPath: destinationPath), withIntermediateDirectories: true, attributes: nil)
        try fileManager.copyItem(atPath: templateName, toPath: "\(destinationPath)/\(templateName)")
        printInConsole("✅  Template installed succesfully 🎉. Enjoy 🙂")
    } catch let error as NSError {
        printInConsole("❌  Ooops! Something went wrong 😡 : \(error.localizedFailureReason!)")
    }
    
    print("================ Finished for Template \(templateName) ================ \n\n")
}

func shell(launchPath: String, arguments: [String]) -> String {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8) ?? ""
    if !output.isEmpty {
        let lastIndex = output.index(before: output.endIndex)
        return String(output[output.startIndex ..< lastIndex])
    }
    return output
}

func bash(command: String, arguments: [String]) -> String {
    let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
    return shell(launchPath: whichPathForCommand, arguments: arguments)
}

installTemplates()
