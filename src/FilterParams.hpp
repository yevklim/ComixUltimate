#pragma once

#include <string>
#include <vector>
#include <ctime> // std::time_t
#include <algorithm>

#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QStringList>
#include <QDebug>
#include "qqml.h"
#include "types.hpp" // ComixUltimate::rate_t

using ComixUltimate::qrate_t;
using ComixUltimate::qtime_t;
using ComixUltimate::ItemType;
using std::string;
using std::time_t;
using std::vector;

class FilterParams : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ItemType type READ get_type WRITE set_type NOTIFY typeChanged)
    Q_PROPERTY(QString source READ get_source WRITE set_source NOTIFY sourceChanged)
    Q_PROPERTY(QString title READ get_title WRITE set_title NOTIFY titleChanged)
    Q_PROPERTY(qint64 added READ get_added WRITE set_added NOTIFY addedChanged)
    Q_PROPERTY(qint64 lastview READ get_lastview WRITE set_lastview NOTIFY lastviewChanged)
    Q_PROPERTY(qint8 rate READ get_rate WRITE set_rate NOTIFY rateChanged)
    Q_PROPERTY(QStringList tags READ get_tags WRITE set_tags NOTIFY tagsChanged)
    QML_ELEMENT

    friend class DBItem;
    friend class DataBase;
    friend class HistoryViewer;

private:
    ItemType m_type{ComixUltimate::UndefinedType};
    QString m_source = "";
    QString m_title = "";

    qtime_t m_added = 0;
    qtime_t m_lastview = 0;

    qrate_t m_rate = 0;

    QStringList m_tags = {};

    vector<bool> m_changed{false, false, false, false, false, false, false};
    enum
    {
        Type,
        Source,
        Title,
        Added,
        LastView,
        Rate,
        Tags
    };

public:
    FilterParams(QObject *parent = nullptr) : QObject(parent) {}
    FilterParams(
        QObject *parent,
        ItemType type,
        QString source,
        QString title,
        qtime_t added,
        qtime_t lastview,
        qrate_t rate,
        QStringList tags) : QObject(parent)
    {
        set_type(type);
        set_source(source);
        set_title(title);
        set_added(added);
        set_lastview(lastview);
        set_rate(rate);
        set_tags(tags);
    }
    FilterParams(QObject *parent, const QJsonObject &json) : QObject(parent)
    {
        read(json, true);
    }
    ~FilterParams() {}

    ItemType get_type() const;
    QString get_source() const;
    QString get_title() const;
    qtime_t get_added() const;
    qtime_t get_lastview() const;
    qrate_t get_rate() const;
    QStringList get_tags() const;

    void set_type(ItemType type);
    void set_source(QString source);
    void set_title(QString title);
    void set_added(qtime_t added);
    void set_lastview(qtime_t lastview);
    void set_rate(qrate_t rate);
    void set_tags(QStringList tags);

    bool check_type() const;
    bool check_source() const;
    bool check_title() const;
    bool check_added() const;
    bool check_lastview() const;
    bool check_rate() const;
    bool check_tags() const;

    bool check_all() const;
    bool check_any() const;

    bool has_tag(QString tag) const;
    bool has_tags(QStringList tags) const;

    void push_tag(QString tag);
    void push_tags(QStringList tags);

    void pop_tag(QString tag);
    void pop_tags(QStringList tags);

    void merge(const FilterParams &other);
    FilterParams merge_copy(const FilterParams &other);

    void read(const QJsonObject &json, bool firstRead = false);
    void write(QJsonObject &json) const;

    static int qmlRegisterType(const char *uri, int versionMajor, int versionMinor);
    static int qRegisterMetaType();
public slots:
signals:
    void objectChanged();
    void typeChanged();
    void sourceChanged();
    void titleChanged();
    void coverChanged();
    void addedChanged();
    void lastviewChanged();
    void rateChanged();
    void tagsChanged();
};
