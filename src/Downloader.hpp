#pragma once
#include <QtCore>
#include <QtNetwork>
#include <QNetworkAccessManager>
#include <functional>
#include "types.hpp"

#include <QObject>
#include <QDebug>
#include <QPair>
#include <QRegExp>
#include <QJSEngine>
#include <QJSValue>
#include <QList>
#include <QDir>
#include "utility.hpp"

using namespace ComixUltimate;

struct Download
{
    QUrl url;
    UrlHandler::OnFinished onfinished;
    UrlHandler::RequestHeadersSetter requestHeadersSetter = [&](QNetworkRequest *request){};
};
struct DownloadSequence
{
    QStringList urls;
    UrlHandler::OnFinished onfinished;
    UrlHandler::RequestHeadersSetter requestHeadersSetter = [&](QNetworkRequest *request){};
};
using DownloadQueue = QQueue<Download>;
using DownloadStack = QStack<Download>;

class Downloader : public QObject
{
    Q_OBJECT

    QNetworkAccessManager *m_manager = new QNetworkAccessManager{this};
    DownloadQueue m_downloadQueue;
    QByteArray m_userAgent{"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36 OPR/79.0.4143.72"};
    QList<QNetworkReply *> m_currentDownloads;
    int m_downloads_limit;
    const int max_downloads_limit = 25;

    bool m_first_new_then_old = false;

public:
    explicit Downloader(QObject *parent = nullptr, int downloads_limit = 1, bool first_new_then_old = false, QNetworkAccessManager *manager = nullptr);

    void sendRequest(const QByteArray &METHOD, Download download);

    void GET(const Download &download);
    void GET(const DownloadSequence &downloads);

    void HEAD(const Download &download);

    void set_downloads_limit(int downloads_limit);
    int  get_downloads_limit();

    QByteArray get_user_agent();

    QNetworkAccessManager *get_manager();

signals:
    void finished();
    void errorOccured();
    void downloadStarted();

public slots:
    void abortDownloads();
    void reset();

private slots:
    void startNextDownload();
//    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);
//    void downloadFinished();
//    void downloadReadyRead();

};
