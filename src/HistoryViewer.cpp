#include "HistoryViewer.hpp"

HistoryViewer::HistoryViewer(DataBase *db) : DataBaseViewer(db)
{
    auto f1 = [this]()
    {
        m_filter_params.m_lastview = 1;
        m_filter_params.m_changed[FilterParams::LastView] = true;
    };
    auto f2 = [this]()
    {
        m_sorter_params.m_param = "lastview";
        m_sorter_params.m_changed[SorterParams::Param] = true;
    };
    connect(&m_filter_params, &FilterParams::lastviewChanged, this, f1);
    connect(&m_sorter_params, &SorterParams::paramChanged, this, f2);
    f1();
    f2();
}
