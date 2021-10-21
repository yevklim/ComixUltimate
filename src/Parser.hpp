#pragma once
#include <QtCore>
#include <QtNetwork>
#include <QNetworkAccessManager>
#include <functional>
#include "types.hpp"
#include "Downloader.hpp"

#include <QObject>
#include <QDebug>
#include <QPair>
#include <QRegExp>
#include <QJSEngine>
#include <QJSValue>
#include <QList>
#include <QDir>
#include "utility.hpp"
#include <chrono>
using namespace std::chrono;

using namespace ComixUltimate;

class Parser: public QObject
{
    Q_OBJECT
public:
    explicit Parser(QObject *parent = nullptr);

signals:
    void finished(const QString &url);
    void errorOccured(const QString &url);
    void downloadStarted(const QString &url);
    void partiallyReady(const QString &url, const QStringList &links);
    void completelyReady(const QString &url);

public slots:
    void requestLinks(const QString &url);

private:
    QMap<QString, UrlHandler::UrlHandler> handlers;
    Downloader downloader{this};

    void setHandler(QString handlerName, UrlHandler::UrlHandler handlerFunc);
    UrlHandler::UrlHandler &getHandler(const QUrl &qurl);
};
