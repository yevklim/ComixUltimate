#include "DataBaseViewer.hpp"

DataBaseViewer::DataBaseViewer(DataBase *db) : QObject(db)
{
    database = db;

    connect(database, &DataBase::itemsChanged, this, &DataBaseViewer::itemsChanged);

    connect(&m_filter_params, &FilterParams::objectChanged, this, &DataBaseViewer::paramsChanged);
    connect(&m_sorter_params, &SorterParams::objectChanged, this, &DataBaseViewer::paramsChanged);

    connect(this, &DataBaseViewer::paramsChanged, this, &DataBaseViewer::itemsChanged);
    connect(this, &DataBaseViewer::itemsChanged, this, &DataBaseViewer::requestItems);
}

DataBase *DataBaseViewer::get_database()
{
    return database;
}

QVector<DBItem *> DataBaseViewer::get_items()
{
    return database->get_items(m_filter_params, m_sorter_params);
}

void DataBaseViewer::reset_filters()
{
    //TODO;
}

void DataBaseViewer::reset_sorters()
{
    //TODO;
}

void DataBaseViewer::set_filter_params(const FilterParams &params)
{
    m_filter_params.merge(params);
    emit paramsChanged();
//    emit objectChanged();
}

void DataBaseViewer::set_sorter_params(const SorterParams &params)
{
    m_sorter_params.merge(params);
    emit paramsChanged();
    //    emit objectChanged();
}

FilterParams *DataBaseViewer::get_filter_params()
{
    return &m_filter_params;
}

SorterParams *DataBaseViewer::get_sorter_params()
{
    return &m_sorter_params;
}

void DataBaseViewer::requestItems()
{
    emit sendItems(get_items());
}
