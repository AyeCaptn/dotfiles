// Local macOS 27 Space switcher for yabai/skhd.
//
// Uses the serialized IOHID gesture technique documented by noswoosh
// (https://github.com/mmathys/noswoosh, MIT) and originally reverse-engineered
// by joshuarli/iss. This is intentionally a small command-line helper rather
// than an installed menu-bar application.

import ApplicationServices
import Foundation

func eventField(_ number: UInt32) -> CGEventField {
    unsafeBitCast(number, to: CGEventField.self)
}

let fieldCGSEventType = eventField(55)
let fieldGestureHIDType = eventField(110)
let fieldSwipeMask = eventField(115)
let fieldSwipeMotion = eventField(123)
let fieldSwipeProgress = eventField(124)
let fieldSwipePositionX = eventField(125)
let fieldSwipePositionY = eventField(126)
let fieldSwipeVelocityX = eventField(129)
let fieldSwipeVelocityY = eventField(130)
let fieldGesturePhase = eventField(132)

let cgEventGesture: Int64 = 29
let cgEventDockControl: Int64 = 30
let ioHIDEventTypeDockSwipe: Int64 = 23
let gestureMotionHorizontal: Int64 = 1
let rawIOHIDPayloadTag = 4205

enum GesturePhase: Int64 {
    case began = 1
    case changed = 2
    case ended = 4
}

func fixed1616(_ value: Double) -> Int32 {
    let fixed = Int32(truncatingIfNeeded: Int64(value * 65_536.0))
    if fixed == 0 && value != 0 { return value > 0 ? 1 : -1 }
    return fixed
}

extension Array where Element == UInt8 {
    mutating func appendLE(_ value: UInt16) {
        Swift.withUnsafeBytes(of: value.littleEndian) { append(contentsOf: $0) }
    }

    mutating func appendLE(_ value: UInt32) {
        Swift.withUnsafeBytes(of: value.littleEndian) { append(contentsOf: $0) }
    }

    mutating func appendLE(_ value: UInt64) {
        Swift.withUnsafeBytes(of: value.littleEndian) { append(contentsOf: $0) }
    }

    mutating func appendLE(_ value: Int32) {
        appendLE(UInt32(bitPattern: value))
    }
}

func ioHIDPayload(for event: CGEvent) -> [UInt8] {
    let phase = event.getIntegerValueField(fieldGesturePhase)
    let motion = event.getIntegerValueField(fieldSwipeMotion)
    let progress = event.getDoubleValueField(fieldSwipeProgress)
    let positionX = event.getDoubleValueField(fieldSwipePositionX)
    let positionY = event.getDoubleValueField(fieldSwipePositionY)
    let velocityX = event.getDoubleValueField(fieldSwipeVelocityX)
    let velocityY = event.getDoubleValueField(fieldSwipeVelocityY)
    let mask = event.getIntegerValueField(fieldSwipeMask)
    let includeVelocity = velocityX != 0 || velocityY != 0 || phase == GesturePhase.ended.rawValue

    var payload = [UInt8]()
    payload.appendLE(event.timestamp != 0 ? event.timestamp : mach_absolute_time())
    payload.appendLE(UInt64(0))
    payload.appendLE(UInt32(0))
    payload.appendLE(UInt32(0))
    payload.appendLE(UInt32(includeVelocity ? 2 : 1))

    payload.appendLE(UInt32(40))
    payload.appendLE(UInt32(23))
    payload.appendLE((UInt32(truncatingIfNeeded: phase) & 0xff) << 24)
    payload.append(contentsOf: [0, 0, 0, 0])
    payload.appendLE(fixed1616(positionX))
    payload.appendLE(fixed1616(positionY))
    payload.appendLE(Int32(0))
    payload.appendLE(UInt32(truncatingIfNeeded: mask))
    payload.appendLE(UInt16(truncatingIfNeeded: motion))
    payload.appendLE(UInt16(3))
    payload.appendLE(fixed1616(progress))

    if includeVelocity {
        payload.appendLE(UInt32(28))
        payload.appendLE(UInt32(9))
        payload.appendLE(UInt32(0))
        payload.append(contentsOf: [1, 0, 0, 0])
        payload.appendLE(fixed1616(velocityX))
        payload.appendLE(fixed1616(velocityY))
        payload.appendLE(Int32(0))
    }
    return payload
}

