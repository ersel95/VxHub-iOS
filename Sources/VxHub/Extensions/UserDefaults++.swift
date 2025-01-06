extension UserDefaults {
    private static let lastReviewRequestKey = "VxHub.lastReviewRequestDate"
    
    var lastReviewRequestDate: Date? {
        get {
            return object(forKey: Self.lastReviewRequestKey) as? Date
        }
        set {
            set(newValue, forKey: Self.lastReviewRequestKey)
        }
    }
    
    func shouldRequestReview() -> Bool {
        let currentDate = Date()
        if let lastRequestDate = lastReviewRequestDate {
            // Check if one month (30 days) has passed
            let oneMonth: TimeInterval = 30 * 24 * 60 * 60 // 30 days in seconds
            return currentDate.timeIntervalSince(lastRequestDate) >= oneMonth
        }
        return true // First time requesting review
    }
    
    func updateLastReviewRequestDate() {
        lastReviewRequestDate = Date()
    }
} 