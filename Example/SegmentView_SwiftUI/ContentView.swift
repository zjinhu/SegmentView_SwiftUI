//
//  ContentView.swift
//  SegmentView_SwiftUI
//
//  Created by iOS on 2023/5/12.
//

import SwiftUI
import SegmentView_SwiftUI
struct ContentView: View {

    var body: some View {
        SegmentView(selectIndex: 0,
                    titles: ["Home","Second"],
                    indicatorColor: .blue) { title in
            Text("\(title)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
