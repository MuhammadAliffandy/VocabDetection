//
//  AppOptionPicker.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 08/06/26.
//

import SwiftUI

struct AppOptionPicker: View {
    
    @Binding  var selectedPeriod: String
    var options: Array<String> = ["Tanggal", "Bulan", "Tahun"]
    
    var body: some View {
        AppWrapDropdown(
            parent: {
                Picker("Select Period", selection: $selectedPeriod) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .tag(option)
                           
                    }
                }
                .labelsHidden()
                .tint(.black)
            },
            child: {
                HStack{
                    AppText(
                        text: selectedPeriod,
                        fontStyle: .appSubheadline,
                        textColor: .black
                    )
                    
                    AppImage(
                        image: AppIcon.ChevronRightIcon
                    )
                }
            }
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
            @State private var previewPeriod = "Tanggal"
            
            var body: some View {
                VStack(spacing: 20) {
 
                    AppOptionPicker(selectedPeriod: $previewPeriod
                    ,options:  ["Tanggal", "Bulan", "Tahun"]
                    )
                    
                    Text("Parent State Value: \(previewPeriod)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding()
                .onChange(of: previewPeriod) { _, newValue in
                    print("The user changed the period to: \(newValue)")
                }
            }
        }
        
        return PreviewWrapper()
}
