#!/usr/bin/env swift

import AppKit
import CoreGraphics
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resources = root.appendingPathComponent("Resources", isDirectory: true)
let iconset = resources.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let preview = resources.appendingPathComponent("AppIcon.png")

try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

struct RGBA {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    var cgColor: CGColor {
        CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

let canvasSize = CGSize(width: 1024, height: 1024)

func roundedPath(rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func strokeRoundedRect(_ context: CGContext, rect: CGRect, radius: CGFloat, color: CGColor, width: CGFloat) {
    context.addPath(roundedPath(rect: rect, radius: radius))
    context.setStrokeColor(color)
    context.setLineWidth(width)
    context.strokePath()
}

func fillRoundedRect(_ context: CGContext, rect: CGRect, radius: CGFloat, color: CGColor) {
    context.addPath(roundedPath(rect: rect, radius: radius))
    context.setFillColor(color)
    context.fillPath()
}

func drawIcon() -> NSImage {
    let image = NSImage(size: canvasSize)
    image.lockFocusFlipped(false)

    guard let context = NSGraphicsContext.current?.cgContext else {
        fatalError("Unable to create drawing context")
    }

    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)

    let bounds = CGRect(origin: .zero, size: canvasSize)
    let iconRect = bounds.insetBy(dx: 54, dy: 54)

    context.saveGState()
    context.addPath(roundedPath(rect: iconRect, radius: 210))
    context.clip()

    let gradientColors = [
        RGBA(red: 0.02, green: 0.48, blue: 0.57, alpha: 1).cgColor,
        RGBA(red: 0.08, green: 0.22, blue: 0.46, alpha: 1).cgColor,
        RGBA(red: 0.12, green: 0.12, blue: 0.18, alpha: 1).cgColor
    ] as CFArray
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: [0, 0.58, 1])!
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: iconRect.minX, y: iconRect.maxY),
        end: CGPoint(x: iconRect.maxX, y: iconRect.minY),
        options: []
    )

    context.setFillColor(RGBA(red: 1, green: 1, blue: 1, alpha: 0.13).cgColor)
    context.fillEllipse(in: CGRect(x: 116, y: 640, width: 440, height: 260))
    context.setFillColor(RGBA(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor)
    context.fillEllipse(in: CGRect(x: 520, y: 116, width: 350, height: 260))
    context.restoreGState()

    context.setShadow(offset: CGSize(width: 0, height: -18), blur: 30, color: RGBA(red: 0, green: 0, blue: 0, alpha: 0.28).cgColor)
    fillRoundedRect(
        context,
        rect: CGRect(x: 214, y: 298, width: 596, height: 378),
        radius: 54,
        color: RGBA(red: 0.95, green: 0.98, blue: 1, alpha: 0.96).cgColor
    )
    context.setShadow(offset: .zero, blur: 0, color: nil)

    fillRoundedRect(
        context,
        rect: CGRect(x: 278, y: 548, width: 314, height: 48),
        radius: 24,
        color: RGBA(red: 0.13, green: 0.24, blue: 0.31, alpha: 0.12).cgColor
    )
    fillRoundedRect(
        context,
        rect: CGRect(x: 278, y: 462, width: 372, height: 34),
        radius: 17,
        color: RGBA(red: 0.13, green: 0.24, blue: 0.31, alpha: 0.10).cgColor
    )
    fillRoundedRect(
        context,
        rect: CGRect(x: 278, y: 398, width: 250, height: 34),
        radius: 17,
        color: RGBA(red: 0.13, green: 0.24, blue: 0.31, alpha: 0.10).cgColor
    )

    let lensRect = CGRect(x: 374, y: 284, width: 314, height: 314)
    context.setShadow(offset: CGSize(width: 0, height: -12), blur: 24, color: RGBA(red: 0, green: 0, blue: 0, alpha: 0.26).cgColor)
    context.setFillColor(RGBA(red: 0.47, green: 0.88, blue: 0.92, alpha: 0.23).cgColor)
    context.fillEllipse(in: lensRect)
    context.setShadow(offset: .zero, blur: 0, color: nil)

    context.setStrokeColor(RGBA(red: 1, green: 1, blue: 1, alpha: 0.96).cgColor)
    context.setLineWidth(58)
    context.strokeEllipse(in: lensRect.insetBy(dx: 22, dy: 22))

    context.setLineCap(.round)
    context.setStrokeColor(RGBA(red: 1, green: 1, blue: 1, alpha: 0.96).cgColor)
    context.setLineWidth(74)
    context.move(to: CGPoint(x: 626, y: 318))
    context.addLine(to: CGPoint(x: 770, y: 174))
    context.strokePath()

    context.setStrokeColor(RGBA(red: 1, green: 0.80, blue: 0.23, alpha: 1).cgColor)
    context.setLineWidth(22)
    context.setLineCap(.round)

    let center = CGPoint(x: lensRect.midX, y: lensRect.midY)
    context.move(to: CGPoint(x: center.x - 82, y: center.y))
    context.addLine(to: CGPoint(x: center.x + 82, y: center.y))
    context.move(to: CGPoint(x: center.x, y: center.y - 82))
    context.addLine(to: CGPoint(x: center.x, y: center.y + 82))
    context.strokePath()

    context.setStrokeColor(RGBA(red: 1, green: 0.80, blue: 0.23, alpha: 1).cgColor)
    context.setLineWidth(20)
    strokeRoundedRect(
        context,
        rect: CGRect(x: center.x - 94, y: center.y - 94, width: 188, height: 188),
        radius: 28,
        color: RGBA(red: 1, green: 0.80, blue: 0.23, alpha: 1).cgColor,
        width: 20
    )

    strokeRoundedRect(
        context,
        rect: iconRect.insetBy(dx: 6, dy: 6),
        radius: 204,
        color: RGBA(red: 1, green: 1, blue: 1, alpha: 0.18).cgColor,
        width: 6
    )

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, size: Int, to url: URL) throws {
    guard
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: size,
            pixelsHigh: size,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
    else {
        fatalError("Unable to create bitmap")
    }

    bitmap.size = CGSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    image.draw(in: CGRect(x: 0, y: 0, width: size, height: size), from: .zero, operation: .copy, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()

    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Unable to encode PNG")
    }

    try data.write(to: url)
}

let icon = drawIcon()
try writePNG(icon, size: 1024, to: preview)

let iconSizes: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for size in iconSizes {
    try writePNG(icon, size: size.pixels, to: iconset.appendingPathComponent(size.name))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = [
    "-c", "icns",
    iconset.path,
    "-o", resources.appendingPathComponent("AppIcon.icns").path
]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    fatalError("iconutil failed with status \(process.terminationStatus)")
}

print(resources.appendingPathComponent("AppIcon.icns").path)
