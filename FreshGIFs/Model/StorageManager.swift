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
let downloadsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first


class StorageManager {
    
    static let shared = StorageManager()
    
    
    func toggleFavouriteStateOfGif(file: GPHImage) {
        
        let favouritesIds = favouriteGifs // UserDefaults.standard.stringArray(forKey: favouritesIdsKey) ?? [String]()
        
        let gifFromFile = FavouriteGif(from: file)
        
   if favouritesIds.contains(where: { $0.mediaId == gifFromFile.mediaId }), let downloadsPath = downloadsPath {
 //       if favouritesIds.contains(gifFromFile), let downloadsPath = downloadsPath {
            
            removeFavouriteGifFromUserDefaults(gif: gifFromFile)
            
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
        let favouritesIds = favouriteGifs//UserDefaults.standard.stringArray(forKey: favouritesIdsKey) ?? [String]()
        
         if favouritesIds.contains(where: { $0.mediaId == gif.mediaId }), let downloadsPath = downloadsPath {
       // if favouritesIds.contains(gif), let downloadsPath = downloadsPath {
            
            removeFavouriteGifFromUserDefaults(gif: gif)
            
            let url = downloadsPath.appendingPathComponent("\(gif.mediaId).gif")
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    func saveFile(file: GPHImage, completion: @escaping (_ success: Bool) -> Void) {
        guard let stringUrl = file.gifUrl, let url = URL(string: stringUrl) else {
            completion(false)
            return
        }
        
        let gifFromUrlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            
            if error == nil, let data = data, let downloadPath = downloadsPath {
                
                let filename = downloadPath.appendingPathComponent("\(file.mediaId).gif")
                    try! data.write(to: filename)
                    completion(true)
            } else {
                completion(false)
            }
        }
        
        gifFromUrlSession.resume()
    }
    
    func removeFile(with id: String) {
        
    }
    
    func gif(for id: String) -> UIImage? {
        guard let url = downloadsPath?.appendingPathComponent(id), let data = try? Data.init(contentsOf: url) else { return nil }
        
        return UIImage.gifImageWithData(data)
    }
    
    func saveFileInfoToUserDefaults(file: GPHImage) {
        let defaults = UserDefaults.standard

        var favGifs = favouriteGifs//defaults.array(forKey: favouriteGifsKey) ?? [FavouriteGif]()

        favGifs.append(FavouriteGif(from: file))
        
        let gifFromFIle = FavouriteGif(from: file)
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: favGifs)
        
        UserDefaults.standard.set(encodedData, forKey: favouriteGifsKey)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: .GifHasBeenLiked, object: file.mediaId)

    }
    
    var favouriteGifs: [FavouriteGif] {
        let decodedData  = UserDefaults.standard.object(forKey: favouriteGifsKey) as? Data
        
        if let decodedData = decodedData {
            return NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? [FavouriteGif] ?? [FavouriteGif]()
        } else {
            return [FavouriteGif]()
        }
    }
    
    // let giphy1 = FavouriteGif(from: gifs.first!)
//    let giphy2 = FavouriteGif(from: gifs.last!)
//    let giphies = [giphy1, giphy2]
//    
//    let encodedData = NSKeyedArchiver.archivedData(withRootObject: giphies)
//    UserDefaults.standard.set(encodedData, forKey: "favouriteGifs4")
//    
//    UserDefaults.standard.synchronize()
//    
//    let decoded  = UserDefaults.standard.object(forKey: "favouriteGifs4") as! Data
//    let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [FavouriteGif]
//    print(decodedTeams.count)
//    print(decodedTeams.first?.width)
    
    func removeFavouriteGifFromUserDefaults(gif: FavouriteGif) {
        let defaults = UserDefaults.standard
        
        var favouritesIds = favouriteGifs//defaults.stringArray(forKey: favouritesIdsKey) ?? [String]()
        
       // guard let index = favouritesIds.index(of: gif) else { return }
         guard let index = favouritesIds.index(where: { $0.mediaId == gif.mediaId }) else { return }
        
        favouritesIds.remove(at: Int(index))
        
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: favouritesIds)
        
        UserDefaults.standard.set(encodedData, forKey: favouriteGifsKey)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: .GifHasBeenLiked, object: gif.mediaId)

        
//        UserDefaults.standard.set(favouritesIds, forKey: favouriteGifsKey)
//        UserDefaults.standard.synchronize()
//        NotificationCenter.default.post(name: .GifHasBeenLiked, object: gif.mediaId)
    }
    
}
