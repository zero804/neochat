/**
 * SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
 *
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

#pragma once

#include <KWindowConfig>
#include <KSharedConfig>

/**
 * A \c WindowConfig allows to conveniently save and restore the window sizes
 * from QML and C++.
 */
class WindowConfig : public QObject {
    Q_OBJECT

public:
    explicit WindowConfig();
    ~WindowConfig() = default;

    Q_INVOKABLE void saveWindowSize(QWindow *window);
    Q_INVOKABLE void restoreWindowSize(QWindow *window);
    Q_INVOKABLE void saveWindowPosition(QWindow *window);
    Q_INVOKABLE void restoreWindowPosition(QWindow *window);

private:
    KSharedConfig::Ptr m_config;
    KConfigGroup m_windowGroup;
    bool m_restored;
};
