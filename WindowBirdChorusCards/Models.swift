import Foundation

enum SoundShape: String, Codable, CaseIterable, Identifiable, Hashable {
    case trill
    case chirpPair
    case fallingWhistle
    case chatter
    case farCall

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .trill: "Bright Trill"
        case .chirpPair: "Two-note Chirp"
        case .fallingWhistle: "Falling Whistle"
        case .chatter: "Leafy Chatter"
        case .farCall: "Far Window Call"
        }
    }

    var shortGlyph: String {
        switch self {
        case .trill: "~~~"
        case .chirpPair: "• •"
        case .fallingWhistle: "↘"
        case .chatter: "••••"
        case .farCall: "◌"
        }
    }

    var moodTip: String {
        switch self {
        case .trill: "A quick trill often feels like a wake-up shimmer. Mark where it started before the street gets loud."
        case .chirpPair: "Two short notes are easy to remember. Try counting how many pairs arrive in one minute."
        case .fallingWhistle: "A falling whistle can feel like a sliding ribbon. Note whether it came from a roofline or tree."
        case .chatter: "Busy chatter usually clusters. Save it as a neighborhood texture, not a species guess."
        case .farCall: "A far call is still useful. Let distance become part of your sound map."
        }
    }
}

enum ListenDirection: String, Codable, CaseIterable, Identifiable, Hashable {
    case north, northeast, east, southeast, south, southwest, west, northwest

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .north: "North"
        case .northeast: "Northeast"
        case .east: "East"
        case .southeast: "Southeast"
        case .south: "South"
        case .southwest: "Southwest"
        case .west: "West"
        case .northwest: "Northwest"
        }
    }

    var degrees: Double {
        switch self {
        case .north: 0
        case .northeast: 45
        case .east: 90
        case .southeast: 135
        case .south: 180
        case .southwest: 225
        case .west: 270
        case .northwest: 315
        }
    }
}

enum WeatherTag: String, Codable, CaseIterable, Identifiable, Hashable {
    case paleSun
    case cloudyWindow
    case lightRain
    case windyLeaves

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .paleSun: "Pale Sun"
        case .cloudyWindow: "Cloudy Window"
        case .lightRain: "Light Rain"
        case .windyLeaves: "Windy Leaves"
        }
    }
}

enum MoodTag: String, Codable, CaseIterable, Identifiable, Hashable {
    case curious
    case calm
    case bright
    case sleepy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .curious: "Curious"
        case .calm: "Calm"
        case .bright: "Bright"
        case .sleepy: "Sleepy"
        }
    }
}

enum ListenStatus: String, Codable, Hashable {
    case saved
    case archived
}

struct ListenCard: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var heardAt: Date
    var direction: ListenDirection
    var soundShape: SoundShape
    var weather: WeatherTag
    var mood: MoodTag
    var note: String
    var windowPhotoFilename: String?
    var status: ListenStatus

    init(
        id: UUID = UUID(),
        heardAt: Date = Date(),
        direction: ListenDirection,
        soundShape: SoundShape,
        weather: WeatherTag,
        mood: MoodTag,
        note: String,
        windowPhotoFilename: String? = nil,
        status: ListenStatus = .saved
    ) {
        self.id = id
        self.heardAt = heardAt
        self.direction = direction
        self.soundShape = soundShape
        self.weather = weather
        self.mood = mood
        self.note = note
        self.windowPhotoFilename = windowPhotoFilename
        self.status = status
    }
}

struct ListenDraft: Equatable, Hashable {
    var direction: ListenDirection = .east
    var soundShape: SoundShape = .trill
    var weather: WeatherTag = .paleSun
    var mood: MoodTag = .curious
    var note: String = ""
    var windowPhotoFilename: String?
    var pendingWindowPhotoData: Data?

    init() {}

    init(card: ListenCard) {
        direction = card.direction
        soundShape = card.soundShape
        weather = card.weather
        mood = card.mood
        note = card.note
        windowPhotoFilename = card.windowPhotoFilename
    }

    func makeCard(id: UUID = UUID(), heardAt: Date = Date()) -> ListenCard {
        ListenCard(
            id: id,
            heardAt: heardAt,
            direction: direction,
            soundShape: soundShape,
            weather: weather,
            mood: mood,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            windowPhotoFilename: windowPhotoFilename
        )
    }
}

struct BirdMoodCard: Identifiable, Equatable, Hashable {
    let shape: SoundShape
    let localIllustrationSlot: String
    let tip: String

    var id: SoundShape { shape }

    static let all: [BirdMoodCard] = SoundShape.allCases.map {
        BirdMoodCard(shape: $0, localIllustrationSlot: "illustrated bird silhouette card", tip: $0.moodTip)
    }
}

enum SoundBadgeType: String, Codable, CaseIterable, Identifiable, Hashable {
    case firstDawn
    case threeDirections
    case weekendRoost
    case archivedMemory

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .firstDawn: "First Dawn"
        case .threeDirections: "Three Directions"
        case .weekendRoost: "Weekend Roost"
        case .archivedMemory: "Archived Memory"
        }
    }

    var description: String {
        switch self {
        case .firstDawn: "Save your first private window listen."
        case .threeDirections: "Hear from three different directions."
        case .weekendRoost: "Review your map during a weekend pause."
        case .archivedMemory: "Archive a listen you no longer need on the main map."
        }
    }
}

struct SoundBadge: Identifiable, Codable, Equatable, Hashable {
    var type: SoundBadgeType
    var earnedAt: Date

    var id: SoundBadgeType { type }
}

enum VisualSlot: String, CaseIterable {
    case softDawnGradient
    case illustratedBirdSilhouetteCards
    case compassLikeDirectionRing
    case neighborhoodSoundDots
    case windowViewPhotos
}
