//
//  CustomButtonStyle.swift
//  
//
//  Created by Vishweshwaran on 30/10/22.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    
    var buttonColor: Color
    var cornerRadius: CGFloat = 10
    var isDisabled: Bool = false
    
    init(
        buttonColor: Color = LoadifyColors.blueAccent,
        cornerRadius: CGFloat = 10,
        isDisabled: Bool = false
    ) {
        self.buttonColor = buttonColor
        self.cornerRadius = cornerRadius
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isDisabled ? .white.opacity(0.5) : .white)
            .frame(maxWidth: Loadify.maxWidth, maxHeight: 56)
            .background(isDisabled ? buttonColor.opacity(0.5) : buttonColor)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct CustomButtonStyle_Previews: PreviewProvider {
    
    static var previews: some View {
        Button(action: {}) {
            Text("Download Now")
        }
        .padding()
        .buttonStyle(CustomButtonStyle(isDisabled: false))
    }
}
