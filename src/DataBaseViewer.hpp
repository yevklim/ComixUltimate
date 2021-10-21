#pragma once

#include <QObject>
#include "DataBase.hpp"

class DataBaseViewer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVector<DBItem *> items READ get_items NOTIFY itemsChanged)
    Q_PROPERTY(FilterParams* filter_params READ get_filter_params WRITE set_filter_params NOTIFY paramsChanged)
    Q_PROPERTY(SorterParams* sorter_params READ get_sorter_params WRITE set_sorter_params NOTIFY paramsChanged)
    QML_ELEMENT

protected:
    DataBase *database = nullptr;
    FilterParams m_filter_params{this};
    SorterParams m_sorter_params{this, "title", true, false};
public:
    explicit DataBaseViewer(DataBase *db);

    DataBase *get_database();

    QVector<DBItem *> get_items();

    void reset_filters();
    void reset_sorters();

    void set_filter_params(const FilterParams &params);
    void set_sorter_params(const SorterParams &params);

    FilterParams *get_filter_params();
    SorterParams *get_sorter_params();
public slots:
    void requestItems();
signals:
    void sendItems(QVector<DBItem *> items);

    void objectChanged();
    void itemsChanged();
    void paramsChanged();
};
