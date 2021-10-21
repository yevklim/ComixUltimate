#include "Pager.hpp"

Pager::Pager(QObject *parent) : QObject(parent)
{
    connect(this, &Pager::pagesChanged, this, &Pager::updatePage);
}

void Pager::setPage(int num)
{
    if (num < 0)
    {
        num = 0;
    }
    if (num >= pages)
    {
        num = pages - 1; //Yeah... -1 allowed
    }
    if (page != num)
    {
        page = num;
        emit pageChanged();
    }
}

void Pager::setPages(int num)
{
    if (num >= 0 && num != pages)
    {
        pages = num;
        emit pagesChanged();
    }
}

int Pager::getPage() const
{
    return page;
}

int Pager::getPages() const
{
    return pages;
}

int Pager::getLastPage() const
{
    return pages - 1;
}

bool Pager::isPageFirst() const
{
    return pages == 0 || page == 0;
}

bool Pager::isPageLast() const
{
    return pages == 0 || page == pages - 1;
}

int Pager::qmlRegisterType(const char *uri, int versionMajor, int versionMinor)
{
    return ::qmlRegisterType<Pager>(uri, versionMajor, versionMinor, "Pager");
}

void Pager::updatePage()
{
    setPage(page);
}

void Pager::toFirstPage()
{
    setPage(0);
}

void Pager::toLastPage()
{
    setPage(pages - 1);
}
