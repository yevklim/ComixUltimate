#include "ISaveLoad.hpp"

bool ISaveLoad::load()
{
    return load(saveFormat);
}
bool ISaveLoad::load(ISaveLoad::SaveFormat saveFormat)
{
    QFile loadFile(filepath());

    if (!loadFile.open(QIODevice::ReadOnly)) {
        qWarning() << "Couldn't open file: " << filepath();
        return false;
    }

    QByteArray saveData = loadFile.readAll();
    QJsonDocument loadDoc;

    if (saveFormat == Json)
    {
        loadDoc = QJsonDocument::fromJson(saveData);
    }
    else
    {
        loadDoc = QJsonDocument(QCborValue::fromCbor(saveData).toMap().toJsonObject());
    }

    read(loadDoc.object());

    qInfo() << filepath() << "was loaded!";
    return true;
}

bool ISaveLoad::save() const
{
    return save(saveFormat);
}
bool ISaveLoad::save(ISaveLoad::SaveFormat saveFormat) const
{
    QFile saveFile(filepath());

    if (!saveFile.open(QIODevice::WriteOnly)) {
        qWarning() << "Couldn't open file: " << filepath();
        return false;
    }

    QJsonObject qDataBase;
    write(qDataBase);
    saveFile.write(saveFormat == Json
        ? QJsonDocument(qDataBase).toJson()
        : QCborValue::fromJsonValue(qDataBase).toCbor());
    qInfo() << filepath() << "was saved!";
    return true;
}
