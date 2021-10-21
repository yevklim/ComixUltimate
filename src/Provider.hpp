#pragma once

#include <QtCore>
#include <QtNetwork>
#include <QNetworkAccessManager>
#include <QStandardPaths>
#include <QQuickImageProvider>
#include <QImage>
#include <QDir>
#include <functional>
#include "types.hpp"
#include "Downloader.hpp"
#include "Parser.hpp"
#include "DBItem.hpp"
#include "DataBase.hpp"

#include <QObject>
#include <QDebug>
#include <QPair>
#include <QRegExp>
#include <QJSEngine>
#include <QJSValue>
#include <QList>
#include <QDir>
#include <QThreadPool>
#include "utility.hpp"
#include "ProvidedItemsManager.hpp"

class MasterProvider : public QObject
{
    Q_OBJECT

    const QDir cache_path{QStandardPaths::standardLocations(QStandardPaths::CacheLocation).at(0)};
    DataBase *m_database;
    QNetworkAccessManager *m_manager = new QNetworkAccessManager{this};
    Downloader *m_downloader = new Downloader{this, 10, true, m_manager};
    Parser *m_parser = new Parser{this};

    QString m_last_requested_url;

    ProvidedItemsManager *m_items_manager;

public:
    explicit MasterProvider(QObject *parent, DataBase *database);
    ~MasterProvider();

signals:
    void finished(const QString &url);
    void errorOccured(const QString &url);
    void downloadStarted(const QString &url);
    void partiallyReady(const QString &url, int links_num, bool toEnd = true, bool toBegin = false);
    void completelyReady(const QString &url, int links_num);

    void linkFixed(qhash_t hash, int index, const QString &fixed_link);

public slots:
    void requestLinks(const QString &url);
    void abortDownloads();
    QString get_real_link(qhash_t hash, int index);
    QStringList get_real_links(qhash_t hash, int from, int to);
    void fix_real_link(qhash_t hash, int index);

    QString get_user_agent();

private slots:

};
