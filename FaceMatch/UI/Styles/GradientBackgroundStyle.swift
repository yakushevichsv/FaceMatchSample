//
//  GradientBackgroundStyle.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

struct GradientBackgroundStyle: ButtonStyle {
 
    var startColor: Color = .green
    var endColor: Color = .accentColor.opacity(0.8)
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 40
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(foregroundColor)
            .background(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .leading, endPoint: .trailing).opacity(configuration.isPressed ? 0.5 : 1))
            .cornerRadius(cornerRadius) //kind of clip shape...
            .padding(.horizontal, ceil(0.5 * cornerRadius))
            //.clipShape(Capsule())
            .shadow(radius: 10)
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

/*struct GrowingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}*/
