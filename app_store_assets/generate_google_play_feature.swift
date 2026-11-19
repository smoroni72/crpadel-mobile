import AppKit

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: generate_google_play_feature.swift <icon> <output>\n", stderr)
    exit(1)
}

let canvas = NSImage(size: NSSize(width: 1024, height: 500))
canvas.lockFocus()

NSColor(calibratedRed: 0.04, green: 0.07, blue: 0.15, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1024, height: 500)).fill()

NSColor(calibratedRed: 0.93, green: 0.10, blue: 0.12, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: 28, height: 500)).fill()

if let icon = NSImage(contentsOfFile: CommandLine.arguments[1]) {
    icon.draw(in: NSRect(x: 72, y: 92, width: 316, height: 316),
              from: NSRect(origin: .zero, size: icon.size),
              operation: .sourceOver,
              fraction: 1)
}

let titleStyle: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 82, weight: .bold),
    .foregroundColor: NSColor.white
]
let subtitleStyle: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 34, weight: .medium),
    .foregroundColor: NSColor(calibratedWhite: 0.88, alpha: 1)
]

NSString(string: "CRPadel").draw(at: NSPoint(x: 440, y: 265), withAttributes: titleStyle)
NSString(string: "Prenota. Gioca. Scala la classifica.").draw(
    at: NSPoint(x: 444, y: 205),
    withAttributes: subtitleStyle
)

canvas.unlockFocus()

guard let tiff = canvas.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Unable to render PNG\n", stderr)
    exit(2)
}

try png.write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
