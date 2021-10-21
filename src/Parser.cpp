#include "Parser.hpp"

#include <QTextStream>

Parser::Parser(QObject *parent) : QObject(parent)
{
    setHandler("file", [&](const QUrl &qurl){
        QDir dir{qurl.toString().replace("file://", "")};
        QString path = qurl.toString();
        QStringList links{};
        links = dir.entryList().mid(2);
        for (int i = 0, s = links.size(); i < s; i++)
            links[i] = "file://" + dir.absoluteFilePath(links[i]);
        auto stop1 = high_resolution_clock::now();
        if (links.size() > 0)
        {
            emit partiallyReady(path, links);
            emit completelyReady(path);
        }
        else emit errorOccured(path);
    });
    setHandler("readcomicsonline.ru/comic", [&](const QUrl &qurl){
        downloader.GET({
            qurl,
            [&, qurl](QNetworkReply *reply) -> QNetworkRequest
            {
                QString doc = reply->readAll();
                doc.replace(QRegularExpression(".*<ul class=\"chapters\"(.*?)<div class=\"row\">.*", QRegularExpression::DotMatchesEverythingOption), "\\1");

                QRegularExpression re_link("href=\\\"(.*?)\\\"", QRegularExpression::DotMatchesEverythingOption);
                QRegularExpression re_date("date-chapter-title-rtl.*?(..) (...)\\. (....)", QRegularExpression::DotMatchesEverythingOption);
                QRegularExpressionMatchIterator it_link = re_link.globalMatch(doc);
                QRegularExpressionMatchIterator it_date = re_date.globalMatch(doc);

                QMap<qint64, QString> chapter_links;
                while (it_link.hasNext())
                {
                    QString chapter_link = it_link.next().captured(1);
                    QString date_str = it_date.next().capturedTexts().sliced(1).join(" ");
                    auto date = QDate::fromString(date_str, Qt::RFC2822Date).startOfDay().toMSecsSinceEpoch();
                    chapter_links.insert(date, chapter_link);
                }
                QString last_url;
                if (chapter_links.size()) last_url = chapter_links.last();
                downloader.GET({
                    chapter_links.values(),
                    [&, qurl, last_url](QNetworkReply *reply) -> QNetworkRequest
                    {
                        QString doc = reply->readAll();
                        doc.replace(QRegularExpression(".*(<div id=.all.*?</div>).*", QRegularExpression::DotMatchesEverythingOption), "\\1");
                        QRegularExpression re_link("data-src=' (.*?) '", QRegularExpression::DotMatchesEverythingOption);
                        QRegularExpressionMatchIterator it_link = re_link.globalMatch(doc);

                        QStringList links{};
                        while(it_link.hasNext())
                        {
                            links << it_link.next().captured(1);
                        }
                        emit partiallyReady(qurl.toString(), links);
                        if (reply->url() == last_url) emit completelyReady(qurl.toString());
                        return reply->request();
                    }
                });
                return reply->request();
            }
        });
    });
}

UrlHandler::UrlHandler &Parser::getHandler(const QUrl &qurl)
{
    QString scheme = qurl.scheme();
    if (scheme == "file") return handlers["file"];
    QString handlerKey;
    QStringList handlersKeys = handlers.keys();
    for (int i = 0; i < handlersKeys.size(); i++)
    {
        QRegularExpression re(handlersKeys.at(i));
        if(re.match(qurl.url()).hasMatch()) handlerKey = handlersKeys.at(i); // hostname used before
    }
    return handlers[handlerKey];
}

void Parser::requestLinks(const QString &url)
{
    QUrl qurl = QUrl(url);
    qInfo() << "Links for '" << url << "' have been requested!" << "\n";
    UrlHandler::UrlHandler &handler = getHandler(qurl);
    if (!handler) {
        qDebug() << "NO HANDLER FOR THIS HOST.\nHost: " << qurl.host() << ";\nUrl: " << qurl.toString();
        return;
    }
    handler(qurl);
}

void Parser::setHandler(QString handlerName, UrlHandler::UrlHandler handlerFunc)
{
    if(!handlers.contains(handlerName))
        handlers.insert(handlerName, handlerFunc);
}
