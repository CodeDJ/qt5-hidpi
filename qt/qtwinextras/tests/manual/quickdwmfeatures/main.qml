/****************************************************************************
 **
 ** Copyright (C) 2013 Ivan Vizir <define-true-false@yandex.com>
 ** Contact: http://www.qt-project.org/legal
 **
 ** This file is part of the QtWinExtras module of the Qt Toolkit.
 **
 ** $QT_BEGIN_LICENSE:LGPL$
 ** Commercial License Usage
 ** Licensees holding valid commercial Qt licenses may use this file in
 ** accordance with the commercial license agreement provided with the
 ** Software or, alternatively, in accordance with the terms contained in
 ** a written agreement between you and Digia.  For licensing terms and
 ** conditions see http://qt.digia.com/licensing.  For further information
 ** use the contact form at http://qt.digia.com/contact-us.
 **
 ** GNU Lesser General Public License Usage
 ** Alternatively, this file may be used under the terms of the GNU Lesser
 ** General Public License version 2.1 as published by the Free Software
 ** Foundation and appearing in the file LICENSE.LGPL included in the
 ** packaging of this file.  Please review the following information to
 ** ensure the GNU Lesser General Public License version 2.1 requirements
 ** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
 **
 ** In addition, as a special exception, Digia gives you certain additional
 ** rights.  These rights are described in the Digia Qt LGPL Exception
 ** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
 **
 ** GNU General Public License Usage
 ** Alternatively, this file may be used under the terms of the GNU
 ** General Public License version 3.0 as published by the Free Software
 ** Foundation and appearing in the file LICENSE.GPL included in the
 ** packaging of this file.  Please review the following information to
 ** ensure the GNU General Public License version 3.0 requirements will be
 ** met: http://www.gnu.org/copyleft/gpl.html.
 **
 **
 ** $QT_END_LICENSE$
 **
 ****************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.0
import QtWinExtras 1.0
import QtGraphicalEffects 1.0

Window {
    title: "DWM Features QtWinExtras manual test"
    width: 350
    height: 261

    DwmFeatures {
        id: dwm
        leftGlassMargin: sboxLeft.value
        rightGlassMargin: sboxRight.value
        topGlassMargin: sboxTop.value
        bottomGlassMargin: sboxBottom.value
        blurBehindEnabled: cbBlurBehind.checked

        excludedFromPeek: cbExcludedFromPeek.checked
        peekDisallowed: cbPeekDisallowed.checked

        Component.onCompleted: {
            cbCompositionEnabled.checked = compositionEnabled
            compositionEnabled = Qt.binding(function () { return cbCompositionEnabled.checked })
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: dwm.compositionEnabled ? dwm.leftGlassMargin : 0
        anchors.rightMargin: dwm.compositionEnabled ? dwm.rightGlassMargin : 0
        anchors.topMargin: dwm.compositionEnabled ? dwm.topGlassMargin : 0
        anchors.bottomMargin: dwm.compositionEnabled ? dwm.bottomGlassMargin : 0

        visible: !dwm.compositionEnabled || dwm.topGlassMargin > -1 && dwm.leftGlassMargin > -1 && dwm.rightGlassMargin > -1 && dwm.bottomGlassMargin > -1 && !cbBlurBehind.checked
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 2
        columns: 2

        CheckBox {
            id: cbCompositionEnabled
            text: "Composition enabled"
            Layout.columnSpan: 2
        }

        CheckBox {
            id: cbBlurBehind
            text: "Blur behind enabled"
            Layout.columnSpan: 2
            enabled: cbCompositionEnabled.checked
        }

        Label { text: "Top glass frame margin" }
        SpinBox { id: sboxTop; minimumValue: -1; maximumValue: 40; value: 0; Layout.alignment: Qt.AlignRight; enabled: cbCompositionEnabled.checked }
        Label { text: "Right glass frame margin" }
        SpinBox { id: sboxRight; minimumValue: -1; maximumValue: 40; value: 0; Layout.alignment: Qt.AlignRight; enabled: cbCompositionEnabled.checked }
        Label { text: "Bottom glass frame margin" }
        SpinBox { id: sboxBottom; minimumValue: -1; maximumValue: 40; value: 0; Layout.alignment: Qt.AlignRight; enabled: cbCompositionEnabled.checked }
        Label { text: "Left glass frame margin" }
        SpinBox { id: sboxLeft; minimumValue: -1; maximumValue: 40; value: 0; Layout.alignment: Qt.AlignRight; enabled: cbCompositionEnabled.checked }

        CheckBox {
            id: cbExcludedFromPeek
            text: "Excluded from peek"
            Layout.columnSpan: 2
            enabled: cbCompositionEnabled.checked
        }

        CheckBox {
            id: cbPeekDisallowed
            text: "Peek disallowed"
            Layout.columnSpan: 2
            enabled: cbCompositionEnabled.checked
        }

        Rectangle {
            id: rcColorization
            width: parent.width
            height: 32
            color: dwm.realColorizationColor
            Layout.fillWidth: true
            Layout.columnSpan: 2
            border.width: 4
            border.color: ''+dwm.realColorizationColor

            Label { text: "Real colorization color"; anchors.centerIn: parent}
        }

        Rectangle {
            width: parent.width
            height: 32
            color: dwm.colorizationColor
            Layout.fillWidth: true
            Layout.columnSpan: 2
            border.width: 4
            border.color: ''+dwm.colorizationColor

            Label { text: "API-given colorization color (blended)"; anchors.centerIn: parent}
        }

        Item { Layout.fillHeight: true }
    }
}
