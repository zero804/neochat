import QtQuick 2.12

import org.kde.kirigami 2.4 as Kirigami

Text {
    text: "<style>pre {white-space: pre-wrap} a{color: " + Kirigami.Theme.linkColor + ";} .user-pill{}</style>" + display

    font.family: Kirigami.Theme.defaultFont.family + ", emoji"

    wrapMode: Text.WordWrap
    width: parent.width
    textFormat: Text.RichText
}
