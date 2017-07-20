//
//  ColorWheelView.swift
//  Color Picker
//
//  Created by David Wu on 5/4/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

typealias RGB = (r: UInt8, g: UInt8, b: UInt8)

protocol ColorWheelViewDelegate: class {
    func colorDidChange(_ newColor: NSColor)
}

@IBDesignable
class ColorWheelView: NSView {

    weak var delegate: ColorWheelViewDelegate?
    /// The color in the crosshair
    private(set) var selectedColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    private var blackImage: CGImage!
    /// Used in drawing, doesn't affect `selectedColor`
    private var brightness: CGFloat = 1.0
    private var colorWheelImage: CGImage!
    private var crosshairLocation: CGPoint!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        blackImage        = blackImage(rect: frame)
        colorWheelImage   = colorWheelImage(rect: frame)
        crosshairLocation = CGPoint(x: frame.width/2, y: frame.height/2)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current()?.cgContext else { return }

        context.addEllipse(in: dirtyRect)
        context.clip()
        context.draw(colorWheelImage, in: dirtyRect)
        context.setAlpha(1-brightness)
        context.draw(blackImage, in: dirtyRect)
        context.setAlpha(1.0)

        if brightness < 0.5 {
            context.setStrokeColor(CGColor.white)
        } else {
            context.setStrokeColor(CGColor.black)
        }
        context.addEllipse(in: CGRect(origin: CGPoint(x: crosshairLocation.x-5.5, y: crosshairLocation.y-5.5),
                                      size: CGSize(width: 11, height: 11)))
        context.addLines(between: [CGPoint(x: crosshairLocation.x, y: crosshairLocation.y-8),
                                   CGPoint(x: crosshairLocation.x, y: crosshairLocation.y+8)])
        context.addLines(between: [CGPoint(x: crosshairLocation.x-8, y: crosshairLocation.y),
                                   CGPoint(x: crosshairLocation.x+8, y: crosshairLocation.y)])
        context.strokePath()
    }

    func setColor(_ newColor: NSColor, _ redrawCrosshair: Bool = true) {
        if redrawCrosshair {
            let center = CGPoint(x: frame.width/2, y: frame.height/2)
            crosshairLocation = point(for: newColor, center: center) ?? center
        }
        selectedColor = newColor
        brightness = newColor.scaledBrightness
        needsDisplay = true
    }

    private func blackImage(rect: NSRect) -> CGImage {
        let width = Int(rect.width), height = Int(rect.height)
        var imageBytes = [RGB](repeating: RGB(r: 0, g: 0, b: 0), count: width * height)
        return cgImage(bytes: &imageBytes, width: width, height: height)
    }

    private func colorWheelImage(rect: NSRect) -> CGImage {
        let width = Int(rect.width), height = Int(rect.height)
        var imageBytes = [RGB]()
        for j in stride(from: height, to: 0, by: -1) {
            for i in 0..<width {
                let color = NSColor(coord: (i, j), center: (width/2, height/2), brightness: 1.0)
                imageBytes.append(RGB(r: UInt8(color.redComponent*255),
                                      g: UInt8(color.greenComponent*255),
                                      b: UInt8(color.blueComponent*255)))
            }
        }
        return cgImage(bytes: &imageBytes, width: width, height: height)
    }

    private func cgImage(bytes: inout [RGB], width: Int, height: Int) -> CGImage {
        return CGImage(width: width,
                       height: height,
                       bitsPerComponent: 8,
                       bitsPerPixel: 24,
                       bytesPerRow: width * MemoryLayout<RGB>.size,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                       provider: CGDataProvider(data: NSData(bytes: &bytes,
                                                             length: bytes.count *
                                                                MemoryLayout<RGB>.size))!,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .defaultIntent)!
    }

    private func point(for color: NSColor, center: CGPoint) -> CGPoint? {
        let h = color.hueComponent
        let s = color.saturationComponent
        let angle = h * 2 * CGFloat.pi
        let distance = s * center.x
        let x = center.x + sin(angle)*distance
        let y = center.y + cos(angle)*distance
        return CGPoint(x: x, y: y)
    }

    /// - returns: Clamped point and boolean indicating if the point was clamped
    private func clamped(_ point: CGPoint) -> (CGPoint, Bool) {
        let centerX = frame.width/2
        let centerY = frame.height/2
        let vX = point.x - centerX
        let vY = point.y - centerY
        let distanceFromCenter = sqrt((vX*vX) + (vY*vY))
        let radius = frame.width/2
        if distanceFromCenter > radius {
            return (CGPoint(x: centerX + vX/distanceFromCenter * radius,
                            y: centerY + vY/distanceFromCenter * radius), true)
        } else {
            return (point, false)
        }
    }

    /// - postcondition: Calls `delegate`
    private func setColor(at point: CGPoint) {
        selectedColor = NSColor(coord: (Int(point.x), Int(point.y)),
                                center: (Int(frame.width/2), Int(frame.height/2)),
                                brightness: 1.0)
        delegate?.colorDidChange(selectedColor)
    }

    // MARK: - Mouse

    /// - postcondition: May call `NSWindow.makeFirstResponder`
    override func mouseDown(with event: NSEvent) {
        let (clampedPoint, wasClamped) = clamped(convert(event.locationInWindow, from: nil))
        if wasClamped {
            window?.makeFirstResponder(window?.contentView)
        } else {
            setColor(at: clampedPoint)
            crosshairLocation = clampedPoint
            needsDisplay = true
        }
    }

    override func mouseDragged(with event: NSEvent) {
        let (clampedPoint, _) = clamped(convert(event.locationInWindow, from: nil))
        setColor(at: clampedPoint)
        crosshairLocation = clampedPoint
        needsDisplay = true
    }
}
