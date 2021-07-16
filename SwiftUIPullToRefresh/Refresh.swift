//
//  Refresh.swift
//  SwiftUIPullToRefresh
//
//  Created by apple on 2021/7/14.
//

import SwiftUI
import WebKit

struct WebView111 : UIViewRepresentable {
    
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
}

#if DEBUG
struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(request: URLRequest(url: URL(string: "https://www.apple.com")!))
    }
}
#endif
