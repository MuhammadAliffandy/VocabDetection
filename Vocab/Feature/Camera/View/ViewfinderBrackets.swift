import SwiftUI

struct ViewfinderBrackets: View {
    // Kamu bisa menyesuaikan ukuran width dan height ini nanti
    // sesuai dengan proporsi aset gambar aslinya
    let iconSize: CGFloat = 50
    
    var body: some View {
        VStack {
            // Sisi Atas (Kiri & Kanan)
            HStack {
                Image("left-top")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                
                Spacer()
                
                Image("right-top")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }
            
            // Mendorong HStack atas dan bawah agar berjauhan
            Spacer()
            
            // Sisi Bawah (Kiri & Kanan)
            HStack {
                Image("left-bottom")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                
                Spacer()
                
                Image("right-bottom")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }
        }
    }
}
