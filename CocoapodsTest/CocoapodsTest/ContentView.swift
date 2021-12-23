//
//  ContentView.swift
//  CocoapodsTest
//
//  Created by 이태현 on 2021/12/21.
//
import SwiftUI
import Combine//비동기 처리 위한 Combine 프레임워크

//MARK: MODEL
struct Course: Hashable, Codable {
    let title: String
    let isEssential: Bool
    let script: String
}

//MARK: VIEWMODEL
class ViewModel: ObservableObject {
    @Published var courses: [Course] = []
    
    func fetch() {
        guard let url = URL(string: "https://raw.githubusercontent.com/ZeroFriends/GoStopCalculator/develop/app/src/main/assets/rule.json") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) {
            [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let courses = try JSONDecoder().decode([Course].self, from: data)
                DispatchQueue.main.async {
                    self?.courses = courses
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

//MARK: VIEW
struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.courses, id: \.self) { course in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(course.title)
                            Text(String(course.isEssential))
                            Text(course.script)
                        }
                    }
                }
            }
            .navigationTitle("조건")
            .onAppear {
                viewModel.fetch()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
