import Foundation

enum ReminderInterval: Int, CaseIterable, Identifiable, Codable {
    case oneMinute = 1
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case twoHours = 120
    case threeHours = 180
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .oneMinute: return "1 dakika"
        case .fifteenMinutes: return "15 dakika"
        case .thirtyMinutes: return "30 dakika"
        case .oneHour: return "1 saat"
        case .twoHours: return "2 saat"
        case .threeHours: return "3 saat"
        }
    }
    
    func nextOccurrences(from date: Date = Date(), workSchedule: WorkSchedule, limit: Int = 5) -> [Date] {
        let calendar = Calendar.current
        var currentDate = date
        var occurrences: [Date] = []
        
        // Maksimum 7 gün ileriye bakacağız
        for dayOffset in 0...7 {
            // Şu anki günü ve saati al
            let components = calendar.dateComponents([.weekday, .hour, .minute], from: currentDate)
            guard let weekday = components.weekday,
                  let currentHour = components.hour,
                  let currentMinute = components.minute else {
                continue
            }
            
            // Swift'in weekday'i (1 = Pazar, 2 = Pazartesi) -> WeekDay enum'una çevir
            let weekDayIndex = (weekday + 5) % 7 // Pazartesi = 0, Salı = 1, ...
            let weekDay = WeekDay.allCases[weekDayIndex]
            
            // Bu gün için çalışma saatleri var mı?
            guard let workDay = workSchedule.workDays[weekDay] else {
                // Bu gün çalışma günü değil, sonraki güne geç
                if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = calendar.startOfDay(for: nextDate)
                }
                continue
            }
            
            // Interval değerini dakika cinsinden al
            let intervalMinutes = Double(rawValue)
            
            // Günün başlangıç ve bitiş zamanlarını dakika cinsinden hesapla
            let currentTimeInMinutes = Double(currentHour * 60 + currentMinute)
            let startTimeInMinutes = Double(workDay.startHour * 60)
            let endTimeInMinutes = Double(workDay.endHour * 60)
            
            // O gün için tüm interval'ları hesapla
            var timeInMinutes = startTimeInMinutes
            
            // Eğer bugünse ve şu anki zaman başlangıç ile bitiş arasındaysa
            if dayOffset == 0 && currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes <= endTimeInMinutes {
                // Şu anki zamanı başlangıç olarak al
                timeInMinutes = currentTimeInMinutes
            }
            
            // Bitiş saatine kadar olan tüm interval'ları ekle
            while timeInMinutes <= endTimeInMinutes {
                let hour = Int(timeInMinutes) / 60
                let minute = Int(timeInMinutes) % 60
                
                if let nextTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate) {
                    // Eğer zaman şu andan sonraysa ekle
                    if nextTime > date {
                        occurrences.append(nextTime)
                        
                        // Eğer yeterli sayıda zaman bulduysak döndür
                        if occurrences.count >= limit {
                            return occurrences
                        }
                    }
                }
                
                timeInMinutes += intervalMinutes
            }
            
            // Sonraki güne geç
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = calendar.startOfDay(for: nextDate)
            }
        }
        
        return occurrences
    }
    
    // Geriye uyumluluk için eski metodu da tutalım
    func nextOccurrence(from date: Date = Date(), workSchedule: WorkSchedule) -> Date? {
        return nextOccurrences(from: date, workSchedule: workSchedule, limit: 1).first
    }
}