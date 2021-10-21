#pragma once

#include <string>
#include <vector>
#include <ctime>   // std::time_t, std::size_t
//#include <compare> // std::strong_ordering, operator<=>
// #include <utility>

#include "FilterParams.hpp"
#include "SorterParams.hpp"
#include "DBItem.hpp"
#include "types.hpp"
#include "utility.hpp"

#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QDebug>

#include <QJsonObject>
#include <QCborMap>
#include <QCborValue>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QRandomGenerator>
#include <QTextStream>
#include <QVector>
#include "ISaveLoad.hpp"

using ComixUltimate::qrate_t;
using ComixUltimate::qhash_t;
using ComixUltimate::qtime_t;
using std::size_t;
using std::string;
//using std::strong_ordering;
using std::time_t;
using std::vector;

class DataBase : public QObject, public ISaveLoad
{
    Q_OBJECT
    Q_PROPERTY(int length READ size NOTIFY sizeChanged)
    Q_PROPERTY(QVector<DBItem *> items READ get_items NOTIFY itemsChanged)
    Q_PROPERTY(QStringList tags READ get_tags WRITE set_tags NOTIFY tagsChanged)
    QML_ELEMENT

    QVector<DBItem *> m_items;
    QStringList m_tags;

    DBItem *new_item = nullptr;

protected:
    QString savefile = "db";

public:
    explicit DataBase(QObject *parent = nullptr, QVector<DBItem *> items = {}) : QObject(parent), ISaveLoad(), m_items{items} {
        qInfo() << "DataBase has been constructed!";
    }
    ~DataBase() {
        save();
        qInfo() << "DataBase has been destructed!";
    }

    enum SaveFormat {
        Json, Binary
    };
    SaveFormat saveFormat = Json;

    QString filepath() const override;

    QVector<DBItem *> get_items();
    QVector<DBItem *> get_items(const FilterParams &filter_params, const SorterParams &sorter_params);
    QVector<DBItem *> get_items(const SorterParams &sorter_params, const FilterParams &filter_params);
    QVector<DBItem *> get_filtered(const FilterParams &filter_params);
    QVector<DBItem *> get_filtered(const FilterParams &filter_params, QVector<DBItem *> items);
    QVector<DBItem *> get_sorted(const SorterParams &sorter_params);
    QVector<DBItem *> get_sorted(const SorterParams &sorter_params, QVector<DBItem *> items);

    DBItem *get_item(qhash_t hash) const;
    DBItem *get_item(QString source, bool exact_match = true) const;
    DBItem *operator[](qhash_t hash) const;
    DBItem *operator[](QString source) const;

    bool contain_item(DBItem *item) const;
    bool contain_items(QVector<DBItem *> items) const;

    void push_items(QVector<DBItem *> items);

    void remove_item(DBItem *item);
    void remove_items(QVector<DBItem *> items);

    QStringList get_tags() const;
    void set_tags(QStringList tags);

    size_t size() const;
    QVector<DBItem *>::iterator begin();
    QVector<DBItem *>::iterator end();
    
    void read(const QJsonObject &json) override;
    void write(QJsonObject &json) const override;

public slots:
    void requestItems();

    void push_item(DBItem *item);

    void remove_item(qhash_t hash);
    void remove_item(QString source);

    DBItem *get_new_item();
    void add_new_item();

    bool has_tag(QString tag) const;
    bool has_tags(QStringList tags) const;

    void push_tag(QString tag);
    void push_tags(QStringList tags);

    void pop_tag(QString tag);
    void pop_tags(QStringList tags);

signals:
    void sendItems(QVector<DBItem *> items);

    void objectChanged();
    void itemsChanged();
    void itemRemoved();
    void itemAdded();
    void sizeChanged();
    void tagsChanged();
};
