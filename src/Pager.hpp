#pragma once

#include <cmath>
#include <QObject>
#include <QQmlEngine>
#include "qqml.h"

class Pager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int page READ getPage WRITE setPage NOTIFY pageChanged)
    Q_PROPERTY(int pages READ getPages WRITE setPages NOTIFY pagesChanged)
    Q_PROPERTY(int lastpage READ getLastPage NOTIFY pagesChanged)
    Q_PROPERTY(bool isPageFirst READ isPageFirst NOTIFY pageChanged)
    Q_PROPERTY(bool isPageLast READ isPageLast NOTIFY pageChanged)
    QML_ELEMENT

    int page = 0;
    int pages{};

public:
    explicit Pager(QObject *parent = nullptr);

    void setPage(int num);
    void setPages(int num);

    int getPage() const;
    int getPages() const;
    int getLastPage() const;

    bool isPageFirst() const;
    bool isPageLast() const;

    static int qmlRegisterType(const char *uri, int versionMajor, int versionMinor);

signals:
    void pageChanged();
    void pagesChanged();

private slots:
    void updatePage();

public slots:
    void toFirstPage();
    void toLastPage();
};
