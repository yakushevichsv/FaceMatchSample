//
//  SelectImage.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

struct SelectImageVIew: View {
    let viewModel: SelectImageViewModel
    var body: some View {
        ZStack(alignment: .leading) {
            Color.purple.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                ForEach(viewModel.options, id: \.text) { info in
                    button(info: info).buttonStyle(GradientBackgroundStyle())
                    
                }
                if let checkBoxVM = viewModel.checkBoxOptions {
                    CheckView(viewModel: checkBoxVM)
                }
                Spacer()
            }
        }
        .navigationTitle(Text(viewModel.title))
        //.navigationViewStyle(.stack)
    }
}

//MARK: - VM.Mapping
extension SelectImageVIew {
    func button(info: TextAction) -> some View {
        Button(info.text,
               action: info.action)
    }
}

struct SelectImage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectImageVIew(viewModel: .init())
        }
    }
}
