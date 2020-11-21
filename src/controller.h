/**
 * SPDX-FileCopyrightText: 2018-2019 Black Hat <bhat@encom.eu.org>
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */
#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QApplication>
#include <QMediaPlayer>
#include <QMenu>
#include <QObject>
#include <QSystemTrayIcon>

#include <KAboutData>

#include "connection.h"
#include "csapi/list_public_rooms.h"
#include "room.h"
#include "settings.h"
#include "user.h"

using namespace Quotient;

class Controller : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int accountCount READ accountCount NOTIFY connectionAdded NOTIFY connectionDropped)
    Q_PROPERTY(bool quitOnLastWindowClosed READ quitOnLastWindowClosed WRITE setQuitOnLastWindowClosed NOTIFY quitOnLastWindowClosedChanged)
    Q_PROPERTY(Connection *activeConnection READ activeConnection WRITE setActiveConnection NOTIFY activeConnectionChanged)
    Q_PROPERTY(bool busy READ busy WRITE setBusy NOTIFY busyChanged)
    Q_PROPERTY(KAboutData aboutData READ aboutData WRITE setAboutData NOTIFY aboutDataChanged)
    Q_PROPERTY(QString recaptchaSiteKey READ recaptchaSiteKey WRITE setRecaptchaSiteKey NOTIFY recaptchaSiteKeyChanged)
    Q_PROPERTY(QString recaptchaResponse READ recaptchaResponse WRITE setRecaptchaResponse NOTIFY recaptchaResponseChanged)
    Q_PROPERTY(QString termsName READ termsName WRITE setTermsName NOTIFY termsNameChanged)
    Q_PROPERTY(QString termsUrl READ termsUrl WRITE setTermsUrl NOTIFY termsUrlChanged)

public:
    static Controller &instance();

    QVector<Connection *> connections() const;

    void setActiveConnection(Connection *connection);
    Connection *activeConnection() const;

    void addConnection(Connection *c);
    void dropConnection(Connection *c);

    Q_INVOKABLE void loginWithCredentials(QString, QString, QString, QString);
    Q_INVOKABLE void loginWithAccessToken(QString, QString, QString, QString);

    Q_INVOKABLE void changePassword(Quotient::Connection *connection, const QString &currentPassword, const QString &newPassword);
    
    Q_INVOKABLE void registerAccount(const QString &homeserver, const QString &username, const QString &email, const QString &password);
    Q_INVOKABLE QVector<QVector<QString>> flows(const QString &homeserver) const;

    int accountCount() const;

    bool quitOnLastWindowClosed() const;
    void setQuitOnLastWindowClosed(bool value);

    bool busy() const;
    void setBusy(bool busy);

    void setAboutData(KAboutData aboutData);
    KAboutData aboutData() const;
    
    void setRecaptchaSiteKey(const QString &recaptchaSiteKey);
    QString recaptchaSiteKey() const;
    
    void setRecaptchaResponse(const QString &response);
    QString recaptchaResponse() const;
    
    void setTermsName(const QString &termsname);
    QString termsName() const;
    
    void setTermsUrl(const QString &termsUrl);
    QString termsUrl() const;

    enum PasswordStatus {
        Success,
        Wrong,
        Other,
    };
    Q_ENUM(PasswordStatus);

private:
    explicit Controller(QObject *parent = nullptr);
    ~Controller();

    QVector<Connection *> m_connections;
    QPointer<Connection> m_connection;
    bool m_busy = false;
    QString m_recaptchaSiteKey = "6LcgI54UAAAAABGdGmruw6DdOocFpYVdjYBRe4zb";
    QString m_recaptchaResponse;
    QString m_termsName;
    QString m_termsUrl;

    QByteArray loadAccessTokenFromFile(const AccountSettings &account);
    QByteArray loadAccessTokenFromKeyChain(const AccountSettings &account);

    bool saveAccessTokenToFile(const AccountSettings &account, const QByteArray &accessToken);
    bool saveAccessTokenToKeyChain(const AccountSettings &account, const QByteArray &accessToken);
    void loadSettings();
    void saveSettings() const;

    KAboutData m_aboutData;

private Q_SLOTS:
    void invokeLogin();

Q_SIGNALS:
    void busyChanged();
    void errorOccured(QString error, QString detail);
    void syncDone();
    void connectionAdded(Quotient::Connection *conn);
    void connectionDropped(Quotient::Connection *conn);
    void initiated();
    void notificationClicked(const QString roomId, const QString eventId);
    void quitOnLastWindowClosedChanged();
    void unreadCountChanged();
    void activeConnectionChanged();
    void aboutDataChanged();
    void passwordStatus(Controller::PasswordStatus status);
    void recaptchaSiteKeyChanged();
    void recaptchaResponseChanged();
    void termsNameChanged();
    void termsUrlChanged();

public Q_SLOTS:
    void logout(Quotient::Connection *conn, bool serverSideLogout);
    void joinRoom(Quotient::Connection *c, const QString &alias);
    void createRoom(Quotient::Connection *c, const QString &name, const QString &topic);
    void createDirectChat(Quotient::Connection *c, const QString &userID);
    void playAudio(QUrl localFile);
    void changeAvatar(Quotient::Connection *conn, QUrl localFile);
    void markAllMessagesAsRead(Quotient::Connection *conn);
};

// TODO libQuotient 0.7: Drop
class NeochatChangePasswordJob : public BaseJob
{
public:
    explicit NeochatChangePasswordJob(const QString &newPassword, bool logoutDevices, const Omittable<QJsonObject> &auth = none);
};

class NeochatRegisterJob : public BaseJob {
public:
    explicit NeochatRegisterJob(const QString& kind = QStringLiteral("user"),
                         const Omittable<QJsonObject>& auth = none,
                         const QString& username = {},
                         const QString& password = {},
                         const QString& deviceId = {},
                         const QString& initialDeviceDisplayName = {},
                         Omittable<bool> inhibitLogin = none);

    QString userId() const { return loadFromJson<QString>("user_id"_ls); }

    QString accessToken() const
    {
        return loadFromJson<QString>("access_token"_ls);
    }

    QString homeServer() const
    {
        return loadFromJson<QString>("home_server"_ls);
    }

    QString deviceId() const { return loadFromJson<QString>("device_id"_ls); }
};

#endif // CONTROLLER_H
