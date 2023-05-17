//
//  SegmentView.swift
//  MessageModule
//
//  Created by iOS on 2023/5/8.
//

import SwiftUI

//class SegmentDataSource: ObservableObject {
//    @Published
//}

struct SegmentView: View {
    @State var selection: Int = 0
    
    var titles: [String]
    var views: [AnyView]
    
    init(titles: [String], views: [AnyView]) {
        self.titles = titles
        self.views = views
    }
    
    var body: some View {
        
        VStack(spacing: 0){
            SegmentScrollView(selection: $selection, items: titles)
            
            TabView(selection: $selection)  {
                
                ForEach(0..<views.count, id: \.self) { idx in
                    views[idx]
                        .tag(idx)
                }
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
//            .background(Color.pink)
        }
        
    }
}
struct SegmentView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentView(titles: ["Message",
                             "Calls"],
                    views: [AnyView(Text("1111")),
                            AnyView(Text("2222"))])
    }
}


struct SegmentScrollView: View {
    @Binding private var selection: Int
    private let  items: [String]
    @State private var buttonFrames: [Int: CGRect] = [:]
    
    private var containerSpace: String {
        return "showBottomLine"
    }
    
    init(selection: Binding<Int>,
         items: [String]) {
        self._selection = selection
        self.items = items
    }
    
    var body: some View {
        ScrollViewReader{ scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    buttons()
                    
                    indicatorContainer()
                        .padding(.bottom, 5)
                }
                .coordinateSpace(name: containerSpace)
            }
            .background(Color.pink)
            .onChange(of: selection, perform: { _ in
                withAnimation {
                    scrollView.scrollTo(selection, anchor: .center)
                }
            })
        }
    }
    
    private func buttons() -> some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { obj in
                Button {
                    withAnimation {
                        selection = obj.offset
                    }
                } label: {
                    Text(obj.element)
                        .font(isSelected(index: obj.offset) ? .system(size: 20, weight: .bold)  : .system(size: 15, weight: .bold))
                        .animation(.default, value: selection)
                        .foregroundColor(isSelected(index: obj.offset) ? .white : .white.opacity(0.5))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                }
                .readFrame(in: .named(containerSpace)) {
                    buttonFrames[obj.offset] = $0
                }
                .id(obj.offset)
            }
        }
    }
    
    private func indicatorContainer() -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: tabWidth(), height: 6)
            .overlay(indicator(), alignment: .center)
            .offset(x: selectionBarXOffset(), y: 0)
            .animation(.default, value: selection)
    }
    
    private func indicator() -> some View {
        Capsule()
            .fill(Color.white)
            .frame(width: 32, height: 3)
    }
    
    private func sanitizedSelection() -> Int {
        return max(0, min(items.count - 1, selection))
    }
    
    private func isSelected(index: Int) -> Bool {
        return sanitizedSelection() == index
    }
    
    private func selectionBarXOffset() -> CGFloat {
        return buttonFrames[sanitizedSelection()]?.minX ?? .zero
    }
    
    private func indicatorWidth() -> CGFloat {
        return max(tabWidth() - 32, .zero)
    }
    
    private func tabWidth() -> CGFloat {
        return buttonFrames[sanitizedSelection()]?.width ?? .zero
    }
}

extension View {
    
    public func readFrame(in space: CoordinateSpace, id: String = "BottomLine", onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color
                    .clear
                    .preference(
                        key: SegmentViewValueKey.self,
                        value: [.init(space: space, id: id): proxy.frame(in: space)])
            }
        )
        .onPreferenceChange(SegmentViewValueKey.self) {
            onChange($0[.init(space: space, id: id)] ?? .zero)
        }
    }
}

private struct SegmentViewValueKey: PreferenceKey {
    static var defaultValue: [PreferenceValueKey: CGRect] = [:]
    
    static func reduce(value: inout [PreferenceValueKey: CGRect], nextValue: () -> [PreferenceValueKey: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

private struct PreferenceValueKey: Hashable {
    let space: CoordinateSpace
    let id: String
}
