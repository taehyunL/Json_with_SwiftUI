//
//  ContentView.swift
//  CocoapodsTest
//
//  Created by 이태현 on 2021/12/21.
//
import SwiftUI

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
            }//옵셔널 언래핑 해줘야함 조건 안맞으면 return
            
            //data가 존재한다면 이제 디코딩을 해줘야함
            do {
                let courses = try JSONDecoder().decode([Course].self, from: data)
                DispatchQueue.main.async {
                    self?.courses = courses
                }
            } catch {
                print(error)
            }//오류메세지
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
            }//onAppear를 통해여 호출해줘야함
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
