import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.UI

Item {
    id: root
    property var pluginApi: null
    
    Component.onCompleted: {
        if (pluginApi) {
            pluginApi.mainInstance = root;
        }
        
        var mkdirProcess = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root);
        mkdirProcess.command = ["sh", "-c", "mkdir -p ~/Pictures/Screenshots"];
        mkdirProcess.startDetached();
        mkdirProcess.exited.connect(function() { 
            mkdirProcess.destroy(); 
        });
    }
    
    function takeScreenshot(mode) {
        var command = "hyprshot -m " + mode + " -o ~/Pictures/Screenshots";
        
        var screenshotProcess = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root);
        screenshotProcess.command = ["sh", "-c", command];
        screenshotProcess.startDetached();
        
        screenshotProcess.exited.connect(function() {
            screenshotProcess.destroy();
        });
        
        // Закрываем панель после запуска
        if (pluginApi && pluginApi.closePanel) {
            pluginApi.closePanel();
        }
    }
    
    IpcHandler {
        target: "plugin:screenshot-plugin"
        
        function toggle() {
            if (!root.pluginApi) return;
            
            if (Quickshell.screens && Quickshell.screens.length > 0) {
                root.pluginApi.openPanel(Quickshell.screens[0]);
            }
        }
        
        function open() {
            if (!root.pluginApi) return;
            
            if (Quickshell.screens && Quickshell.screens.length > 0) {
                root.pluginApi.openPanel(Quickshell.screens[0]);
            }
        }
    }
}