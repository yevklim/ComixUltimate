#pragma once

#include <cmath>
#include <QObject>
#include <QQmlEngine>
#include "qqml.h"

class PageLimiter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int rangeSize READ getRangeSize WRITE setRangeSize NOTIFY rangeSizeChanged)
    Q_PROPERTY(int first READ getFirst NOTIFY firstAndLastChanged)
    Q_PROPERTY(int last READ getLast NOTIFY firstAndLastChanged)
    Q_PROPERTY(int current READ getCurrent WRITE setCurrent NOTIFY currentChanged)
    Q_PROPERTY(int limit READ getLimit NOTIFY limitUpdated)
    Q_PROPERTY(int minimumLimit READ getMinimumLimit WRITE setMinimumLimit NOTIFY minimumLimitChanged)
    Q_PROPERTY(int maximumLimit READ getMaximumLimit WRITE setMaximumLimit NOTIFY maximumLimitChanged)
    Q_PROPERTY(int stepSize READ getStepSize WRITE setStepSize NOTIFY stepSizeChanged)
    QML_ELEMENT

    int rangeSize = 0;

    int absoluteMinimumLimit = 1;
    int absoluteMaximumLimit = 10;

    int minimumLimit{};
    int maximumLimit{};

    int limit{};

    int first{};
    int last{};
    int cur{};

    int stepSize = 1;

public:
    explicit PageLimiter(QObject *parent = nullptr);

    void setRangeSize(int num);
    void setMinimumLimit(int num);
    void setMaximumLimit(int num);
    void setCurrent(int num);
    void setStepSize(int num);

    int getRangeSize() const;
    int getMinimumLimit() const;
    int getMaximumLimit() const;
    int getLimit() const;
    int getFirst() const;
    int getLast() const;
    int getCurrent() const;
    int getStepSize() const;

    static int qmlRegisterType(const char *uri, int versionMajor, int versionMinor);

signals:
    void rangeSizeChanged();
    void minimumLimitChanged();
    void maximumLimitChanged();
    void limitUpdated();
    void firstAndLastChanged();
    void currentChanged();
    void stepSizeChanged();

private slots:
    void updateFirstAndLast();
    void updateAbsoluteLimits();
    void updateLimit();

public slots:
    void increaseLimit();
    void decreaseLimit();
    void decreaseLimitTo(int num);
    void resetLimit();
    bool isNumAtRange(int num) const;

    void setConstLimit(int num);
    void maximizeLimit();

};
