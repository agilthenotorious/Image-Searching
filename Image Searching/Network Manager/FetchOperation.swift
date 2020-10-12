//
//  FetchOperation.swift
//  Image Searching
//
//  Created by Agil Madinali on 10/11/20.
//

import Foundation

// Fetch data from a url
class FetchOperation: Operation {
    
    var section: Sections?
    var provider: Provider
    var text: String
    
    var isFinishedStored = false
    override var isFinished: Bool {
        get {
            return self.isFinishedStored
        }
        set {
            if self.isFinishedStored != newValue {
                willChangeValue(forKey: "isFinished")
                self.isFinishedStored = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    init(provider: Provider, text: String) {
        self.provider = provider
        self.text = text
    }
    
    override func start() {
        if self.isCancelled { return }
        
        let parameters = self.updateParameter(with: text, provider.parameters)
        NetworkManager.shared.request(urlString: provider.url, headers: provider.headers,
                                      parameters: parameters) { dictionary in
            if self.isCancelled { return }
            
            guard let dictionary = dictionary as? [String: Any] else {
                return
            }
            self.updateSection(provider: self.provider, dictionary: dictionary)
            self.isFinished = true
        }
    }
    
    func updateParameter(with text: String, _ dict: [String: String]) -> [String: String] {
        var parameters = dict
        
        if dict["query"] != nil {
            parameters["query"] = text
        } else if parameters["q"] != nil {
            parameters["q"] = text
        }
        return parameters
    }
    
    func updateSection(provider: Provider, dictionary: Any?) {
        guard let dictionary = dictionary as? [String: Any] else { return }
        var newSection: [ImageProtocol] = []
        
        switch provider.name {
        case Splash.name:
            guard let arrayItems = dictionary["images"] as? [[String: Any]], !arrayItems.isEmpty else { return }
            arrayItems.forEach { dictionary in
                newSection.append(SplashImageInfo(dict: dictionary))
            }
            self.section = Sections(provider: provider, dataSource: newSection)
            
        case Pexels.name:
            guard let arrayItems = dictionary["photos"] as? [[String: Any]], !arrayItems.isEmpty else { return }
            arrayItems.forEach { dictionary in
                newSection.append(PexelsImageInfo(dict: dictionary))
            }
            self.section = Sections(provider: provider, dataSource: newSection)
            
        case Pixabay.name:
            guard let arrayItems = dictionary["hits"] as? [[String: Any]], !arrayItems.isEmpty else { return }
            arrayItems.forEach { dictionary in
                newSection.append(PixabayImageInfo(dict: dictionary))
            }
            self.section = Sections(provider: provider, dataSource: newSection)
            
        default:
            break
        }
    }
}
