#include "LocalCachingNetworkAccessManagerFactory.hpp"

QNetworkAccessManager *LocalCachingNetworkAccessManagerFactory::create(QObject *parent)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(parent);
    QNetworkDiskCache *disk_cache = new QNetworkDiskCache(manager);
    disk_cache->setCacheDirectory(cache_path.absolutePath());
    disk_cache->setMaximumCacheSize(maximumCacheSize);
    manager->setCache(disk_cache);
    return manager;
}
