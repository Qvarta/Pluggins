import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi: null

    // Свойства из настроек
    property string currentIconName: pluginApi?.pluginSettings?.currentIconName || 
                                     pluginApi?.manifest?.metadata?.defaultSettings?.currentIconName || 
                                     "music_note"

    spacing: Style.marginL

    // Выбор иконки
    RowLayout {
        spacing: Style.marginL
        Layout.fillWidth: true

        NLabel {
            label: pluginApi?.tr("iconLabel") || "Icon"
            description: pluginApi?.tr("iconDescription") || "Select icon for the widget"
            Layout.fillWidth: true
        }

        // Превью текущей иконки
        Rectangle {
            width: 40
            height: 40
            radius: Style.radiusM
            color: Color.mSurfaceVariant
            
            NIcon {
                anchors.centerIn: parent
                icon: root.currentIconName
                color: Color.mPrimary
                width: 24
                height: 24
            }
        }

        // Название текущей иконки
        NText {
            text: root.currentIconName
            color: Color.mOnSurfaceVariant
            font.pointSize: Style.fontSizeS
        }

        // Кнопка выбора иконки
        NButton {
            text: pluginApi?.tr("changeIconButton") || "Change Icon"
            onClicked: {
                iconPicker.open();
            }
        }
    }

    // Компонент выбора иконки
    NIconPicker {
        id: iconPicker
        onIconSelected: function (icon) {
            root.currentIconName = icon;
            saveSettings();
        }
    }

    // Функция сохранения настроек
    function saveSettings() {
        if (!pluginApi) {
            return;
        }

        // Сохраняем выбранную иконку
        pluginApi.pluginSettings.currentIconName = root.currentIconName;
        
        // Сохраняем настройки
        pluginApi.saveSettings();
        
        // Закрываем панель настроек
        if (pluginApi.closePanel) {
            pluginApi.closePanel();
        }
    }
}