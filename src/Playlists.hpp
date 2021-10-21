#pragma once

#include <QObject>

//TODO: gotta implement static and dynamic playlists
//Dynamic: contain items autofiltered by some params (like tags or source) from database
//Static: contain items manually added by user
class Playlists : public QObject
{
    Q_OBJECT
public:
    explicit Playlists(QObject *parent = nullptr);

signals:

};
