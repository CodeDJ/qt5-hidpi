/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Quick Controls module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Private 1.0

/*!
    \qmltype StandAloneScrollBar
    \inqmlmodule QtQuick.Controls
    \since  5.2.1
    \ingroup views
    \brief Provides a scrolling bar within another Flickable.
*/
Item {
    id: scrollbar

    property Flickable flickableItem: null
    property bool isTransient: !!__panel && !!__panel.isTransient
    property bool active: !!__panel && (__panel.sunken || __panel.activeControl !== "none")
    property int orientation: Qt.Horizontal
    property alias minimumValue: slider.minimumValue
    property alias maximumValue: slider.maximumValue
    property alias value: slider.value
    property int singleStep: 20
    property bool scrolling: false
    property Component style: Qt.createComponent(Settings.style + "/StandAloneScrollBarStyle.qml", scrollbar)
    property Style __style: styleLoader.item
    property Item __panel: panelLoader.item

    activeFocusOnTab: false
    enabled: !isTransient || __panel.visible
    visible: orientation === Qt.Horizontal ? (internalData.contentWidth > internalData.availableWidth)
                                           : (internalData.contentHeight > internalData.availableHeight)
    width: (visible && orientation === Qt.Vertical) ? implicitWidth : 0
    height: (visible && orientation === Qt.Horizontal) ? implicitHeight : 0
    z: 1

    Accessible.role: Accessible.ScrollBar
    implicitWidth: panelLoader.implicitWidth
    implicitHeight: panelLoader.implicitHeight

    Loader {
        id: panelLoader
        anchors.fill: parent
        sourceComponent: __style ? __style.__scrollbar : null
        onStatusChanged: if (status === Loader.Error) console.error("Failed to load Style for", scrollbar)
        property alias __control: scrollbar
        property QtObject __styleData: QtObject {
            readonly property alias horizontal: internal.horizontal
            readonly property alias upPressed: internalData.upPressed
            readonly property alias downPressed: internalData.downPressed
            readonly property alias handlePressed: internalData.handlePressed
        }
    }

    Loader {
        id: styleLoader
        sourceComponent: style
        onStatusChanged: {
            if (status === Loader.Error)
                console.error("Failed to load Style for", scrollbar)
        }
        property alias __control: scrollbar
    }

    MouseArea {
        id: internal
        property bool horizontal: orientation === Qt.Horizontal
        property int pageStep: internal.horizontal ? width : height
        property bool scrollToClickposition: internal.scrollToClickPosition
        anchors.fill: parent
        cursorShape: __panel.visible ? Qt.ArrowCursor : Qt.IBeamCursor // forces a cursor change

        property bool autoincrement: false
        property bool scrollToClickPosition: __style ? __style.scrollToClickedPosition : 0

        // Update hover item
        onEntered: if (!pressed) __panel.activeControl = __panel.hitTest(mouseX, mouseY)
        onExited: if (!pressed) __panel.activeControl = "none"
        onMouseXChanged: if (!pressed) __panel.activeControl = __panel.hitTest(mouseX, mouseY)
        hoverEnabled: true

        property var pressedX
        property var pressedY
        property int oldPosition
        property int grooveSize

        Timer {
            running: internalData.upPressed || internalData.downPressed
                     || internalData.pageUpPressed || internalData.pageDownPressed
            interval: 350
            onTriggered: internal.autoincrement = true
        }

        Timer {
            running: internal.autoincrement
            interval: 60
            repeat: true
            onTriggered: {
                if (internalData.upPressed && internal.containsMouse) {
                    internal.decrement();
                } else if (internalData.downPressed && internal.containsMouse) {
                    internal.increment();
                } else if (internalData.pageUpPressed) {
                    internal.decrementPage();
                } else if (internalData.pageDownPressed) {
                    internal.incrementPage();
                }
            }
        }

        onPositionChanged: {
            if (internalData.handlePressed) {
                if (!horizontal) {
                    slider.position = oldPosition + (mouseY - pressedY);
                } else {
                    slider.position = oldPosition + (mouseX - pressedX);
                }
                scrolling = true;
            }
        }

        onPressed: {
            __panel.activeControl = __panel.hitTest(mouseX, mouseY)
            scrollToClickposition = scrollToClickPosition
            var handleRect = __panel.subControlRect("handle")
            var grooveRect = __panel.subControlRect("groove")
            grooveSize =  horizontal ? grooveRect.width - handleRect.width:
                                       grooveRect.height - handleRect.height;
            if (__panel.activeControl === "handle") {
                pressedX = mouseX;
                pressedY = mouseY;
                internalData.handlePressed = true;
                oldPosition = slider.position;
            } else if (__panel.activeControl === "up") {
                decrement();
                internalData.upPressed = Qt.binding(function() {return containsMouse});
            } else if (__panel.activeControl === "down") {
                increment();
                internalData.downPressed = Qt.binding(function() {return containsMouse});
            } else if (!scrollToClickposition){
                if (__panel.activeControl === "upPage") {
                    decrementPage();
                    internalData.pageUpPressed = true;
                } else if (__panel.activeControl === "downPage") {
                    incrementPage();
                    internalData.pageDownPressed = true;
                }
            } else { // scroll to click position
                slider.position = horizontal ? mouseX -  handleRect.width/2 - grooveRect.x
                                             : mouseY - handleRect.height/2 - grooveRect.y
                pressedX = mouseX;
                pressedY = mouseY;
                internalData.handlePressed = true;
                oldPosition = slider.position;
            }
            scrolling = true;
        }

        onReleased: {
            __panel.activeControl = __panel.hitTest(mouseX, mouseY);
            autoincrement = false;
            internalData.upPressed = false;
            internalData.downPressed = false;
            internalData.handlePressed = false;
            internalData.pageUpPressed = false;
            internalData.pageDownPressed = false;
            scrolling = false;
        }

        onWheel: {
            var stepCount = -(wheel.angleDelta.x ? wheel.angleDelta.x : wheel.angleDelta.y) / 120
            if (stepCount != 0) {
                scrolling = true
                if (wheel.modifiers & Qt.ControlModifier || wheel.modifiers & Qt.ShiftModifier)
                   incrementPage(stepCount)
                else
                   increment(stepCount)
                scrolling = false
            }
        }

        function incrementPage(stepCount) {
            value = boundValue(value + getSteps(pageStep, stepCount))
        }

        function decrementPage(stepCount) {
            value = boundValue(value - getSteps(pageStep, stepCount))
        }

        function increment(stepCount) {
            value = boundValue(value + getSteps(singleStep, stepCount))
        }

        function decrement(stepCount) {
            value = boundValue(value - getSteps(singleStep, stepCount))
        }

        function boundValue(val) {
            return Math.min(Math.max(val, minimumValue), maximumValue)
        }

        function getSteps(step, count) {
            if (count)
                step *= count
            return step
        }

        RangeModel {
            id: slider
            minimumValue: 0.0
            maximumValue: 1.0
            value: 0
            stepSize: 0.0
            inverted: false
            positionAtMaximum: internal.grooveSize
        }
    }

    Connections {
        target: flickableItem
        onContentWidthChanged: internalData.doLayout()
        onContentHeightChanged: internalData.doLayout()
        onContentXChanged: {
            if (scrollbar.orientation === Qt.Horizontal) {
                internalData.blockUpdates = true;
                slider.value = flickableItem.contentX;
                internalData.blockUpdates = false;
            }
            internalData.flash();
        }
        onContentYChanged: {
            if (scrollbar.orientation === Qt.Vertical) {
                internalData.blockUpdates = true;
                slider.value = flickableItem.contentY;
                internalData.blockUpdates = false;
            }
            internalData.flash();
        }
    }

    onValueChanged: {
        if (flickableItem && !internalData.blockUpdates && enabled) {
            if (orientation === Qt.Horizontal) {
                flickableItem.contentX = value;
            } else {
                flickableItem.contentY = value;
            }
        }
    }

    Binding {
        target: scrollbar.__panel
        property: "raised"
        value: scrollbar.active
        when: scrollbar.isTransient
    }
    Binding {
        target: scrollbar.__panel
        property: "visible"
        value: true
        when: !scrollbar.isTransient || scrollbar.active
    }

    Timer {
        id: flasher
        interval: 10
        onTriggered: __panel.on = false
    }

    QtObject {
        id: internalData

        property bool blockUpdates: false
        property int availableHeight: 0
        property int availableWidth: 0
        property int contentHeight: 0
        property int contentWidth: 0
        property real originX: 0
        property real originY: 0
        property bool recursionGuard: false
        property bool upPressed: false
        property bool downPressed: false
        property bool pageUpPressed: false
        property bool pageDownPressed: false
        property bool handlePressed: false

        function doLayout()
        {
            if (recursionGuard || !flickableItem)
                return;

            recursionGuard = true;
            availableWidth = flickableItem.width;
            availableHeight = flickableItem.height;
            contentWidth = flickableItem.contentWidth;
            contentHeight = flickableItem.contentHeight;
            originX = flickableItem.originX;
            originY = flickableItem.originY;
            slider.minimumValue = minValue();
            slider.maximumValue = maxValue();
            recursionGuard = false;
        }

        function maxValue()
        {
            if (scrollbar.orientation == Qt.Vertical)
                return contentHeight > availableHeight ? originY + contentHeight - availableHeight : 0;
            return contentWidth > availableWidth ? originX + contentWidth - availableWidth : 0;
        }

         function minValue()
         {
             return (scrollbar.orientation == Qt.Vertical) ? originY : originX;
         }

         function flash()
         {
             if (scrollbar.isTransient) {
                 scrollbar.__panel.on = true;
                 scrollbar.__panel.visible = true;
                 flasher.start();
             }
         }
    }
}
