#include "Palettes.hpp"

void Palettes::normalizePalettes()
{
    foreach(QString paletteName, palettes.keys())
    {
        Palette &pal = palettes[paletteName];
        normalizePalette(pal);
    }
}

void Palettes::normalizePalette(Palette &palette)
{
    Palette blank = getBlankPalette();
    foreach(QString colorName, colorNames)
    {
        if (palette.contains(colorName))
        {
            blank[colorName] = palette[colorName];
        }
    }
    palette = blank;
}

Palettes::Palettes(QObject *parent) : QObject(parent), ISaveLoad()
{
    load(saveFormat);
    connect(this, &Palettes::currentChanged, this, &Palettes::palettesChanged);
    connect(this, &Palettes::paletteAdded, this, &Palettes::palettesChanged);
    connect(this, &Palettes::paletteRenamed, this, &Palettes::palettesChanged);
    connect(this, &Palettes::paletteRemoved, this, &Palettes::palettesChanged);
    connect(this, &Palettes::colorAdded, this, &Palettes::palettesChanged);
    connect(this, &Palettes::colorRenamed, this, &Palettes::palettesChanged);
    connect(this, &Palettes::colorRemoved, this, &Palettes::palettesChanged);
}

Palettes::~Palettes()
{
    save(saveFormat);
}

QString Palettes::filepath() const
{
    return savefile;
}

QString Palettes::getCurrentPaletteName()
{
    return currentPaletteName;
}

void Palettes::setCurrentPaletteName(QString paletteName)
{
    if (getPaletteNames().contains(paletteName) && currentPaletteName != paletteName)
    {
        currentPaletteName = paletteName;
        emit currentChanged();
    }
}

QStringList Palettes::getPaletteNames() const
{
    return palettes.keys();
}

QStringList Palettes::getColorNames() const
{
    return colorNames;
}

void Palettes::read(const QJsonObject &json)
{
    if (json.contains("current") && json["current"].isString())
    {
        currentPaletteName = json["current"].toString();
    }
    if (json.contains("colorNames") && json["colorNames"].isArray())
    {
        colorNames = json["colorNames"].toVariant().toStringList();
    }
    if (json.contains("palettes") && json["palettes"].isObject())
    {
        palettes.clear();
        QMap jsonPalettes = json["palettes"].toVariant().toMap();
        QStringList paletteNames = jsonPalettes.keys();
        foreach(QString paletteName, paletteNames)
        {
            palettes[paletteName] = jsonPalettes[paletteName].toJsonObject().toVariantMap();
        }

        if (!paletteNames.contains(currentPaletteName))
        {
            currentPaletteName = paletteNames[0];
        }
        normalizePalettes();
    }
}

void Palettes::write(QJsonObject &json) const
{
    json["current"] = currentPaletteName;
    json["colorNames"] = QVariant::fromValue(colorNames).toJsonArray();
    QJsonObject jsonPalettes;
    foreach(QString paletteName, palettes.keys())
    {
        jsonPalettes[paletteName] = QVariant::fromValue(palettes[paletteName]).toJsonObject();
    }
    json["palettes"] = jsonPalettes;
}

Palette Palettes::getBlankPalette()
{
    Palette blankPalette;
    foreach(QString colorName, colorNames)
    {
        blankPalette[colorName] = "#0f0";
    }
    return blankPalette;
}

Palette &Palettes::getCurrentPalette()
{
    return palettes[currentPaletteName];
}

void Palettes::setCurrentPalette(Palette palette)
{
    normalizePalette(palette);
    palettes[currentPaletteName] = palette;
}

Palette &Palettes::getPalette(QString paletteName)
{
    return palettes[paletteName];
}

void Palettes::setPalette(QString paletteName, Palette palette)
{
    normalizePalette(palette);
    palettes[paletteName] = palette;
}

bool Palettes::addNewPalette(QString paletteName, Palette newPalette)
{
    if (!getPaletteNames().contains(paletteName))
    {
        palettes[paletteName] = newPalette;
        emit paletteAdded();
        return true;
    }
    return false;
}

bool Palettes::renamePalette(QString oldName, QString newName)
{
    if (!getPaletteNames().contains(oldName)) {
        return false;
    }
    else
    if(getPaletteNames().contains(newName)) {
        return false;
    }
    else {
        palettes[newName] = palettes[oldName];
        palettes.remove(oldName);
        emit paletteRenamed();
        if (currentPaletteName == oldName)
        {
            setCurrentPaletteName(newName);
        }
        return true;
    }
}

bool Palettes::removePalette(QString paletteName)
{
    if (palettes.contains(paletteName))
    {
        palettes.remove(paletteName);
        emit paletteRemoved();
        if (currentPaletteName == paletteName)
        {
            currentPaletteName = getPaletteNames().value(0);
            emit currentChanged();
        }
        return true;
    }
    return false;
}

void Palettes::setColor(QString colorName, QString color)
{
    setColor(currentPaletteName, colorName, color);
}
void Palettes::setColor(QString paletteName, QString colorName, QString color)
{
    palettes[paletteName][colorName] = color;
    if (paletteName == currentPaletteName)
    {
        emit currentChanged();
    }
    else
    {
        emit palettesChanged();
    }

}

bool Palettes::addNewColor(QString colorName, QString color)
{
    if (!colorNames.contains(colorName))
    {
        colorNames.append(colorName);
        normalizePalettes();
        palettes[currentPaletteName][colorName] = color;
        emit colorAdded();
        return true;
    }
    return false;
}

bool Palettes::renameColor(QString oldName, QString newName)
{
    if (!colorNames.contains(oldName)) {
        return false;
    }
    else
    if(colorNames.contains(newName)) {
        return false;
    }
    else
    {
        foreach(Palette pal, palettes)
        {
//            Palette &pal = palettes[paletteName];
            pal[newName] = pal[oldName];
            pal.remove(oldName);
        }
        colorNames.append(newName);
        colorNames.removeOne(oldName);
        emit colorRenamed();
        return true;
    }
}

bool Palettes::removeColor(QString colorName)
{
    if (colorNames.contains(colorName))
    {
        colorNames.removeOne(colorName);
        normalizePalettes();
        emit colorRemoved();
        return true;
    }
    return false;
}

