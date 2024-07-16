import SwiftUI
import MapKit

enum TransportType: String, Hashable {
    case automobile
    case walking
    
    var mkTransportType: MKDirectionsTransportType {
        switch self {
        case .automobile:
            return .automobile
        case .walking:
            return .walking
        }
    }
}

struct CustomPicker: View {
    
    @Binding var date: Date
    @Binding var transportType: TransportType
    @State private var showingDatePicker = false
    
    @Binding var routeDisplaying: Bool
    @Binding var routes: [MKRoute]
    
    var fetchRoute: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showingDatePicker.toggle()
                }) {
                    HStack {
                        Text("Leave ")
                        Text("\(formattedDate(date: date))")
                            .bold()
                        Text(" at ")
                        Text("\(formattedTime(date: date))")
                            .bold()
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .padding()
                    .padding(.vertical, 2)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                Menu {
                    Picker("Transport Type", selection: $transportType) {
                        HStack {
                            Image(systemName: "bicycle")
                            Text("Bike")
                        }
                        .tag(TransportType.automobile)
                        
                        HStack {
                            Image(systemName: "figure.walk")
                            Text("Walk")
                        }
                        .tag(TransportType.walking)
                    }
                    .onChange(of: transportType) { _, newValue in
                        if routeDisplaying {
                            routes.removeAll()
                            fetchRoute()
                        }
                    }
                } label: {
                    HStack {
                        if transportType == .automobile {
                            Image(systemName: "bicycle")
                        } else {
                            Image(systemName: "figure.walk")
                        }
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(11)
                }
                .frame(maxWidth: 50)
                .tint(.black)
            }
            .padding()
        }
        .padding()
        .overlay(
            Group {
                if showingDatePicker {
                    VStack {
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .padding()
                        
                        Button("Done") {
                            showingDatePicker.toggle()
                        }
                        .padding(.top, 10)
                    }
                    .frame(width: 300, height: 300)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 20)
                    .overlay(
                        Button(action: {
                            showingDatePicker = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding()
                        .position(x: 290, y: 10)
                    )
                }
            }
                .padding(.top, 400)
        )
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func formattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

