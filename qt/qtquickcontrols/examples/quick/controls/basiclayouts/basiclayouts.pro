QT += qml quick
TARGET = basiclayouts
!android: !ios: !blackberry: qtHaveModule(widgets): QT += widgets

include(src/src.pri)

OTHER_FILES += \
    main.qml

RESOURCES += \
    resources.qrc