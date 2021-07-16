# SwiftUI-Refresh DEMO

## 功能
下拉刷新 上拉加载 效果图如下：

https://user-images.githubusercontent.com/18625637/125956524-0d277f7c-68c4-40b0-b2ec-6ea0787d09b8.mp4

## 使用方法
```swift
// 下拉刷新、上拉加载
var headerFooterRefresh: some View {
  ScrollView {
    PullToRefreshView(header: RefreshDefaultHeader(), footer: RefreshDefaultFooter()) {
      ItemList(items: items)
    }.environmentObject(listState)
  }
  .addPullToRefresh(isHeaderRefreshing: $headerRefreshing, onHeaderRefresh: reloadData,
                      isFooterRefreshing: $footerRefreshing, onFooterRefresh: loadMoreData)
}
```

其中，`header`和`footer`分别制定下拉和上拉出现的内容。
如只指定一个，则仅支持单边的操作；如两个都省略，则默认为`header: RefreshDefaultHeader(), footer: RefreshDefaultFooter()`

当下拉刷新和上拉加载触发时，分别调用`onHeaderRefresh`和`onFooterRefresh`（用于放置添加/刷新数据的异步请求等操作），并分别将`isHeaderRefreshing`和`isFooterRefreshing`设置为`true`；
在刷新完成后，将`isHeaderRefreshing`和`isFooterRefreshing`设为`false`可以终止“刷新中”动画

`header`和`footer`的实现大致如下：
```swift
struct RefreshDefaultHeader: View {
  @Environment(\.headerRefreshData) private var headerRefreshData

  var body: some View {
    let state = headerRefreshData.refreshState
    let progress = headerRefreshData.progress
    if state == .stopped {
      // 当静止状态及拉动过程中的界面内容
    }
    if state == .triggered {
      // 当拉到足够触发的距离时的界面内容
    }
    if state == .loading {
      // 当松手进入加载中时的界面内容
    }
    if state == .invalid {
      // 当失效时的界面内容
    }
  }
}
```
其中`headerRefreshData.refreshState`为四种状态之一，`headerRefreshData.progress`为一个0-1的浮点数，表示拉动距离；整体随拉动距离改变透明度

## 实现原理
实现主要包括三个部分，`PullToRefreshView`、`.addPullToRefresh`和`RefreshDefaultHeader/RefreshDefaultFooter`

### PullToRefreshView
在主体列表上下绘制`header`和`footer`，并通过`.anchorPreference`方法获取各个部分的`bounds`（记录视图的包围盒），用以计算拉动距离（见`.addPullToRefresh`部分）。
原理示例：
```swift
header
  .frame(maxWidth: .infinity)
  .anchorPreference(key: HeaderBoundsPreferenceKey.self, value: .bounds, transform: {
      [.init(bounds: $0)]
  })
```

### .addPullToRefresh
是一个`ViewModifier`，给主体列表添加一系列更新响应以处理拉动时的各种状态变更。
通过在`.backgroundPreferenceValue`中返回`Color.clear`创造一个没有实际效果的交互响应，主要目的是获取前面存储的`bounds`并调用函数计算所需状态。
原理示例：
```swift
content
  .environment(\.headerRefreshData, headerRefreshData)
  .environment(\.footerRefreshData, footerRefreshData)
  .backgroundPreferenceValue(HeaderBoundsPreferenceKey.self) { value -> Color in
      DispatchQueue.main.async {
          calculateHeaderRefreshState(proxy, value: value)
      }
      return Color.clear // 返回一个透明背景，无效果，仅用于在视图更新时触发calculateHeaderRefreshState函数
  }
```

### RefreshDefaultHeader/RefreshDefaultFooter
以环境参数的方式接收拉动状态，并绘制相应的头/尾部指示器。
定义方法参见上文。

### License
[MIT licensed](./LICENSE).
