import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root
    property var pluginApi: null
    
    // Свойство для отслеживания состояния панели
    property bool panelOpen: false
    
    // Функция для создания скриншота
    function takeScreenshot(mode) {
        console.log("Создание скриншота:", mode);
        var command = "hyprshot -m " + mode + " -o ~/Pictures/Screenshots";
        
        var screenshotProcess = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root);
        screenshotProcess.command = ["sh", "-c", command];
        
        screenshotProcess.exited.connect(function() {
            console.log("Hyprshot завершен с кодом:", screenshotProcess.exitCode);
            screenshotProcess.destroy();
        });
        
        screenshotProcess.startDetached();
    }
    
    // Регистрируем IPC обработчик с toggle функцией
    IpcHandler {
        target: "plugin:screenshot-plugin"
        property var pluginApi: root.pluginApi
        
        // Основная функция toggle - открывает/закрывает панель
        function toggle() {
            console.log("IPC toggle команда получена");
            
            if (!pluginApi) {
                console.error("pluginApi не доступен");
                return;
            }
            
            if (root.panelOpen) {
                // Если панель открыта - закрываем
                if (typeof pluginApi.closePanel === 'function') {
                    pluginApi.closePanel(0);
                    root.panelOpen = false;
                    console.log("Панель закрыта");
                }
            } else {
                // Если панель закрыта - открываем
                if (typeof pluginApi.openPanel === 'function') {
                    pluginApi.openPanel(0);
                    root.panelOpen = true;
                    console.log("Панель открыта");
                }
            }
        }
        
        // Также поддерживаем явные команды open/close
        function open() {
            console.log("IPC open команда получена");
            if (pluginApi && typeof pluginApi.openPanel === 'function' && !root.panelOpen) {
                pluginApi.openPanel(0);
                root.panelOpen = true;
            }
        }
        
        function close() {
            console.log("IPC close команда получена");
            if (pluginApi && typeof pluginApi.closePanel === 'function' && root.panelOpen) {
                pluginApi.closePanel(0);
                root.panelOpen = false;
            }
        }
    }
    
    // Обработчик событий от панели
    Connections {
        target: pluginApi
        
        // Слушаем события закрытия панели
        function onPanelClosed() {
            console.log("Событие закрытия панели получено");
            root.panelOpen = false;
        }
    }
    
    Component.onCompleted: {
        console.log("Плагин скриншотов инициализирован");
        
        // Создаем папку для скриншотов
        var mkdirProcess = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root);
        mkdirProcess.command = ["sh", "-c", "mkdir -p ~/Pictures/Screenshots"];
        mkdirProcess.startDetached();
        mkdirProcess.exited.connect(function() { mkdirProcess.destroy(); });
    }
}