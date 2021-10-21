#pragma once

#include <string>
#include <vector>
#include <ctime>
//#include <compare>
#include <algorithm>
#include <functional> // std::hash

#include "FilterParams.hpp"
#include "types.hpp"   // ComixUltimate::rate_t
#include "utility.hpp" // ComixUltimate::includes2

#include <QObject>
#include <QQmlEngine>
#include <QDebug>

#include <QDateTime>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QString>
#include <QStringList>
#include <QVector>
#include "qqml.h"

using ComixUltimate::qrate_t;
using ComixUltimate::qhash_t;
using ComixUltimate::qtime_t;
using ComixUltimate::ItemType;
using std::size_t;
using std::string;
//using std::strong_ordering;
using std::time_t;
using std::vector;

class DBItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qint64 hash READ get_hash NOTIFY hashChanged RESET generate_hash)
    Q_PROPERTY(int type READ get_type WRITE set_type NOTIFY typeChanged)
    Q_PROPERTY(QString source READ get_source WRITE set_source NOTIFY sourceChanged)
    Q_PROPERTY(QString title READ get_title WRITE set_title NOTIFY titleChanged)
    Q_PROPERTY(QString cover READ get_cover WRITE set_cover NOTIFY coverChanged)
    Q_PROPERTY(qint64 added READ get_added WRITE set_added NOTIFY addedChanged)
    Q_PROPERTY(qint64 lastview READ get_lastview WRITE set_lastview NOTIFY lastviewChanged)
    Q_PROPERTY(int rate READ get_rate WRITE set_rate NOTIFY rateChanged)
    Q_PROPERTY(QStringList tags READ get_tags WRITE set_tags NOTIFY tagsChanged)
    QML_ELEMENT

    friend class DataBase;
    friend class Playlists;

private:
    qhash_t m_hash;

    ItemType m_type{ ComixUltimate::ComicBook };
    QString m_source;
    QString m_title;
    QString m_cover;

    qtime_t m_added;
    qtime_t m_lastview;

    qrate_t m_rate;

    QStringList m_tags;

public:
    DBItem(QObject *parent = nullptr) : QObject(parent) {
        m_added = QDateTime::currentMSecsSinceEpoch();
        m_lastview = 0;
        m_rate = 0;
    }
    DBItem(
        QObject *parent,
        ItemType type,
        QString source,
        QString title,
        QString cover,
        time_t added,
        time_t lastview,
        qrate_t rate,
        QStringList tags) : QObject(parent),
                            m_source{source},
                            m_title{title},
                            m_cover{cover},
                            m_added{added},
                            m_lastview{lastview},
                            m_rate{rate},
                            m_tags{tags}
    {
        m_type = type;
        generate_hash();
    }
    DBItem(
        QObject *parent,
        DBItem *other) : QObject(parent),
                         m_type{other->m_type},
                         m_source{other->m_source},
                         m_title{other->m_title},
                         m_cover{other->m_cover},
                         m_added{other->m_added},
                         m_lastview{other->m_lastview},
                         m_rate{other->m_rate},
                         m_tags{other->m_tags}
    {
        m_type = other->m_type;
        generate_hash();
    }
    DBItem(QObject *parent,
           const QJsonObject &json,
           bool readHash = false) : QObject(parent)
    {
        read(json, readHash);
    }
    ~DBItem() {}

    qhash_t get_hash() const;
    qhash_t generate_hash();

    int get_type() const;
    QString get_source() const;
    QString get_title() const;
    QString get_cover() const;
    qtime_t get_added() const;
    qtime_t get_lastview() const;
    qrate_t get_rate() const;
    QStringList get_tags() const;

    void set_type(int type);
    void set_source(QString source);
    void set_title(QString title);
    void set_cover(QString cover);
    void set_added(qtime_t added);
    void set_lastview(qtime_t lastview);
    void set_rate(qrate_t rate);
    void set_tags(QStringList tags);

    bool pass_filters(const FilterParams &filter_params) const;
    int compare(DBItem *other, QString param) const;

    void read(const QJsonObject &json, bool readHash = false);
    void write(QJsonObject &json, bool writeHash = false) const;

    static int qmlRegisterType(const char *uri, int versionMajor, int versionMinor);
    static int qRegisterMetaType();
public slots:
    void update_lastview();

    bool has_tag(QString tag) const;
    bool has_tags(QStringList tags) const;

    void push_tag(QString tag);
    void push_tags(QStringList tags);

    void pop_tag(QString tag);
    void pop_tags(QStringList tags);
signals:
    void objectChanged();
    void hashChanged();
    void typeChanged();
    void sourceChanged();
    void titleChanged();
    void coverChanged();
    void addedChanged();
    void lastviewChanged();
    void rateChanged();
    void tagsChanged();
};
