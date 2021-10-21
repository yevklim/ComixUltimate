#pragma once
#include <QtCore>
#include <QtNetwork>
#include <QJSValue>
#include <functional>

namespace ComixUltimate
{
    typedef qint8 qrate_t;
    typedef qint64 qhash_t;
    typedef qint64 qtime_t;
    typedef QJSValue JSFunction;
    enum ItemType
    {
        UndefinedType,
        ComicBook,
        ArtBook,
        Video,
        VideoCollection
    };

    namespace UrlHandler  {
        using RequestHeadersSetter = std::function<void(QNetworkRequest *request)>;
        using Callback = std::function<void(QStringList &links)>;
        using OnFinished = std::function<QNetworkRequest(QNetworkReply *reply)>;
        using OnError = std::function<void(/*QNetworkReply *reply*/)>;
        using AfterFinished = std::function<void(/*QNetworkReply *reply*/)>;
        using UrlHandler = std::function<void(const QUrl &qurl/*, const Callback &callback, const OnError &onerror, const AfterFinished &afterfinished*/)>;
    }
    using VoidFunction = std::function<void()>;
}
