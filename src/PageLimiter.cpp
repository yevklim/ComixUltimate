#include "PageLimiter.hpp"

PageLimiter::PageLimiter(QObject *parent) : QObject(parent)
{
    connect(this, &PageLimiter::rangeSizeChanged, this, &PageLimiter::updateAbsoluteLimits);
    connect(this, &PageLimiter::minimumLimitChanged, this, &PageLimiter::updateLimit);
    connect(this, &PageLimiter::maximumLimitChanged, this, &PageLimiter::updateLimit);
    connect(this, &PageLimiter::limitUpdated, this, &PageLimiter::updateFirstAndLast);
    connect(this, &PageLimiter::currentChanged, this, &PageLimiter::updateFirstAndLast);
}

void PageLimiter::setRangeSize(int num)
{
    if (num > 0 && num != rangeSize)
    {
        rangeSize = num;
        emit rangeSizeChanged();
    }
}

void PageLimiter::setMinimumLimit(int num)
{
    if (num > 0 && num <= absoluteMaximumLimit && num != absoluteMinimumLimit)
    {
        absoluteMinimumLimit = num;
        minimumLimit = num < rangeSize ? num : rangeSize;
        emit minimumLimitChanged();
    }
}

void PageLimiter::setMaximumLimit(int num)
{
    if (num >= absoluteMinimumLimit && num != absoluteMaximumLimit)
    {
        absoluteMaximumLimit = num;
        maximumLimit = num < rangeSize ? num : rangeSize;
        emit maximumLimitChanged();
    }
}

void PageLimiter::setCurrent(int num)
{
    if (num >= 0 && num < rangeSize && num != cur)
    {
        cur = num;
        emit currentChanged();
        updateFirstAndLast();
    }
}

void PageLimiter::setStepSize(int num)
{
    //TODO: add a condition
    if (num > 0)
    {
        stepSize = num;
        emit stepSizeChanged();
    }

}

int PageLimiter::getRangeSize() const
{
    return rangeSize;
}

int PageLimiter::getMinimumLimit() const
{
    return minimumLimit;
}

int PageLimiter::getMaximumLimit() const
{
    return maximumLimit;
}

int PageLimiter::getLimit() const
{
    return limit;
}

int PageLimiter::getFirst() const
{
    return first;
}

int PageLimiter::getLast() const
{
    return last;
}

int PageLimiter::getCurrent() const
{
    return cur;
}

int PageLimiter::getStepSize() const
{
    return stepSize;
}

int PageLimiter::qmlRegisterType(const char *uri, int versionMajor, int versionMinor)
{
    return ::qmlRegisterType<PageLimiter>(uri, versionMajor, versionMinor, "PageLimiter");
}

void PageLimiter::updateFirstAndLast()
{
    float halfLimit = (float)limit / 2;
    int halfLimitFloor = std::floor(halfLimit),
        halfLimitCeil = std::ceil(halfLimit);

    if (cur <= halfLimitFloor)
    {
        first = 0;
        last = limit - 1;
    }
    else
    if (cur >= rangeSize - halfLimitFloor)
    {
        first = rangeSize - limit;
        last = rangeSize - 1;
    }
    else//if (cur > halfLimitFloor)
    {
        first = cur - halfLimitFloor;
        last = cur + halfLimitCeil - 1;
    }

//    first = std::floor(first / stepSize) * stepSize;
//    last = std::ceil(last / stepSize) * stepSize;

    emit firstAndLastChanged();
}

void PageLimiter::updateAbsoluteLimits()
{
    minimumLimit = absoluteMinimumLimit < rangeSize ? absoluteMinimumLimit : rangeSize;
    maximumLimit = absoluteMaximumLimit < rangeSize ? absoluteMaximumLimit : rangeSize;
    updateLimit();
}

void PageLimiter::updateLimit()
{
    if (limit > maximumLimit)
    {
        limit = maximumLimit;
        emit limitUpdated();
    }
    if (limit < minimumLimit)
    {
        limit = minimumLimit;
        emit limitUpdated();
    }
}

void PageLimiter::increaseLimit()
{
    if (limit < maximumLimit)
    {
        limit++;
        emit limitUpdated();
    }
}

void PageLimiter::decreaseLimit()
{
    if (limit > minimumLimit)
    {
        limit--;
        emit limitUpdated();
    }
}

void PageLimiter::decreaseLimitTo(int num)
{
    if (num > minimumLimit && num < limit)
    {
        limit = num;
        emit limitUpdated();
    }
}

void PageLimiter::resetLimit()
{
    limit = minimumLimit;
    emit limitUpdated();
}

bool PageLimiter::isNumAtRange(int num) const
{
    return num >= first && num <= last;
}

void PageLimiter::setConstLimit(int num)
{
    //    limit = num;
}

void PageLimiter::maximizeLimit()
{
    if (limit != maximumLimit)
    {
        limit = maximumLimit;
        emit limitUpdated();
    }
}
