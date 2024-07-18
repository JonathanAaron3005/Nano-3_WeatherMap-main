import SwiftUI

struct BadgeDetailedView: View {
    // MARK: - Properties
    var location: String
    var weatherDescription: String
    var probability: Double
    var precipitation: Int
    var temperature: Int
    var time: String
    
    @State private var isDetailVisible: Bool = true
    
    func getTemperatureGradient() -> AngularGradient {
        return AngularGradient(
            gradient: Gradient(stops: [
                Gradient.Stop(color: Color(red: 0.29, green: 0.62, blue: 1), location: 0.22),
                Gradient.Stop(color: Color(red: 0.05, green: 0.87, blue: 0.09), location: 0.59),
                Gradient.Stop(color: Color(red: 1, green: 0.01, blue: 0.01), location: 0.90),
            ]),
            center: UnitPoint(x: 0.5, y: 0.53),
            angle: Angle(degrees: -65)
        )
    }

    func getProbabilityGradient() -> AngularGradient {
        return AngularGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.39, green: 0.69, blue: 1), location: 0.00),
                .init(color: Color(red: 0.33, green: 0.63, blue: 0.85), location: 0.33),
                .init(color: Color(red: 0.24, green: 0.47, blue: 0.89), location: 0.66),
                .init(color: Color(red: 0, green: 0.04, blue: 1), location: 1.00),
            ]),
            center: .center,
            angle: .degrees(-65)
        )
    }

    func blackDotPosition(for value: Double) -> Angle {
        return Angle(degrees: 306 * value - 153)
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)
            
            VStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 6)
                    .cornerRadius(3)
                    .background(Color.white.frame(width: 44, height: 5).cornerRadius(4))
                    .padding(.top, 5)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(location)
                            .font(.system(size: 22, weight: .semibold))
                        
                        Text(weatherDescription)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Button(action: { withAnimation { isDetailVisible.toggle() } }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        
                        HStack(spacing: 2) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                            
                            Text(time)
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                if isDetailVisible {
                    HStack {
                        Spacer()
                        
                        GradientCircle(
                            value: probability,
                            gradient: getProbabilityGradient(),
                            label: "\(Int(probability * 100))%",
                            icon: "umbrella.fill",
                            title: "PROBABILITY"
                        )
                        
                        Spacer()
                        
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 90, height: 90)
                                Text("\(precipitation)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                    .offset(y: 3)
                            }
                            Image(systemName: "drop.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .offset(y: -75)
                            Text("MM")
                                .font(.caption)
                                .foregroundColor(.black)
                                .offset(y: -42)
                            Text("PRECIPITATION")
                                .font(.caption)
                                .foregroundColor(.black)
                                .offset(y: -28)
                        }
                        
                        Spacer()
                        
                        GradientCircle(
                            value: Double(temperature / 50),
                            gradient: getTemperatureGradient(),
                            label: "\(Int(temperature))°",
                            icon: "thermometer",
                            title: "TEMPERATURE"
                        )

                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .transition(.move(edge: .bottom))
        }
    }
}

struct GradientCircle: View {
    var value: Double
    var gradient: AngularGradient
    var label: String
    var icon: String
    var title: String
    
    func blackDotPosition(for value: Double) -> Angle {
        return Angle(degrees: 306 * value - 153)
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.85)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(Angle(degrees: -243))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: value * 0.85)
                    .stroke(gradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(Angle(degrees: -243))
                    .frame(width: 80, height: 80)
                
                Text(label)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .offset(y: -3)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(y: -40)
                    .rotationEffect(blackDotPosition(for: value))
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
                    .offset(y: -40)
                    .rotationEffect(blackDotPosition(for: value))
            }
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.black)
                .offset(y: -26)
            Text(title)
                .font(.caption)
                .foregroundColor(.black)
                .offset(y: -20)
        }
    }
}
