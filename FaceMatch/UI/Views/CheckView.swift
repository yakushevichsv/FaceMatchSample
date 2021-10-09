//
//  CheckView.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

struct CheckView: View {
    @ObservedObject var viewModel: CheckViewModel
    
    var body: some View {
        Button(action: viewModel.onPressed){
            HStack{
                Image(systemName: viewModel.systemImageName).renderingMode(.template).foregroundColor(viewModel.foregroundColor)
                if let title = viewModel.title {
                    Text(title).foregroundColor(viewModel.textForegroundColor)
                }
            }
        }
    }

}

struct CheckView_Previews: PreviewProvider {
    static var previews: some View {
        CheckView(viewModel: .init())
    }
}
