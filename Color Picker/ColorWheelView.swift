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

    private(set) var selectedColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    weak var delegate: ColorWheelViewDelegate?
    private var colorWheelImage: CGImage!
    private var colorWheelShouldRedraw = true
    private var crosshairLocation: CGPoint!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        colorWheelImage = colorWheelImage(rect: frame, brightness: selectedColor.scaledBrightness)
        crosshairLocation = CGPoint(x: frame.width/2, y: frame.height/2)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current()?.cgContext else { return }

        if colorWheelShouldRedraw {
            colorWheelImage = colorWheelImage(rect: dirtyRect, brightness: selectedColor.scaledBrightness)
            colorWheelShouldRedraw = false
        }
        context.addEllipse(in: dirtyRect)
        context.clip()
        context.draw(colorWheelImage, in: dirtyRect)

        if selectedColor.scaledBrightness < 0.5 {
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

    func setColor(_ newColor: NSColor) {
        if selectedColor.scaledBrightness != newColor.scaledBrightness {
            colorWheelShouldRedraw = true
        }
        let center = CGPoint(x: frame.width/2, y: frame.height/2)
        crosshairLocation = point(for: newColor, center: center) ?? center

        selectedColor = newColor
        needsDisplay = true
    }

    private func colorWheelImage(rect: NSRect, brightness: CGFloat) -> CGImage {
        let width = Int(rect.width), height = Int(rect.height)
        var imageBytes = [RGB]()
        for j in stride(from: height, to: 0, by: -1) {
            for i in 0..<width {
                let color = NSColor(coord: (i, j), center: (width/2, height/2), brightness: brightness)
                imageBytes.append(RGB(r: UInt8(color.redComponent*255),
                                      g: UInt8(color.greenComponent*255),
                                      b: UInt8(color.blueComponent*255)))
            }
        }
        return CGImage(width: width,
                       height: height,
                       bitsPerComponent: 8,
                       bitsPerPixel: 24,
                       bytesPerRow: width * MemoryLayout<RGB>.size,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                       provider: CGDataProvider(data: NSData(bytes: &imageBytes,
                                                             length: imageBytes.count *
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

    /// - postcondition: Calls `delegate`
    private func setColor(at point: CGPoint) {
        let centerX = frame.width/2
        let centerY = frame.height/2
        selectedColor = NSColor(coord: (Int(point.x), Int(point.y)),
                                center: (Int(centerX), Int(centerY)),
                                brightness: selectedColor.scaledBrightness)

        let vX = point.x - centerX
        let vY = point.y - centerY
        let distanceFromCenter = sqrt((vX*vX) + (vY*vY))
        let radius = frame.width/2
        if distanceFromCenter > radius {
            crosshairLocation = CGPoint(x: centerX + vX/distanceFromCenter * radius,
                                        y: centerY + vY/distanceFromCenter * radius)
        } else {
            crosshairLocation = point
        }

        needsDisplay = true
        delegate?.colorDidChange(selectedColor)
    }

    // MARK: - Mouse

    override func mouseDown(with event: NSEvent) {
        setColor(at: convert(event.locationInWindow, from: nil))
    }

    override func mouseDragged(with event: NSEvent) {
        setColor(at: convert(event.locationInWindow, from: nil))
    }
}
