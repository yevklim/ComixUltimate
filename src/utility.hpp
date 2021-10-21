#pragma once
#include <algorithm>
#include <QString>
#include <QStringList>
#include <QRegExp>
#include <QRegularExpression>
#include <QUrl>
//#include <compare> // std::strong_ordering, operator<=>

namespace ComixUltimate
{

    template <class T>
    constexpr bool
    includes2(T valarray1, T valarray2)
    {
        return std::includes(
            std::begin(valarray1), std::end(valarray1),
            std::begin(valarray2), std::end(valarray2));
    }

    template <typename T>
    constexpr bool
    cmp_less(T __t)
    {
        return __t < 0;
    }

    template <typename T>
    constexpr bool
    cmp_greater(T __t)
    {
        return __t > 0;
    }

    template <typename T>
    int signum(T val) {
        return (T(0) < val) - (val < T(0));
    }

    QString get_simplified_url(const QString &url);

    QStringList getSubQStringsWithRegExp(const QString &target, const QString &pattern);

    QString getSubQStringWithRegExp(const QString &target, const QString &pattern);

} // namespace ComixUltimate
