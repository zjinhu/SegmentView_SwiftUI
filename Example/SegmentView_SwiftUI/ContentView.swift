//
//  ContentView.swift
//  SegmentView_SwiftUI
//
//  Created by iOS on 2023/5/12.
//

import SwiftUI
import SegmentView_SwiftUI
struct ContentView: View {
    @StateObject var data = SegmentDataSource()
    
    var body: some View {
        SegmentView()
            .environmentObject(data)
            .onAppear{
                data.titles = ["1","2","3"]
                data.views = [AnyView(Text("1")),
                              AnyView(Text("2")),
                              AnyView(Text("3"))]
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
