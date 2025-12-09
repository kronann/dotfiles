import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules.common
import qs.modules.bar
import qs.modules.common.widgets
import qs.services
import QtQuick.Layouts
import qs.modules.common.functions

import QtQuick.Controls

ToolTip {
    id: customToolTip
    visible: down
    text: Network.networkName
    property string displayWifiText: Network.networkName ? "  " +  Network.networkName : "Network Disconnected"
    property string displayBluetoothText: Bluetooth.getBluetoothDevices() != "" ? "ᛒ " + Bluetooth.getBluetoothDevices() : "No devices connected";

    background: Rectangle {
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        color: ColorUtils.applyAlpha(Appearance.colors.colSurfaceContainer, 1 - Appearance.backgroundTransparency)
        radius: Appearance.rounding.small
    }
    contentItem:
     ColumnLayout {
            id: customToolTipRowLayout
            anchors.fill: parent
            layoutDirection: Qt.RightToLeft

            Text {
                id: customToolTipTxt
                Layout.alignment: Qt.AlignCenter

                text: customToolTip.displayWifiText
                font {
                    family: "JetBrainsMono Nerd Font"
                    weight: Font.Medium
                    pixelSize: Appearance.font.pixelSize.normal
                }
                color: Appearance.colors.colOnSurfaceVariant
                padding: 1
            }

            Text {
                id: customToolTipTxt2
                Layout.alignment: Qt.AlignCenter
                text: customToolTip.displayBluetoothText
                font {
                    family: "JetBrainsMono Nerd Font"
                    weight: Font.Medium
                    pixelSize: Appearance.font.pixelSize.normal
                }
                color: Appearance.colors.colOnSurfaceVariant
                padding: 1
            }
    }
}
