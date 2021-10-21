#pragma once

#include <QStandardPaths>
#include <QtNetwork>
#include <QNetworkAccessManager>
#include <QQmlNetworkAccessManagerFactory>


class LocalCachingNetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory
{
    const QDir cache_path{QStandardPaths::standardLocations(QStandardPaths::CacheLocation).at(0)};
    const long maximumCacheSize = 1073742000; //1GiB
public:
    QNetworkAccessManager *create(QObject *parent) override;
};
