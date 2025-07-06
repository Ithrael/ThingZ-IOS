import SwiftUI

struct AddContainerView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var selectedType = ContainerType.wardrobe
    @State private var location = ""
    @State private var capacity = 50
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("容器名称", text: $name)
                    
                    Picker("容器类型", selection: $selectedType) {
                        ForEach(ContainerType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    
                    TextField("存放位置", text: $location)
                    
                    Stepper("容量: \(capacity)", value: $capacity, in: 1...1000)
                }
                
                Section(header: Text("容器图片")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(10)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("点击添加图片")
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 100)
                        }
                    }
                }
            }
            .navigationTitle("添加容器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveContainer()
                    }
                    .disabled(name.isEmpty || location.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func saveContainer() {
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        let container = Container(
            name: name,
            type: selectedType,
            location: location,
            capacity: capacity,
            coverImageData: imageData
        )
        
        dataManager.addContainer(container)
        presentationMode.wrappedValue.dismiss()
    }
}



#Preview {
    AddContainerView()
        .environmentObject(DataManager.shared)
} 