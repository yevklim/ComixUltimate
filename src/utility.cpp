#include "utility.hpp"

QStringList ComixUltimate::getSubQStringsWithRegExp(const QString &target, const QString &pattern)
{
    QRegExp rx(pattern);
    QStringList list;
    int pos = 0;

    while ((pos = rx.indexIn(target, pos)) != -1) {
        list << rx.cap(1);
        pos += rx.matchedLength();
    }
    return list;
}

QString ComixUltimate::getSubQStringWithRegExp(const QString &target, const QString &pattern)
{
    QRegExp rx(pattern);
    if (rx.indexIn(target) != -1)
        return rx.cap(1);
    return "";
}


QString ComixUltimate::get_simplified_url(const QString &url)
{
    QString result = url;
    result.replace(QRegularExpression("(^.*://|www.|/^)"), "");
    return result;
}
