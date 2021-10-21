#pragma once
#include <QtCore>
#include <QStandardPaths>
#include <functional>
#include "types.hpp"
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
#include "Downloader.hpp"
#include "utility.hpp"

struct ProvidedItem
{
    DBItem *item;
    QStringList links{};
    QStringList new_links{};
};
using ProvidedItemsList = QList<ProvidedItem *>;

class ProvidedItemsManager : public QObject, public ISaveLoad
{
    Q_OBJECT

    DataBase *m_database;
    ProvidedItemsList m_items{};
    Downloader *m_downloader;
    QDir m_cache_path;

    QString savefile = "";

public:
    explicit ProvidedItemsManager(QObject *parent, DataBase *database, Downloader *downloader, QDir cache_path) :
        QObject{parent}, ISaveLoad{}, m_database{database}, m_downloader{downloader}, m_cache_path{cache_path}
    {
        load(saveFormat);
    }
    ~ProvidedItemsManager()
    {
        save(saveFormat);
    }

    //BUG: fix ptr errors after items deletion from DB
    ProvidedItem *get_item(const QString &source, bool exact_match = true);
    ProvidedItem *get_item(qhash_t hash);

    bool update_cached_links(ProvidedItem *item);

    DataBase *get_database();
    ProvidedItemsList &get_items();
    Downloader *get_downloader();

    QString filepath() const override;
    void read(const QJsonObject &json) override;
    void write(QJsonObject &json) const override;;
private:
    QStringList get_simplified_urls(const QStringList &urls);
    QString get_simplified_url(const QString &url);
    void simplify_url(QString &url);
};
