import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Rectangle {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    
    // Свойство для иконки из настроек
    property string currentIconName: pluginApi?.pluginSettings?.currentIconName || pluginApi?.manifest?.metadata?.defaultSettings?.currentIconName || "music_note"

    implicitWidth: row.implicitWidth + Style.marginM * 2
    implicitHeight: Style.barHeight

    color: Style.capsuleColor
    radius: Style.radiusM

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Style.marginS
        
        NIcon {
            icon: root.currentIconName
            color: Color.mPrimary
        }

        NText {
            text: "Radio"
            color: Color.mOnSurface
            pointSize: Style.fontSizeS
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.color = Qt.lighter(Style.capsuleColor, 1.1)
        }

        onExited: {
            root.color = Style.capsuleColor
        }

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                pluginApi.openPanel(root.screen)
            } else if (mouse.button === Qt.RightButton) {
                // Можно открыть настройки по правому клику
                pluginApi.openSettings();
            }
        }
    }
}