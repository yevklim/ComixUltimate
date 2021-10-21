#pragma once

#include <string>
#include <vector>
#include <ctime> // std::time_t
#include <algorithm>

// #include "types.hpp"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QObject>
#include <QQmlEngine>
#include <QDebug>
#include <QString>
#include <QVector>
#include "qqml.h"

using std::string;
using std::vector;

class SorterParams : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString param READ get_param WRITE set_param NOTIFY paramChanged)
    Q_PROPERTY(bool alphabet READ get_alphabet WRITE set_alphabet NOTIFY alphabetChanged)
    Q_PROPERTY(bool reversed READ get_reversed WRITE set_reversed NOTIFY reversedChanged)
    QML_ELEMENT

    friend class DBItem;
    friend class DataBase;
    friend class HistoryViewer;

private:
    QString m_param = "";
    bool m_alphabet = false;
    bool m_reversed = false;

    vector<bool> m_changed{false, false, false};
    enum
    {
        Param,
        Alphabet,
        Reversed
    };

public:
    SorterParams(QObject *parent = nullptr) : QObject(parent) {}
    SorterParams(
        QObject *parent,
        QString param,
        bool alphabet,
        bool reversed) : QObject(parent)
    {
        set_param(param);
        set_alphabet(alphabet);
        set_reversed(reversed);
    }
    SorterParams(QObject *parent, const QJsonObject &json) : QObject(parent)
    {
        read(json);
    }
    ~SorterParams() {}

    QString get_param() const;
    bool get_alphabet() const;
    bool get_reversed() const;

    void set_param(QString param);
    void set_alphabet(bool alphabet);
    void set_reversed(bool reversed);

    bool check_param() const;
    bool check_alphabet() const;
    bool check_reversed() const;

    bool check_all() const;
    bool check_any() const;

    void merge(const SorterParams &other);
    SorterParams merge_copy(const SorterParams &other);

    void read(const QJsonObject &json);
    void write(QJsonObject &json) const;

    static int qmlRegisterType(const char *uri, int versionMajor, int versionMinor);
    static int qRegisterMetaType();
public slots:
signals:
    void objectChanged();
    void paramChanged();
    void alphabetChanged();
    void reversedChanged();
};
