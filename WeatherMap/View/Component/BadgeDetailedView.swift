import SwiftUI

struct BadgeDetailedView: View {
    // MARK: - Properties
    var location: String = "McDonald, Edutown"
    var weatherDescription: String = "Heavy Rain"
    var probability: Double = 0.35
    var precipitation: Int = 3
    var temperature: Double = 26
    var time: String = "09.45"
    
    @State private var isDetailVisible: Bool = true
    
    func getTemperatureGradient() -> Gradient {
        return Gradient(stops: [
            .init(color: Color(red: 74/255, green: 157/255, blue: 255/255), location: 1.0),
            .init(color: Color(red: 14/255, green: 222/255, blue: 22/255), location: 0.59),
            .init(color: Color(red: 255/255, green: 3/255, blue: 3/255), location: 0.05)
        ])
    }
    
    func getProbabilityGradient() -> Gradient {
        return Gradient(stops: [
            .init(color: Color(red: 126/255, green: 201/255, blue: 255/255), location: 1.0),
            .init(color: Color(red: 85/255, green: 161/255, blue: 216/255), location: 0.64),
            .init(color: Color(red: 62/255, green: 120/255, blue: 227/255), location: 0.50),
            .init(color: Color(red: 0/255, green: 10/255, blue: 255/255), location: 0.0)
        ])
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
                    .offset(y: -14)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(location)
                            .font(.system(size: 22, weight: .semibold))
                        
                        Text(weatherDescription)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Button(action: { withAnimation { isDetailVisible.toggle() } }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                                .offset(x: 25, y: -16)
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
                                .foregroundColor(.gray)
                                .offset(y: -28)
                        }
                        
                        Spacer()
                        
                        GradientCircle(
                            value: temperature / 50,
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
            .offset(y: 490)
            .offset(y: isDetailVisible ? 0 : 500)
        }
    }
}

struct GradientCircle: View {
    var value: Double
    var gradient: Gradient
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
                    .stroke(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 10, lineCap: .round))
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
                .foregroundColor(.gray)
                .offset(y: -20)
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeDetailedView()
    }
}
