import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Services.Keyboard

Rectangle {
    id: root

    property var pluginApi: null
    property string currentLayout: KeyboardLayoutService ? KeyboardLayoutService.currentLayout : "??"
    property bool capsLockOn: LockKeysService ? LockKeysService.capsLockOn : false
    property bool flag: pluginApi?.pluginSettings.showIcon
    property bool text: pluginApi?.pluginSettings.showText 
    
    implicitWidth: row.implicitWidth + Style.marginM * 2
    implicitHeight: Style.barHeight - 6

    property string displayText: {
      if (!currentLayout || currentLayout === "system.unknown-layout") {
        return "??";
      }
      return currentLayout.substring(0, 2).toUpperCase();
    }

    function getFlagEmoji(layoutCode) {
        if (!layoutCode || layoutCode.length < 2) return "🇦🇧";
        
        var code = layoutCode.toLowerCase();
        
        if (pluginApi?.pluginSettings[code]) {
            return pluginApi?.pluginSettings[code];
        }
        
        return "🇦🇧";
    }

    color: capsLockOn ? Color.mHover : Color.mSurfaceVariant
    radius: 4

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Style.marginS

        NText {
            id: flagText
            visible: root.flag 
            text: getFlagEmoji(displayText.toLowerCase())
            color: capsLockOn ? Color.mOnHover : Color.mOnSurface
            pointSize: Style.fontSizeXL
        }

        NText {
            id: text
            visible: root.text
            text: displayText
            color: capsLockOn ? Color.mOnHover : Color.mOnSurface
            pointSize: Style.fontSizeS
        }
    }

    Connections {
      target: KeyboardLayoutService
      function onCurrentLayoutChanged() {
        Logger.d("KeyboardLayoutWidget", displayText)
      }
    }
    
    Connections {
      target: LockKeysService
      function onCapsLockChanged(active) {
        Logger.d("KeyboardLayoutWidget", capsLockOn)
      }
    }
}