//
//  StorageManager.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 28/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit
import GiphyCoreSDK

let favouriteGifsKey = "favouritesGifs"
let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first


class StorageManager {
    
    static let shared = StorageManager()
    
    var favouriteGifs: [FavouriteGif] {
        if let decodedData = UserDefaults.standard.object(forKey: favouriteGifsKey) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? [FavouriteGif] ?? [FavouriteGif]()
        } else {
            return [FavouriteGif]()
        }
    }
    
    func toggleFavouriteStateOfGif(file: GPHImage) {
        let gifFromFile = FavouriteGif(from: file)
        
        if favouriteGifs.contains(where: { $0.mediaId == gifFromFile.mediaId }), let downloadsPath = documentPath {
            removeFavouriteGifFromUserDefaults(withId: file.mediaId)
            
            let url = downloadsPath.appendingPathComponent("\(file.mediaId).gif")
            try? FileManager.default.removeItem(at: url)
        } else {
            saveFile(file: file) { success in
                guard success else { return }
                self.saveFileInfoToUserDefaults(file: file)
            }
        }
    }
    
    func removeFavouriteGif(gif: FavouriteGif) {
        if favouriteGifs.contains(where: { $0.mediaId == gif.mediaId }), let downloadsPath = documentPath {
            removeFavouriteGifFromUserDefaults(withId: gif.mediaId)
            
            let url = downloadsPath.appendingPathComponent("\(gif.mediaId).gif")
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    // MARK: - Saving GIF File
    
    private func saveFile(file: GPHImage, completion: @escaping (_ success: Bool) -> Void) {
        guard let stringUrl = file.gifUrl, let url = URL(string: stringUrl) else {
            completion(false)
            return
        }
        
        let gifFromUrlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            
            if error == nil, let data = data, let downloadPath = documentPath {
                let filename = downloadPath.appendingPathComponent("\(file.mediaId).gif")
                completion((try? data.write(to: filename)) != nil)
            } else {
                completion(false)
            }
        }
        
        gifFromUrlSession.resume()
    }
    
    // MARK: - User Defaults
    
    private func saveFileInfoToUserDefaults(file: GPHImage) {
        var gifs = favouriteGifs
        gifs.append(FavouriteGif(from: file))
        updateUserDefaults(with: gifs)
        
        NotificationCenter.default.post(name: .gifHasBeenLiked, object: file.mediaId)
    }
    
    private func removeFavouriteGifFromUserDefaults(withId mediaId: String) {
        guard let index = favouriteGifs.index(where: { $0.mediaId == mediaId }) else { return }
        
        var gifs = favouriteGifs
        gifs.remove(at: Int(index))
        updateUserDefaults(with: gifs)
        
        NotificationCenter.default.post(name: .gifHasBeenLiked, object: mediaId)
    }
    
    private func updateUserDefaults(with gifs: [FavouriteGif]) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: gifs)
        UserDefaults.standard.set(encodedData, forKey: favouriteGifsKey)
    }
    
}
