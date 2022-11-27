//
//  ContentView.swift
//  Orbital
//
//  Created by James Zhao on 10/28/22.
//

import SwiftUI
import Numerics

struct Satellite {
}

class Value: ObservableObject {
    @Published var value:Float = 0
    
    func advance() {
        value = value + 0.1
        value = value > .pi*2 ? value - .pi*2 : value
    }
}

func CalcEclipse(_ offset: CGFloat,
                 scale speed_scale: CGFloat,
                 major major_radius: CGFloat,
                 minor minor_radius: CGFloat,
                 screen screen_size : CGSize,
                 obj obj_size: CGSize) -> CGPoint {
    let x = sin(offset * speed_scale) * minor_radius + screen_size.width/2 - obj_size.width
    let y = cos(offset * speed_scale) * major_radius + screen_size.height/2 - obj_size.height
    
    return CGPoint(x: x, y: y)
}

func AddNewOrbit(size entity_size : CGFloat,
                 speed speed_scale: CGFloat,
                 canvas_ratio y_scale: CGFloat,
                 major major_radius: CGFloat,
                 minor minor_radius: CGFloat,
                 size canvas_size: CGSize,
                 context canvas_context: GraphicsContext,
                 offset offset_obj: Value,
                 color entity_color: Color)  -> Void {
    let c_size = canvas_size.applying(CGAffineTransform(scaleX: entity_size, y: entity_size * y_scale))
    let origin = CalcEclipse(CGFloat(offset_obj.value), scale: speed_scale, major: major_radius, minor: minor_radius, screen: canvas_size, obj: c_size)
    canvas_context.fill(
                Path(ellipseIn: CGRect(origin: origin, size: c_size)),
                with: .color(entity_color))
}

struct SubView: View {
    @StateObject var ang = Value()
    let obj_size = 0.02
    let date: Date // just by declaring it, the view will now be recomputed apropriately.
    
    var body: some View {
        Canvas { context, size in
            let screen_ratio = size.width/size.height
            AddNewOrbit(size: obj_size, speed: 0.5, canvas_ratio: screen_ratio, major: 180, minor: 80, size: size, context: context, offset:ang, color: Color.blue)
            AddNewOrbit(size: obj_size, speed: 1, canvas_ratio: screen_ratio, major: 380, minor: 140, size: size, context: context, offset:ang, color: Color.green)
        }
        .border(.green, width: CGFloat(0))
        .onChange(of: date) { _ in
            ang.advance()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { timeline in
            SubView(date: timeline.date)
        }
        .background(.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
