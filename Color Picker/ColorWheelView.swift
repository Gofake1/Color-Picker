//
//  ColorWheelView.swift
//  Color Picker
//
//  Created by David Wu on 5/4/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

protocol ColorWheelViewDelegate: class {
    func colorDidChange(_ newColor: CGColor)
}

@IBDesignable
class ColorWheelView: NSView {

    var brightness: CGFloat = 1.0 {
        didSet {
            guard oldValue != brightness else { return }
            colorWheelShouldRedraw = true
            needsDisplay = true
        }
    }
    private(set) var selectedColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    weak var delegate: ColorWheelViewDelegate?
    private var colorWheelImage: CGImage!
    private var colorWheelShouldRedraw = true
    private var crosshairLocation: CGPoint! {
        didSet {
            needsDisplay = true
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        colorWheelImage = colorWheelImage(rect: frame, brightness: brightness)
        crosshairLocation = CGPoint(x: frame.width/2, y: frame.height/2)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current()?.cgContext else { return }

        if colorWheelShouldRedraw {
            colorWheelImage = colorWheelImage(rect: dirtyRect, brightness: brightness)
            colorWheelShouldRedraw = false
        }
        context.addEllipse(in: dirtyRect)
        context.clip()
        context.draw(colorWheelImage, in: dirtyRect)

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

    func setColor(_ color: NSColor) {
        brightness = color.scaledBrightness
        selectedColor = color.cgColor
        let center = CGPoint(x: frame.width/2, y: frame.height/2)
        crosshairLocation = point(for: color.cgColor, center: center) ?? center
    }

    private func colorWheelImage(rect: NSRect, brightness: CGFloat) -> CGImage {
        let width = Int(rect.width), height = Int(rect.height)
        var imageBytes = [RGB]()
        for j in stride(from: height, to: 0, by: -1) {
            for i in 0..<width {
                imageBytes.append(RGB(coord: (i, j), center: (width/2, height/2), brightness: brightness))
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

    private func point(for color: CGColor, center: CGPoint) -> CGPoint? {
        guard let components = color.components else { return nil }
        let hsv = HSV(r: components[0], g: components[1], b: components[2])
        let angle = hsv.h * 2 * CGFloat.pi
        let distance = hsv.s * center.x
        let x = center.x + sin(angle)*distance
        let y = center.y + cos(angle)*distance
        return CGPoint(x: x, y: y)
    }

    private func setColor(at point: CGPoint) {
        selectedColor = RGB(coord: (Int(point.x), Int(point.y)),
                            center: (Int(frame.width/2), Int(frame.height/2)),
                            brightness: brightness).cgColor
        crosshairLocation = point
        delegate?.colorDidChange(selectedColor)
    }

    // MARK: - Mouse

    //TODO: Stop crosshair from leaving circle
    override func mouseDown(with event: NSEvent) {
        setColor(at: convert(event.locationInWindow, from: nil))
    }

    override func mouseDragged(with event: NSEvent) {
        setColor(at: convert(event.locationInWindow, from: nil))
    }
}
