//
//  AutoScrollDemo.swift.swift
//
//  Created by Itsuki on 2025/11/10.
//

import SwiftUI

private struct Item: Identifiable, Equatable {
    var id = UUID()
    var content: String

}

// Approach 1: onChange + scrollViewProxy + scrollTo
struct AutoScrollDemoV1: View {
    @State private var data: [Item] = (0..<20).map({Item(content: "\($0)")})
    @State private var fontSize: CGFloat = 12
    
    var body: some View {
        NavigationStack {
            ScrollViewReader(content: { proxy in
                List {
                    ForEach(data, content: { item in
                        Text(item.content)
                            // required to give the view an identifier to scroll to
                            .id(item.id)
                    })
                }
                .defaultScrollAnchor(.bottom, for: .alignment)
                .defaultScrollAnchor(.bottom, for: .initialOffset)
                .defaultScrollAnchor(.bottom, for: .sizeChanges)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .topBarTrailing, content: {
                        Button(action: {
                            guard var last = data.last else {
                                return
                            }
                            last.content = "\(last.content)\n something new\n something new\n something new\n something new"
                            data[data.count-1] = last
                        }, label: {
                            Text("Add Content")
                        })
                        
                        Button(action: {
                            data.append(Item(content: "\(data.count)"))
                        }, label: {
                            Text("Add Item")
                        })
                    })
                })
                // data instead of data.count so that we can also scroll to the bottom when the content of an individual item changes.
                .onChange(of: self.data, initial: true, {
                    withAnimation {
                        proxy.scrollTo(data.last?.id, anchor: .bottom)
                    }
                })

            })
        }
    }
}


// Approach 2: Scroll to onScrollGeometryChange instead of onChange
// To handle cases where data is not equatable or what we are displaying is not part of the equatable implementation
struct AutoScrollDemoV2: View {
    @State private var data: [Item] = (0..<20).map({Item(content: "\($0)")})
    
    private let bottomViewId: String = "bottom"
    var body: some View {
        NavigationStack {
            ScrollViewReader(content: { proxy in
                List {
                    ForEach(data, content: { item in
                        Text(item.content)
                            .id(item.id)
                    })
                }
                .defaultScrollAnchor(.bottom, for: .alignment)
                .defaultScrollAnchor(.bottom, for: .initialOffset)
                .defaultScrollAnchor(.bottom, for: .sizeChanges)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .topBarTrailing, content: {
                        Button(action: {
                            guard var last = data.last else {
                                return
                            }
                            last.content = "\(last.content)\n something new\n something new\n something new\n something new"
                            data[data.count-1] = last
                        }, label: {
                            Text("Add Content")
                        })
                        
                        Button(action: {
                            data.append(Item(content: "\(data.count)"))
                        }, label: {
                            Text("Add Item")
                        })
                    })
                    

                })
                .onScrollGeometryChange(for: CGSize.self, of: {
                    $0.contentSize
                }, action: { _, _ in
                    withAnimation{
                        proxy.scrollTo(data.last?.id, anchor: .bottom)
                    }
                })
            })
        }
    }
}


// Approach 3: Static hidden view at the bottom with a fixed ID
// To handle cases where we don't want to or cannot define an id for each individual view within the ForEach.
struct AutoScrollDemoV3: View {
    @State private var data: [Item] = (0..<20).map({Item(content: "\($0)")})
    
    private let bottomViewId: String = "bottom"
    
    var body: some View {
        NavigationStack {
            ScrollViewReader(content: { proxy in
                List {
                    ForEach(data, content: { item in
                        Text(item.content)
                    })
                    
                    Section {
                        HStack{}
                            .id(bottomViewId)
                            .listRowInsets(.all, .zero)
                            .listRowSeparator(.hidden, edges: .all)
                    }
                    .listSectionSpacing(0)
                }
                .environment(\.defaultMinListRowHeight, 0)
                .environment(\.defaultMinListHeaderHeight, 0)
                .defaultScrollAnchor(.bottom, for: .alignment)
                .defaultScrollAnchor(.bottom, for: .initialOffset)
                .defaultScrollAnchor(.bottom, for: .sizeChanges)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .topBarTrailing, content: {
                        Button(action: {
                            guard var last = data.last else {
                                return
                            }
                            last.content = "\(last.content)\n something new\n something new\n something new\n something new"
                            data[data.count-1] = last
                        }, label: {
                            Text("Add Content")
                        })
                        
                        Button(action: {
                            data.append(Item(content: "\(data.count)"))
                        }, label: {
                            Text("Add Item")
                        })
                    })
                    

                })
                .onScrollGeometryChange(for: CGSize.self, of: {
                    $0.contentSize
                }, action: { _, _ in
                    withAnimation{
                        proxy.scrollTo(bottomViewId, anchor: .bottom)
                    }
                })
            })
        }
    }
}


#Preview {
    AutoScrollDemoV3()
}
