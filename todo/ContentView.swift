import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
}

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var newTask: String = ""

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text("📝 Sticky Note")
                    .font(.headline)
                    .foregroundColor(.white)

                TextField("Enter new task", text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if !newTask.trimmingCharacters(in: .whitespaces).isEmpty {
                            tasks.append(Task(title: newTask))
                            newTask = ""
                        }
                    }

                List {
                    ForEach($tasks) { $task in
                        HStack {
                            Button(action: {
                                task.isCompleted.toggle()
                            }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            Text(task.title)
                                .strikethrough(task.isCompleted)
                                .foregroundColor(task.isCompleted ? .gray : .white)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { indices in
                        tasks.remove(atOffsets: indices)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .padding()
            .background(Color.clear)

            // Manually placed close button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
            .padding(.trailing, 8)
        }
        .frame(width: 250, height: 300)
        .background(Color.clear)
    }
}
