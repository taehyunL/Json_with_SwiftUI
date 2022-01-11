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
    let name: String
    let isEssential: Bool
    let script: String
}

//MARK: VIEWMODEL
class ViewModel: ObservableObject {
    @Published var courses: [Course] = []
    var cancellables = Set<AnyCancellable>()
    
    var urlString = "https://raw.githubusercontent.com/ZeroFriends/GoStopCalculator/develop/app/src/main/assets/rule.json"
    
    init() {
        add()
    }
    
    func add() {
        fetch()
    }
    
    func getCourseList() -> [Course] {
        return courses
    }
    
    func fetch() {
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else {
                          throw URLError(.badServerResponse)
                      }
                return data
            }
            .decode(type: [Course].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Completion: \(completion)")
            } receiveValue: { [weak self] receivedValue in
                self?.courses = receivedValue
            }
            .store(in: &cancellables)
    }
    
}

//MARK: VIEW
struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.getCourseList(), id: \.self) { course in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(course.name)
                            Text(String(course.isEssential))
                            Text(course.script)
                        }
                    }
                }
            }
            .navigationTitle("조건")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
