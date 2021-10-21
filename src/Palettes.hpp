#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QMap>
#include <QString>
#include <QColor>
#include <QJsonDocument>
#include <QJsonObject>
#include "ISaveLoad.hpp"

using Palette = QMap<QString, QVariant>;

class Palettes : public QObject, public ISaveLoad
{
    Q_OBJECT
    Q_PROPERTY(QString currentName READ getCurrentPaletteName WRITE setCurrentPaletteName NOTIFY currentChanged)
    Q_PROPERTY(QMap<QString, QVariant> current READ getCurrentPalette WRITE setCurrentPalette NOTIFY currentChanged)
    Q_PROPERTY(QMap<QString, QVariant> blank READ getBlankPalette NOTIFY palettesChanged)
    Q_PROPERTY(QStringList paletteNames READ getPaletteNames NOTIFY palettesChanged)
    Q_PROPERTY(QStringList colorNames READ getColorNames NOTIFY palettesChanged)
//    QML_ELEMENT

    QMap<QString, Palette> palettes{};
    QStringList colorNames{};
    QString currentPaletteName = "";

    QString savefile = "palettes";

    void normalizePalettes();
    void normalizePalette(Palette &palette);
public:
    explicit Palettes(QObject *parent = nullptr);
    ~Palettes();

    QString filepath() const override;

    QString getCurrentPaletteName();
    void setCurrentPaletteName(QString paletteName);

    Palette getBlankPalette();
    Palette &getCurrentPalette();
    void setCurrentPalette(Palette palette);

    QStringList getPaletteNames() const;
    QStringList getColorNames() const;

    void read(const QJsonObject &json) override;
    void write(QJsonObject &json) const override;

public slots:
    Palette &getPalette(QString paletteName);
    void setPalette(QString paletteName, Palette palette);

    bool addNewPalette(QString paletteName, Palette newPalette);
    bool renamePalette(QString oldName, QString newName);
    bool removePalette(QString paletteName);

    void setColor(QString colorName, QString color);
    void setColor(QString paletteName, QString colorName, QString color);

    bool addNewColor(QString colorName, QString color = "#0f0");
    bool renameColor(QString oldName, QString newName);
    bool removeColor(QString colorName);
signals:
    void currentChanged();

    void palettesChanged();
    void paletteAdded();
    void paletteRenamed();
    void paletteRemoved();
    void colorAdded();
    void colorRenamed();
    void colorRemoved();

};
