/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Layouts 1.14

import org.kde.kirigami 2.12 as Kirigami

import org.kde.neochat 1.0

import QtWebView 1.15

Kirigami.Page {
    id: captchaPage
    
    title: i18n("reCAPTCHA")
    
    Kirigami.PlaceholderMessage {
        anchors.fill: parent
        visible: !webview.visible
        text: i18n("Your homeserver requires you to solve a reCAPTCHA before registering an account. If you don't want to do this, go back and choose a different homeserver")
        helpfulAction: Kirigami.Action {
            icon.name: "checkmark"
            text: i18n("Agree")
            onTriggered: {
                webview.visible = true
            }
        }
    }
    WebView {
        id: webview
        url: "http://localhost:20847"
        anchors.fill: parent
        anchors.bottomMargin: 2 * Kirigami.Units.gridUnit
        visible: false
        
        onLoadingChanged: {
            if(!loading) {
                webview.runJavaScript("document.body.style.background = '" + captchaPage.background.color + "'")
            }
        }
        
        Timer {
            id: timer
            repeat: true
            running: true
            interval: 100
            onTriggered: {
                if(!webview.visible)
                    return
                webview.runJavaScript("grecaptcha.getResponse()", function(response){
                    if(!webview.visible || !response)
                        return
                    console.log("R: " + response)
                    timer.running = false;
                    Controller.recaptResponse = response;
                    pageStack.layers.pop();
                })
            }
        }
    }
}