func augment(_ event: CGEvent) -> CGEvent? {
    guard let serialized = event.data else { return nil }
    var bytes = [UInt8](serialized as Data)
    guard bytes.count >= 4, bytes[0...3].elementsEqual([0, 0, 0, 2]) else { return nil }

    let payload = ioHIDPayload(for: event)
    bytes.append(UInt8((payload.count >> 8) & 0xff))
    bytes.append(UInt8(payload.count & 0xff))
    bytes.append(UInt8((rawIOHIDPayloadTag >> 8) & 0xff))
    bytes.append(UInt8(rawIOHIDPayloadTag & 0xff))
    bytes.append(contentsOf: payload)
    return CGEvent(withDataAllocator: nil, data: Data(bytes) as CFData)
}

let naturalScrolling = CFPreferencesCopyAppValue(
    "com.apple.swipescrolldirection" as CFString,
    kCFPreferencesAnyApplication
) as? Bool ?? true
let postingSign = naturalScrolling ? 1.0 : -1.0

func makeDockEvent(_ phase: GesturePhase, movingRight: Bool) -> CGEvent? {
    guard let event = CGEvent(source: nil) else { return nil }
    event.setIntegerValueField(fieldCGSEventType, value: cgEventDockControl)
    event.setIntegerValueField(fieldGestureHIDType, value: ioHIDEventTypeDockSwipe)
    event.setIntegerValueField(fieldGesturePhase, value: phase.rawValue)
    event.setIntegerValueField(fieldSwipeMotion, value: gestureMotionHorizontal)
    event.setDoubleValueField(
        fieldSwipeProgress,
        value: (movingRight ? -0.0001 : 0.0001) * postingSign
    )
    event.setDoubleValueField(fieldSwipePositionX, value: 0.1)
    if phase == .ended {
        event.setDoubleValueField(
            fieldSwipeVelocityX,
            value: (movingRight ? -9_999.0 : 9_999.0) * postingSign
        )
    }
    return augment(event)
}

func postPair(_ dockEvent: CGEvent) {
    guard let companion = CGEvent(source: nil) else { return }
    companion.setIntegerValueField(fieldCGSEventType, value: cgEventGesture)
    dockEvent.post(tap: .cgSessionEventTap)
    companion.post(tap: .cgSessionEventTap)
}

func switchSpace(movingRight: Bool) -> Bool {
    let events = [GesturePhase.began, .changed, .ended].compactMap {
        makeDockEvent($0, movingRight: movingRight)
    }
    guard events.count == 3 else { return false }
    events.forEach(postPair)
    return true
}

let arguments = CommandLine.arguments
guard arguments.count == 2 || arguments.count == 3,
      arguments[1] == "left" || arguments[1] == "right" else {
    FileHandle.standardError.write(Data("usage: yabai-space-switch {left|right} [count]\n".utf8))
    exit(2)
}

guard ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 27 else {
    FileHandle.standardError.write(Data("yabai-space-switch requires macOS 27 or newer\n".utf8))
    exit(2)
}

guard AXIsProcessTrusted() else {
    FileHandle.standardError.write(Data("grant yabai-space-switch Device Control and Data Access permission\n".utf8))
    exit(77)
}

let count = arguments.count == 3 ? (Int(arguments[2]) ?? 0) : 1
guard count > 0 else { exit(2) }

for step in 0..<count {
    guard switchSpace(movingRight: arguments[1] == "right") else { exit(1) }
    if step + 1 < count { usleep(20_000) }
}

// Give WindowManager time to consume the posted event data before this process
// exits. This keeps the helper dependency-free while preserving CLI semantics.
RunLoop.current.run(until: Date().addingTimeInterval(0.2))
