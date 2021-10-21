#pragma once

#include <QObject>
#include <QJsonObject>
#include <QString>
#include <QCborMap>
#include <QCborValue>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>


class ISaveLoad
{

public:
    ISaveLoad() {}

    enum SaveFormat {
        Json, Binary
    };
    SaveFormat saveFormat = Json;

    virtual QString filepath() const = 0;

    virtual void read(const QJsonObject &json) = 0;
    virtual void write(QJsonObject &json) const = 0;

    bool load();
    bool load(SaveFormat saveFormat);
    bool save() const;
    bool save(SaveFormat saveFormat) const;
};
