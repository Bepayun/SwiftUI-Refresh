//
//  ContentView.swift
//  SwiftUIPullToRefresh
//
//  Created by apple on 2021/7/13.
//

import SwiftUI

struct PullToRefresh: View {
    
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Image("cat_blue")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}

struct RefreshControl: View {
    var coordinateSpace: CoordinateSpace
    var onRefresh: ()->Void
    @State var refresh: Bool = false
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: coordinateSpace).midY > 50) {
                Spacer()
                    .onAppear {
                        if refresh == false {
                            onRefresh() ///call refresh once if pulled more than 50px
                        }
                        refresh = true
                    }
            } else if (geo.frame(in: coordinateSpace).maxY < 1) {
                Spacer()
                    .onAppear {
                        refresh = false
                        ///reset  refresh if view shrink back
                    }
            }
            ZStack(alignment: .center) {
                if refresh { ///show loading if refresh called
                    ProgressView()
                } else { ///mimic static progress bar with filled bar to the drag percentage
                    ForEach(0..<8) { tick in
                          VStack {
                              Rectangle()
                                .fill(Color(UIColor.tertiaryLabel))
                                .opacity((Int((geo.frame(in: coordinateSpace).midY)/7) < tick) ? 0 : 1)
                                  .frame(width: 3, height: 7)
                                .cornerRadius(3)
                              Spacer()
                      }.rotationEffect(Angle.degrees(Double(tick)/(8) * 360))
                   }.frame(width: 20, height: 20, alignment: .center)
                }
            }.frame(width: geo.size.width)
        }.padding(.top, -50)
    }
}

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                    // do your stuff when pulled
                }
                VStack(spacing: 10) {
                    ForEach(0..<33) { i in
                        NavigationLink (
                            destination: WebKit()) {
                            HStack{
                                Spacer().frame(width: 32)
                                
                                Text("Some view \(i)...")
                                    .frame(height: 45)
                                Spacer()
                            }
                        }
                        
                    }
                }
                
            }.coordinateSpace(name: "pullToRefresh")
    //        ScrollView {
    //                    RefreshControl(coordinateSpace: .named("RefreshControl")) {
    //                        //refresh view here
    //                    }
    //                    Text("Some view...")
    //                }.coordinateSpace(name: "RefreshControl")
        }
        .edgesIgnoringSafeArea(.all)
    }
}
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
