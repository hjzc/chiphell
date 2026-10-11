import Cocoa
import FlutterMacOS
import desktop_multi_window
import desktop_lifecycle

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
  
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

     FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      // Register the plugin which you want access from other isolate.
        RegisterGeneratedPlugins(registry: controller)
       // DesktopLifecyclePlugin.register(with: controller)
     }
    super.awakeFromNib()

    // 5. 显示窗口
    //self.makeKeyAndOrderFront(nil)
    
  }
  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
        super.order(place, relativeTo: otherWin)
        hiddenWindowAtLaunch()
    }
}
