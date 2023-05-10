//
//  ContentView.swift
//  SegmentView
//
//  Created by iOS on 2023/5/10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SegmentView(titles: ["1111","2222"],
                    views: [AnyView(Text("1111")), AnyView(Text("2222"))])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
