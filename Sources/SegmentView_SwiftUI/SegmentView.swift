//
//  SegmentView.swift
//  Example
//
//  Created by iOS on 2023/5/18.
//

import SwiftUI

public struct SegmentView<Content: View>: View {
    @State private var selectIndex: Int = 0
    private let titles: [String]
    private let content: (String) -> Content
    private var segmentBackColor: Color
    private var segmentPaddingHorizontal: CGFloat
    private var segmentPaddingVertical: CGFloat
    private var indicatorColor: Color
    private var indicatorHeight: CGFloat
    private var indicatorWidth: CGFloat
    private var indicatorPaddingBottom: CGFloat
    private var titleUnSelectedFont: Font
    private var titleSelectedFont: Font
    private var titleUnSelectedColor: Color
    private var titleSelectedColor: Color
    
    public init(selectIndex: Int = 0,
                titles: [String],
                segmentBackColor: Color = .white,
                segmentPaddingHorizontal: CGFloat = 20,
                segmentPaddingVertical: CGFloat = 5,
                indicatorColor: Color = .red,
                indicatorHeight: CGFloat = 4,
                indicatorWidth: CGFloat = 36,
                indicatorPaddingBottom: CGFloat = 2,
                titleUnSelectedFont: Font = .system(size: 15, weight: .bold),
                titleSelectedFont: Font = .system(size: 20, weight: .bold),
                titleUnSelectedColor: Color = .black.opacity(0.5),
                titleSelectedColor: Color = .black,
                @ViewBuilder content: @escaping (String) -> Content) {
        
        self.titles = titles
        self.selectIndex = selectIndex
        self.content = content
        self.segmentBackColor =  segmentBackColor
        self.segmentPaddingHorizontal =  segmentPaddingHorizontal
        self.segmentPaddingVertical =  segmentPaddingVertical
        self.indicatorColor =  indicatorColor
        self.indicatorHeight =  indicatorHeight
        self.indicatorWidth =  indicatorWidth
        self.indicatorPaddingBottom =  indicatorPaddingBottom
        self.titleUnSelectedFont =  titleUnSelectedFont
        self.titleSelectedFont =  titleSelectedFont
        self.titleUnSelectedColor =  titleUnSelectedColor
        self.titleSelectedColor =  titleSelectedColor
    }
    
    public var body: some View {
        VStack(spacing: 0){
            SegmentScrollView(selectIndex: $selectIndex,
                              titles: titles,
                              segmentBackColor: segmentBackColor,
                              segmentPaddingHorizontal: segmentPaddingHorizontal,
                              segmentPaddingVertical: segmentPaddingVertical,
                              indicatorColor: indicatorColor,
                              indicatorHeight: indicatorHeight,
                              indicatorWidth: indicatorWidth,
                              indicatorPaddingBottom: indicatorPaddingBottom,
                              titleUnSelectedFont: titleUnSelectedFont,
                              titleSelectedFont: titleSelectedFont,
                              titleUnSelectedColor: titleUnSelectedColor,
                              titleSelectedColor: titleSelectedColor)
            
            TabView(selection: $selectIndex) {
                
                ForEach(Array(zip(titles.indices, titles)), id: \.0) { idx, title in
                    content(title)
                        .tag(idx)
                }
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

struct SegmentScrollView: View {
    @Binding private var selectIndex: Int
    private let titles: [String]
    private var segmentBackColor: Color
    private var segmentPaddingHorizontal: CGFloat
    private var segmentPaddingVertical: CGFloat
    private var indicatorColor: Color
    private var indicatorHeight: CGFloat
    private var indicatorWidth: CGFloat
    private var indicatorPaddingBottom: CGFloat
    private var titleUnSelectedFont: Font
    private var titleSelectedFont: Font
    private var titleUnSelectedColor: Color
    private var titleSelectedColor: Color
    
    @State private var buttonFrames: [Int: CGRect] = [:]
    
    private var containerSpace: String {
        return "showBottomLine"
    }
    
    init(selectIndex: Binding<Int>,
         titles: [String],
         segmentBackColor: Color,
         segmentPaddingHorizontal: CGFloat,
         segmentPaddingVertical: CGFloat,
         indicatorColor: Color,
         indicatorHeight: CGFloat,
         indicatorWidth: CGFloat,
         indicatorPaddingBottom: CGFloat,
         titleUnSelectedFont: Font,
         titleSelectedFont: Font,
         titleUnSelectedColor: Color,
         titleSelectedColor: Color) {
        
        self._selectIndex = selectIndex
        self.titles = titles
        self.segmentBackColor = segmentBackColor
        self.segmentPaddingHorizontal = segmentPaddingHorizontal
        self.segmentPaddingVertical = segmentPaddingVertical
        self.indicatorColor = indicatorColor
        self.indicatorHeight = indicatorHeight
        self.indicatorWidth = indicatorWidth
        self.indicatorPaddingBottom = indicatorPaddingBottom
        self.titleUnSelectedFont = titleUnSelectedFont
        self.titleSelectedFont = titleSelectedFont
        self.titleUnSelectedColor = titleUnSelectedColor
        self.titleSelectedColor = titleSelectedColor
    }
    
    var body: some View {
        ScrollViewReader{ scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    buttons()
                    
                    indicatorContainer()
                        .padding(.bottom, indicatorPaddingBottom)
                }
                .coordinateSpace(name: containerSpace)
            }
            .background(segmentBackColor)
            .onChange(of: selectIndex, perform: { _ in
                withAnimation {
                    scrollView.scrollTo(selectIndex, anchor: .center)
                }
            })
        }
    }
    
    private func buttons() -> some View {
        HStack(spacing: 0) {
            ForEach(Array(titles.enumerated()), id: \.offset) { obj in
                Button {
                    withAnimation {
                        selectIndex = obj.offset
                    }
                } label: {
                    Text(obj.element)
                        .font(isSelected(index: obj.offset) ? titleSelectedFont : titleUnSelectedFont)
                        .animation(.default, value: selectIndex)
                        .foregroundColor(isSelected(index: obj.offset) ? titleSelectedColor : titleUnSelectedColor)
                        .padding(.horizontal, segmentPaddingHorizontal)
                        .padding(.vertical, segmentPaddingVertical)
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
            .frame(width: tabWidth(), height: indicatorHeight)
            .overlay(indicator(), alignment: .center)
            .offset(x: selectionBarXOffset())
            .animation(.default, value: selectIndex)
    }
    
    private func indicator() -> some View {
        Capsule()
            .fill(indicatorColor)
            .frame(width: indicatorWidth, height: indicatorHeight)
    }
    
    private func sanitizedSelection() -> Int {
        return max(0, min(titles.count - 1, selectIndex))
    }
    
    private func isSelected(index: Int) -> Bool {
        return sanitizedSelection() == index
    }
    
    private func selectionBarXOffset() -> CGFloat {
        return buttonFrames[sanitizedSelection()]?.minX ?? .zero
    }
    
    private func autoIndicatorWidth() -> CGFloat {
        return max(tabWidth() - indicatorWidth, .zero)
    }
    
    private func tabWidth() -> CGFloat {
        return buttonFrames[sanitizedSelection()]?.width ?? .zero
    }
}

extension View {
    
    func readFrame(in space: CoordinateSpace, id: String = "BottomLine", onChange: @escaping (CGRect) -> Void) -> some View {
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
