//
//  CategoryViewModel.swift
//  CocoapodsTest
//
//  Created by 이태현 on 2021/12/22.
//

import SwiftUI

//MARK: VIEWMODEL
class CategoryViewModel: ObservableObject {
    
    @Published var posts: [PostModel] = []
    
    init() {
        getPosts()
    }
    
    func getPosts() {
        
        guard let url = URL(string: "https://raw.githubusercontent.com/ZeroFriends/GoStopCalculator/develop/app/src/main/assets/rule.json") else { return }
        
        downloadData(fromURL: url) { returnedData in
            if let data = returnedData {
                //newPost는 옵셔널 이기 때문에 guard
                guard let newPost = try? JSONDecoder().decode(PostModel.self, from: data) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.posts.append(newPost)
                    
                }
            } else {
                print("반환될 데이터가 존재하지 않습니다.")
            }
        }
    }
    
    func downloadData(fromURL url: URL, complectionHandler: @escaping (_ data: Data?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard
                let data = data,
                error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                    print("데이터 다운로드에 실패했습니다.")
                    complectionHandler(nil)
                    return
                }
            complectionHandler(data)
        }
        .resume()
        
    }
}

