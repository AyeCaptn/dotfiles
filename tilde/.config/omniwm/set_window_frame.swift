import AppKit
import ApplicationServices

func fail(_ message: String, code: Int32 = 1) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(code)
}

guard CommandLine.arguments.count == 6,
      let pid = pid_t(CommandLine.arguments[1]),
      let x = Double(CommandLine.arguments[2]),
      let y = Double(CommandLine.arguments[3]),
      let width = Double(CommandLine.arguments[4]),
      let height = Double(CommandLine.arguments[5])
else {
    fail("usage: omniwm-set-frame <pid> <x> <y> <width> <height>", code: 2)
}

guard AXIsProcessTrusted() else {
    fail("omniwm-set-frame requires Accessibility permission")
}

let app = AXUIElementCreateApplication(pid)
var windowValue: CFTypeRef?
let copyError = AXUIElementCopyAttributeValue(
    app,
    kAXFocusedWindowAttribute as CFString,
    &windowValue
)
guard copyError == .success, let rawWindow = windowValue else {
    fail("unable to find focused window: \(copyError.rawValue)")
}

let window = rawWindow as! AXUIElement
var size = CGSize(width: width, height: height)
var position = CGPoint(x: x, y: y)
guard let sizeValue = AXValueCreate(.cgSize, &size),
      let positionValue = AXValueCreate(.cgPoint, &position)
else {
    fail("unable to create Accessibility geometry")
}

// Moving first mirrors the native Accessibility transaction order used by
// macOS automation and lets OmniWM observe the final resize as one update.
let positionError = AXUIElementSetAttributeValue(
    window,
    kAXPositionAttribute as CFString,
    positionValue
)
let sizeError = AXUIElementSetAttributeValue(
    window,
    kAXSizeAttribute as CFString,
    sizeValue
)
guard sizeError == .success, positionError == .success else {
    fail(
        "unable to set window frame: size=\(sizeError.rawValue) "
            + "position=\(positionError.rawValue)"
    )
}
