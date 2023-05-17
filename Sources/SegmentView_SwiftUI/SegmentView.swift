//
//  SegmentView.swift
//  MessageModule
//
//  Created by iOS on 2023/5/8.
//

import SwiftUI

public class SegmentDataSource: ObservableObject {
    public init() {}
    @Published public var selectIndex: Int = 0
    @Published public var titles: [String] = []
    @Published public var views: [AnyView] = []
    
    @Published public var segmentColor: Color = .orange
    @Published public var indicatorColor: Color = .red
    @Published public var indicatorHeight: CGFloat = 4
    @Published public var indicatorWidth: CGFloat = 36
    @Published public var indicatorPadding: CGFloat = 2
    
    @Published public var titleNor: Font = .system(size: 15, weight: .bold)
    @Published public var titleSel: Font = .system(size: 20, weight: .bold)
    @Published public var titleNorColor: Color = .white.opacity(0.5)
    @Published public var titleSelColor: Color = .white
}

public struct SegmentView: View {
    @EnvironmentObject var dataSource: SegmentDataSource
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0){
            SegmentScrollView()
            
            TabView(selection: $dataSource.selectIndex)  {
                
                ForEach(0..<dataSource.views.count, id: \.self) { idx in
                    dataSource.views[idx]
                        .tag(idx)
                }
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

struct SegmentScrollView: View {
    @EnvironmentObject var dataSource: SegmentDataSource
    
    @State private var buttonFrames: [Int: CGRect] = [:]
    
    private var containerSpace: String {
        return "showBottomLine"
    }

    var body: some View {
        ScrollViewReader{ scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    buttons()
                    
                    indicatorContainer()
                        .padding(.bottom, dataSource.indicatorPadding)
                }
                .coordinateSpace(name: containerSpace)
            }
            .background(dataSource.segmentColor)
            .onChange(of: dataSource.selectIndex, perform: { _ in
                withAnimation {
                    scrollView.scrollTo(dataSource.selectIndex, anchor: .center)
                }
            })
        }
    }
    
    private func buttons() -> some View {
        HStack(spacing: 0) {
            ForEach(Array(dataSource.titles.enumerated()), id: \.offset) { obj in
                Button {
                    withAnimation {
                        dataSource.selectIndex = obj.offset
                    }
                } label: {
                    Text(obj.element)
                        .font(isSelected(index: obj.offset) ? dataSource.titleSel : dataSource.titleNor)
                        .animation(.default, value: dataSource.selectIndex)
                        .foregroundColor(isSelected(index: obj.offset) ? dataSource.titleSelColor : dataSource.titleNorColor)
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
            .frame(width: tabWidth(), height: dataSource.indicatorHeight)
            .overlay(indicator(), alignment: .center)
            .offset(x: selectionBarXOffset())
            .animation(.default, value: dataSource.selectIndex)
    }
    
    private func indicator() -> some View {
        Capsule()
            .fill(dataSource.indicatorColor)
            .frame(width: dataSource.indicatorWidth, height: dataSource.indicatorHeight)
    }
    
    private func sanitizedSelection() -> Int {
        return max(0, min(dataSource.titles.count - 1, dataSource.selectIndex))
    }
    
    private func isSelected(index: Int) -> Bool {
        return sanitizedSelection() == index
    }
    
    private func selectionBarXOffset() -> CGFloat {
        return buttonFrames[sanitizedSelection()]?.minX ?? .zero
    }
    
    private func indicatorWidth() -> CGFloat {
        return max(tabWidth() - dataSource.indicatorWidth, .zero)
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
