#pragma once

#include <QObject>
#include "DataBaseViewer.hpp"

class HistoryViewer : public DataBaseViewer
{
public:
    explicit HistoryViewer(DataBase *db);

};
