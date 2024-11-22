//
//  SwiftUIView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 15/11/2024.
//

import SwiftUI

struct CalendarView: View {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    let requests = [
        Request(id: "1", date: Date().addingTimeInterval(86400), isUrgent: false, isMyRequest: true, requesterName: "Alice"),
        Request(id: "2", date: Date().addingTimeInterval(172800), isUrgent: true, isMyRequest: false, requesterName: "Bob"),
        Request(id: "3", date: Date().addingTimeInterval(259200), isUrgent: false, isMyRequest: false, requesterName: "Charlie"),
        Request(id: "4", date: Date().addingTimeInterval(345600), isUrgent: true, isMyRequest: true, requesterName: "David")
    ]
    
    @State private var selectedDate: Date? = nil
    @State private var currentDate: Date = Date()
    @State private var requestDetails: Request?
    @State private var showCreateRequestModal = false
    
    var body: some View {
        ZStack {
            VStack {
                // Calendar Header
                HStack {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(ColorPalette.charcoalGray)
                    }
                    
                    Text(getCurrentWeek())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.sageGreen)
                    
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                            .font(.title)
                            .foregroundColor(ColorPalette.charcoalGray)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack {
                        // Week Grid
                        VStack {
                            ForEach(daysInCurrentWeek(), id: \.self) { day in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(requestForDate(day.date) != nil ? ColorPalette.rustyRed : ColorPalette.sand, lineWidth: 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(requestForDate(day.date) != nil ? ColorPalette.powderBlue : ColorPalette.sand)
                                        )
                                        .padding(.horizontal)
                                    
                                    HStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(requestForDate(day.date) != nil ? ColorPalette.blushPink : (day.isWeekend ? ColorPalette.sageGreen : ColorPalette.blushPink))
                                                .frame(width: 80, height: 80)
                                            
                                            VStack {
                                                Text(getShortenedWeekdayName(for: day.date))
                                                    .font(.subheadline)
                                                    .foregroundColor(requestForDate(day.date) != nil ? ColorPalette.charcoalGray : .black)
                                                
                                                Text("\(day.day)")
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(requestForDate(day.date) != nil ? .black :  day.isWeekend ? .white : .black)
                                                    .padding(.top, 2)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            if let request = requestForDate(day.date) {
                                                HStack {
                                                    Text(request.requesterName)
                                                        .font(.subheadline)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.blue)
                                                    
                                                    if request.isUrgent {
                                                        Text("‼️ Urgent!")
                                                            .foregroundColor(.red)
                                                            .font(.subheadline)
                                                    }
                                                }
                                                
                                                Text("Request: \(request.isUrgent ? "Emergency!" : "Normal")")
                                                    .font(.subheadline)
                                                    .foregroundColor(request.isUrgent ? .red : .black)
                                                    .padding(.top, 2)
                                            }
                                        }
                                        .frame(width: 180, alignment: .leading)
                                    }
                                    .padding(.horizontal)
                                }
                                .onTapGesture {
                                    if let request = requestForDate(day.date) {
                                        print(request)
                                        self.requestDetails = request
                                        print(self.requestDetails)
                                        print(self.requestDetails?.requesterName)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 20)  // Make space for the TabBar
                
            }
            
            VStack {
                Spacer()
                // Floating Action Button (FAB)
                HStack {
                    Spacer()
                    Button(action: {
                        showCreateRequestModal.toggle()
                    }) {
                        Circle()
                            .fill(ColorPalette.rustyRed)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("+")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 45)
                    .padding(.trailing, 40)
                }
            }
        }
        .sheet(item: $requestDetails) { request in
            RequestDetailView(request: request)
        }
        .sheet(isPresented: $showCreateRequestModal) {
            NewRequestView()
        }
    }
    
    func requestForDate(_ date: Date) -> Request? {
        return requests.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
    }
    
    func daysInCurrentWeek() -> [Day] {
        var days: [Day] = []
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            days.append(Day(day: calendar.component(.day, from: date), date: date, isWeekend: calendar.isDateInWeekend(date)))
        }
        
        return days
    }
    
    func getCurrentWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return "\(formatter.string(from: currentDate))"
    }
    
    func getShortenedWeekdayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    func previousWeek() {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) {
            withAnimation {
                currentDate = newDate
            }
        }
    }
    
    func nextWeek() {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) {
            withAnimation {
                currentDate = newDate
            }
        }
    }
}

struct NewRequestView: View {
    var body: some View {
        VStack {
            Text("Create New Request")
                .font(.title)
                .fontWeight(.bold)
            Button(action: {
                // Handle new request creation
            }) {
                Text("Submit Request")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(ColorPalette.rustyRed)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct RequestDetailView: View {
    let request: Request
    
    var body: some View {
        VStack {
            Text("Request Details")
                .font(.title)
                .fontWeight(.bold)
            Text("Requester: \(request.requesterName)")
            Text("Urgent: \(request.isUrgent ? "Yes" : "No")")
            Text("Date: \(request.date, style: .date)")
        }
        .padding()
    }
}
