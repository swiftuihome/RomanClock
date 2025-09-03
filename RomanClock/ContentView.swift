//
//  ContentView.swift
//  RomanClock
//
//  Created by devlink on 2025/9/3.
//

import SwiftUI

// 包装视图，使其在不同设备上都能良好显示
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                RomanNumeralClock()
                    .padding()
            }
            .navigationTitle("罗马时钟")
        }
    }
}

#Preview {
    ContentView()
}

struct RomanNumeralClock: View {
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 罗马数字
    private let numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
    
    var body: some View {
        GeometryReader { geometry in
            let containerSize = min(geometry.size.width, geometry.size.height)
            let clockSize = containerSize * 0.95 // 时钟占容器的95%
            
            ZStack {
                // 时钟容器
                ClockView(
                    currentTime: currentTime,
                    numerals: numerals,
                    clockSize: clockSize
                )
                
                // 添加数字时间显示
                DigitalTimeView(currentTime: currentTime)
                    .offset(y: -clockSize * 0.15) // 将数字时间放在表盘上方
            }
            .frame(width: containerSize, height: containerSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onReceive(timer) { input in
            currentTime = input
        }
    }
}

// 新增数字时间显示视图
struct DigitalTimeView: View {
    let currentTime: Date
    let timeString: String
    
    init(currentTime: Date) {
        self.currentTime = currentTime
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.timeString = formatter.string(from: currentTime)
    }
    
    var body: some View {
        Text(timeString)
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
    }
}

struct ClockView: View {
    let currentTime: Date
    let numerals: [String]
    let clockSize: CGFloat
    
    // 计算指针角度
    private var secondAngle: Double {
        let seconds = Calendar.current.component(.second, from: currentTime)
        return Double(seconds) * 6.0
    }
    
    private var minuteAngle: Double {
        let minutes = Calendar.current.component(.minute, from: currentTime)
        let seconds = Calendar.current.component(.second, from: currentTime)
        return Double(minutes) * 6.0 + Double(seconds) * 0.1
    }
    
    private var hourAngle: Double {
        let hours = Calendar.current.component(.hour, from: currentTime) % 12
        let minutes = Calendar.current.component(.minute, from: currentTime)
        return Double(hours) * 30.0 + Double(minutes) * 0.5
    }
    
    var body: some View {
        let outerRingSize = clockSize * 1.05 // 外圈比时钟大5%
        let hourMarkLength = clockSize * 0.045 // 小时刻度长度
        let minuteMarkLength = clockSize * 0.025 // 分钟刻度长度
        let numeralRadius = clockSize * 0.4 // 罗马数字位置半径
        
        // 指针尺寸（基于时钟大小计算）
        let hourHandLength = clockSize * 0.225
        let minuteHandLength = clockSize * 0.325
        let secondHandLength = clockSize * 0.4
        
        ZStack {
            // 时钟外圈装饰
            Circle()
                .fill(Color(.systemGray3))
                .frame(width: outerRingSize, height: outerRingSize)
            
            // 时钟主体
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: clockSize, height: clockSize)
                .shadow(color: Color.black.opacity(0.25), radius: clockSize * 0.0375, x: 0, y: clockSize * 0.0375)
                .overlay(
                    Circle()
                        .strokeBorder(Color(.systemGray5), lineWidth: clockSize * 0.025)
                )
            
            // 罗马数字
            ForEach(0..<12, id: \.self) { index in
                Text(numerals[index])
                    .font(.system(size: clockSize * 0.06, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 1, y: 1)
                    .offset(romanNumeralOffset(for: index, radius: numeralRadius))
            }
            
            // 小时刻度
            ForEach(0..<12, id: \.self) { index in
                Rectangle()
                    .fill(Color(red: 51/255, green: 51/255, blue: 51/255))
                    .frame(width: clockSize * 0.015, height: hourMarkLength)
                    .cornerRadius(clockSize * 0.0075)
                    .offset(y: -clockSize / 2 + hourMarkLength / 2)
                    .rotationEffect(.degrees(Double(index) * 30))
            }
            
            // 分钟刻度
            ForEach(0..<60, id: \.self) { index in
                if index % 5 != 0 { // 跳过小时位置
                    Rectangle()
                        .fill(Color(red: 102/255, green: 102/255, blue: 102/255))
                        .frame(width: clockSize * 0.005, height: minuteMarkLength)
                        .cornerRadius(clockSize * 0.0025)
                        .offset(y: -clockSize / 2 + minuteMarkLength / 2)
                        .rotationEffect(.degrees(Double(index) * 6))
                }
            }
            
            // 品牌文字
            Text("Classic Timepiece")
                .font(.system(size: clockSize * 0.035, weight: .medium, design: .default))
                .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
                .tracking(2)
                .offset(y: clockSize * 0.1)
            
            // 时钟指针
            // 时针
            Rectangle()
                .fill(Color(red: 51/255, green: 51/255, blue: 51/255))
                .frame(width: clockSize * 0.025, height: hourHandLength)
                .cornerRadius(clockSize * 0.0125)
                .offset(y: -hourHandLength / 2)
                .rotationEffect(.degrees(hourAngle))
            
            // 分针
            Rectangle()
                .fill(Color(red: 85/255, green: 85/255, blue: 85/255))
                .frame(width: clockSize * 0.015, height: minuteHandLength)
                .cornerRadius(clockSize * 0.0075)
                .offset(y: -minuteHandLength / 2)
                .rotationEffect(.degrees(minuteAngle))
            
            // 秒针
            Rectangle()
                .fill(Color(red: 231/255, green: 76/255, blue: 60/255))
                .frame(width: clockSize * 0.005, height: secondHandLength)
                .cornerRadius(clockSize * 0.0025)
                .offset(y: -secondHandLength / 2)
                .rotationEffect(.degrees(secondAngle))
            
            // 中心点
            Circle()
                .fill(Color(red: 51/255, green: 51/255, blue: 51/255))
                .frame(width: clockSize * 0.045, height: clockSize * 0.045)
                .shadow(color: Color.black.opacity(0.5), radius: clockSize * 0.00625, x: 0, y: 0)
        }
    }
    
    // 计算罗马数字位置
    private func romanNumeralOffset(for index: Int, radius: CGFloat) -> CGSize {
        let angle = (Double(index) * 30 + 30) * .pi / 180
        let x = sin(angle) * radius
        let y = -cos(angle) * radius
        return CGSize(width: x, height: y)
    }
}
