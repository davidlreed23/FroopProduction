//
//  FroopPhotoSelectView.swift
//  FroopProof
//
//  Created by David Reed on 5/2/23.


import SwiftUI
import PhotosUI
import Photos
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine


struct FroopPhotoSelectView: View {
    
    
    
    @ObservedObject var printControl = PrintControl.shared
   
    @ObservedObject var froopDataListener = FroopDataListener.shared
   
 
    
    @ObservedObject private var viewModel: ImageGridViewModel
    @ObservedObject var froopManager = FroopManager.shared
    @State var x : CGFloat = 0
    @State var count : CGFloat
    @State var screen = UIScreen.main.bounds.width - 30
    @State var op : CGFloat = 0
    @Binding var filteredImages: [ImageItem]
    @State private var uploading = false
    @State var selectedImageIndex: Int
    @Binding var selectedImages: [ImageItem]
    @Binding var uploadedImages: [ImageItem]


    var isPassiveMode: Bool {
        return AppStateManager.shared.inProgressFroop.froopId == ""
    }


    public init(selectedImageIndex: Int, filteredImages: Binding<[ImageItem]>, viewModel: ImageGridViewModel, selectedImages: Binding<[ImageItem]>, uploadedImages: Binding<[ImageItem]>) {
        self._count = State(initialValue: CGFloat(selectedImageIndex))
        self._filteredImages = filteredImages
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.selectedImageIndex = selectedImageIndex
        self._selectedImages = selectedImages
        self._uploadedImages = uploadedImages
    }

    var body: some View {
        VStack {
            HStack(spacing: 15) {
                ForEach(filteredImages.indices, id: \.self) { index in
                    CardViewWithCheckmarkOverlay(filteredImage: filteredImages[index], uploadedImages: uploadedImages)
                        .offset(x: self.x)
                        .highPriorityGesture(DragGesture()
                            .onChanged({ (value) in
                                if value.translation.width > 0 {
                                    self.x = value.location.x
                                }
                                else{
                                    self.x = value.location.x - self.screen
                                }
                            })
                                .onEnded({ (value) in
                                    if value.translation.width > 0{
                                        if value.translation.width > ((self.screen - 80) / 6) && Int(self.count) != 0{
                                            self.count -= 1
                                            self.updateHeight(value: Int(self.count))
                                            self.x = -((self.screen + 15) * self.count)
                                        }
                                        else{

                                            self.x = -((self.screen + 15) * self.count)
                                        }
                                    }
                                    else{
                                        if -value.translation.width > ((self.screen - 80) / 6) && Int(self.count) !=  (self.filteredImages.count - 1){
                                            self.count += 1
                                            self.updateHeight(value: Int(self.count))
                                            self.x = -((self.screen + 15) * self.count)
                                        }
                                        else{
                                            self.x = -((self.screen + 15) * self.count)
                                        }
                                    }
                                })
                        )
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .offset(x: self.op)
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        //.navigationBarTitle("Froop Image Select")
        .animation(.easeInOut(duration: 0.3), value: x)
        .onAppear {
            self.op = ((self.screen + 15) * CGFloat(self.filteredImages.count / 2)) - (self.filteredImages.count % 2 == 0 ? ((self.screen + 15) / 2) : 0)
            updateSelectedImageIndexOnAppear()
        }
        // }
    }
    @ViewBuilder
    private func CardViewWithCheckmarkOverlay(filteredImage: ImageItem, uploadedImages: [ImageItem]) -> some View {
        ZStack {
            CardView(filteredImage: filteredImage, toggleImageSelection: toggleImageSelection, uploadedImages: uploadedImages)
            if filteredImage.isSelected {
                ZStack (alignment: .center){
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.blue)
                }
                .offset(x: (screen / 2) - 35, y: 220)
            }
        }
    }

    func updateSelectedImages(imageItem: ImageItem) {
        print("updateSelectedImages Function Firing")
        if imageItem.isSelected {
            selectedImages.append(imageItem)
        } else {
            selectedImages.removeAll { $0.id == imageItem.id }
        }
    }

    func updateHeight(value: Int) {
        print("updateHeight Function Firing")
        
        if value < 0 || value >= filteredImages.count {
            print("Invalid value: \(value)")
            return
        }
        
        for i in 0..<filteredImages.count {
            filteredImages[i].show = false
        }

        filteredImages[value].show = true

        var updatedImage = filteredImages[value]
        updatedImage.isSelected.toggle()
        filteredImages[value] = updatedImage
    }


    func updateSelectedImageIndexOnAppear() {
        print("updateSelectedImageIndexOnAppear Function Firing")
        DispatchQueue.main.async {
            count = CGFloat(selectedImageIndex)
            x = -((screen + 15) * count)
            updateHeight(value: Int(count))
        }
    }

    func toggleImageSelection(filteredImage: ImageItem) {
        print("toggleImageSelection Function Firing")
//        print("\(dump(filteredImages))")
        if let index = filteredImages.firstIndex(where: { $0.id == filteredImage.id }) {
            var updatedImage = filteredImages[index]

            // Check if the image is already uploaded, and if it is, do not proceed with the toggle
            if uploadedImages.contains(where: { $0.id == filteredImage.id }) {
                print("Image is already uploaded, skipping toggle")
                return
            }

            updatedImage.isSelected.toggle()
            filteredImages[index] = updatedImage
            withAnimation {
                updateSelectedImages(imageItem: updatedImage)
            }
        }
    }

}


struct CardView: View {
    var filteredImage: ImageItem
    var toggleImageSelection: (ImageItem) -> Void
    var uploadedImages: [ImageItem]
    @State private var image: UIImage?

    public init(filteredImage: ImageItem, toggleImageSelection: @escaping (ImageItem) -> Void, uploadedImages: [ImageItem]) {
            self.filteredImage = filteredImage
            self.toggleImageSelection = toggleImageSelection
            self.uploadedImages = uploadedImages // Initialize the property
        }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .opacity(uploadedImages.contains(where: { $0.id == filteredImage.id }) ? 0.5 : 1.0)
            }
        }

        .frame(width: UIScreen.main.bounds.width - 30, height: filteredImage.show ? 600 : 300)
        .background(.ultraThinMaterial)
        .cornerRadius(5)
        .onTapGesture {
            toggleImageSelection(filteredImage)
        }
        .onAppear {
            loadImage(asset: filteredImage.asset) { loadedImage in
                image = loadedImage
            }
        }
    }
    func loadImage(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFill,
            options: requestOptions
        ) { (result, _) in
            completion(result)
        }
    }
}
