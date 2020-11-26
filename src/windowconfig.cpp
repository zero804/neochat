/**
 * SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
 *
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */
#include "windowconfig.h"
#include <QDebug>

WindowConfig::WindowConfig()
    : m_config(KSharedConfig::openStateConfig("neochat"))
    , m_windowGroup(m_config, "Window")
{
}

void WindowConfig::saveWindowSize(QWindow *window)
{
    if (m_restored) {
        KWindowConfig::saveWindowSize(window, m_windowGroup);
        m_config->sync();
    }
}

void WindowConfig::restoreWindowSize(QWindow *window)
{
    KWindowConfig::restoreWindowSize(window, m_windowGroup);
    m_restored = true;
}

void WindowConfig::saveWindowPosition(QWindow *window)
{
    if (m_restored) {
        KWindowConfig::saveWindowPosition(window, m_windowGroup);
        m_config->sync();
        qDebug() << "savePo";
    }
}

void WindowConfig::restoreWindowPosition(QWindow* window)
{
    KWindowConfig::restoreWindowPosition(window, m_windowGroup);
    m_restored = true;
}
