import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    spacing: Style.marginL

    property var pluginApi: null

    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property bool showText: cfg.showText ?? defaults.showText ?? true
    property bool showIcon: cfg.showIcon ?? defaults.showIcon ?? true

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 200
        color: Color.mSurfaceVariant
        radius: Style.radiusM
        border.color: Color.mOutline
        border.width: Style.borderS
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginL
            spacing: Style.marginM
            
            NText {
                text: pluginApi?.tr("displaySettingsLabel")
                color: Color.mPrimary
                font.pointSize: Style.fontSizeL
                font.weight: Font.Bold
            }
            
            NDivider {
                Layout.fillWidth: true
            }
            
            ColumnLayout {
                spacing: Style.marginL
                Layout.fillWidth: true
                
                NToggle {
                    label: pluginApi?.tr("showTextLabel") 
                    description: pluginApi?.tr("showTextDescription") 
                    
                    checked: root.showText
                    onToggled: function (checked) {
                        root.showText = checked;
                    }
                }
                
                NToggle {
                    label: pluginApi?.tr("showIconLabel") 
                    description: pluginApi?.tr("showIconDescription") 
                    
                    checked: root.showIcon
                    onToggled: function (checked) {
                        root.showIcon = checked;
                    }
                }
            }
        }
    }

    function saveSettings() {
        if (!pluginApi) {
            return;
        }
        
        pluginApi.pluginSettings.showText = root.showText;
        pluginApi.pluginSettings.showIcon = root.showIcon;

        pluginApi.saveSettings();
        
        if (pluginApi.closePanel) {
            pluginApi.closePanel();
        }
    }
}