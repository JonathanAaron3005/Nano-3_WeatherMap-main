import SwiftUI

struct BadgeView: View {
    @State private var isPressed: Bool = false
    @Binding var time: String
    @Binding var icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(time)
                .font(.subheadline)
                .foregroundColor(.white)
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .symbolRenderingMode(.monochrome)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isPressed ? Color(red: 1/255, green: 60/255, blue: 255/255) : Color(red: 1/255, green: 60/255, blue: 255/255).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(radius: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(isPressed ? Color.white : Color.clear, lineWidth: 4)
        )
        .overlay(
            Triangle()
                .fill(isPressed ? Color(red: 1/255, green: 60/255, blue: 255/255) : Color(red: 1/255, green: 60/255, blue: 255/255).opacity(0.8))
                .frame(width: 20, height: 10)
                .offset(y: 10)
                .overlay(
                    
                    Triangle()
                        .stroke(isPressed ? Color.white : Color.clear, lineWidth: 3)
                        .frame(width: 20, height: 10)
                        .offset(y: 10)
                    
                )
            , alignment: .bottom
        )
        .scaleEffect(isPressed ? 1.5 : 1.0)
        .onTapGesture {
            withAnimation {
                isPressed.toggle()

            }
        }
    }
    
    
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView(time: .constant("16.00"), icon: .constant("cloud.rain.fill"))
    }
}

