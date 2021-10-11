//
//  SelectImage.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

struct SelectImageVIew: View {
    @ObservedObject var viewModel: SelectImageViewModel
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 20) {
                ForEach(viewModel.options) { option in
                    button(option: option).buttonStyle(GradientBackgroundStyle())
                    .onTapGesture {
                        viewModel.onTapGesture(option: option)
                    }.sheet(isPresented: .init(get: {
                        viewModel.showSheet
                    }, set: { newValue in
                        viewModel.showSheet = newValue
                    })) {
                        viewModel.onDismiss(optin: option)
                    } content: {
                        viewModel.coordinator.view(option: option)
                    }
                }
                CheckView(viewModel: viewModel.checkBoxOptions)
                Spacer()
            }
        }
        .scaleEffect(viewModel.animated ? 1 : 0)
        .animation(.easeInOut(duration: 0.5),
                        value: viewModel.animated)
        .onAppear(perform: {
            viewModel.onAppear()
        })
        .navigationTitle(Text(viewModel.title))
    }
}

//MARK: - VM.Mapping
extension SelectImageVIew {
    func button(option: SelectionImageOption) -> some View {
        NavigationLink(option.localizedTitle) {
            viewModel.coordinator.view(option: option)
        }
    }
}

struct SelectImage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectImageVIew(viewModel: .init(animated: true))
        }
    }
}
