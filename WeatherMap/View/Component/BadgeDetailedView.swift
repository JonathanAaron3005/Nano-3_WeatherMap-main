import SwiftUI

struct BadgeDetailedView: View {
    // MARK: - Properties
    var location: String = "McDonald, Edutown"
    var weatherDescription: String = "Heavy Rain"
    var probability: Double = 0.5
    var precipitation: Int = 3
    var temperature: Double = 35.0
    var time: String = "09.45"
    
    @State private var isDetailVisible: Bool = true
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
             
                VStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 6)
                        .cornerRadius(3)
                        .background(Color.white.frame(width: 44, height: 5).cornerRadius(4))
                        .padding(.top, 5)
                        .offset(y:-14)
                }
                
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
                        Button(action: {
                            withAnimation {
                                isDetailVisible.toggle()
                            }
                        }) {
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
                        VStack {
                            ZStack {
                                Circle()
                                    .trim(from: 0, to: 0.85)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                    .rotationEffect(Angle(degrees: -243))
                                    .frame(width: 80, height: 80)
                                Text("\(Int(probability * 100))%")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                    .offset(y: -3)
                            }
                            Image(systemName: "umbrella.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                                .offset(y: -26)
                            Text("PROBABILITY")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .offset(y: -20)
                        }
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
                        VStack {
                            ZStack {
                                Circle()
                                    .trim(from: 0, to: 0.85)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                    .rotationEffect(Angle(degrees: -243))
                                    .frame(width: 80, height: 80)
                                    .offset(y: -6)
                                Text("\(Int(temperature))°")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                    .offset(y: -6)
                            }
                            Text("C°")
                                .bold()
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .offset(y: -23)
                            Text("TEMPERATURE")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .offset(y: -18.5)
                        }
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
            .offset(y:490)
            .offset(y: isDetailVisible ? 0 : 500)
        }
    }
}

struct BadgeDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeDetailedView()
    }
}
