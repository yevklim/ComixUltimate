#include "Downloader.hpp"

Downloader::Downloader(QObject *parent, int downloads_limit, bool first_new_then_old, QNetworkAccessManager *manager) : QObject(parent)
{
    set_downloads_limit(downloads_limit);
    m_first_new_then_old = first_new_then_old;
    if (manager != nullptr)
    {
        m_manager->deleteLater();
        m_manager = manager;
    }
}

void Downloader::GET(const DownloadSequence &downloads)
{
    bool check = m_downloadQueue.isEmpty();
    for (const QString &urlAsString : downloads.urls)
    {
        m_downloadQueue.enqueue(
            {QUrl::fromEncoded(urlAsString.toLocal8Bit()),
             downloads.onfinished,
             downloads.requestHeadersSetter});
    }

    if (check || m_first_new_then_old)
    {
        startNextDownload();
    }
//    if (downloadQueue.isEmpty())
//    {
//        emit finished();
    //    }
}

int Downloader::get_downloads_limit()
{
    return m_downloads_limit;
}

QByteArray Downloader::get_user_agent()
{
    return m_userAgent;
}

QNetworkAccessManager *Downloader::get_manager()
{
    return m_manager;
}
void Downloader::set_downloads_limit(int downloads_limit)
{
    if (downloads_limit > max_downloads_limit)
    {
        m_downloads_limit = max_downloads_limit;
    }
    else
    if (downloads_limit < 1)
    {
        m_downloads_limit = 1;
    }
    else
    {
        m_downloads_limit = downloads_limit;
    }
}

void Downloader::GET(const Download &download)
{
    bool check = m_downloadQueue.isEmpty();
    m_downloadQueue.enqueue(download);
    if (check || m_first_new_then_old)
    {
        startNextDownload();
    }
}

void Downloader::startNextDownload()
{
    if (m_downloadQueue.isEmpty()) {
        emit finished();
        return;
    }
    if (m_currentDownloads.length() < m_downloads_limit || m_first_new_then_old)
    {
        sendRequest("GET", m_downloadQueue.dequeue());
//        QNetworkRequest request(download.url);
//        request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
//        download.requestHeadersSetter(&request);
//        QNetworkReply *currentDownload = m_manager->get(request);
//        if (m_currentDownloads.length() >= m_downloads_limit && m_first_new_then_old)
//        {
//            m_currentDownloads.takeFirst()->abort();
//        }
//        m_currentDownloads.append(currentDownload);
//        connect(currentDownload, &QNetworkReply::finished,
//                this, [this, download, currentDownload]() mutable
//        {
//            QNetworkRequest new_request;
//            QNetworkReply::NetworkError err = currentDownload->error();
//            if (err != QNetworkReply::OperationCanceledError)
//            {
//                new_request = download.onfinished(currentDownload);
//            }
//            else
//            {
//                m_downloadQueue.enqueue(download);
//                new_request = currentDownload->request();
//            }
//            if (currentDownload != nullptr)
//            {
//                if (currentDownload->request().url() != new_request.url())
//                {
//                    download.url = new_request.url();
//                    m_downloadQueue.prepend(download);
//                }
//                m_currentDownloads.removeOne(currentDownload);
//                currentDownload->deleteLater();
//            }
//            if (m_currentDownloads.length() < m_downloads_limit)
//            {
//                startNextDownload();
//            }
//        });
    }
    if (m_currentDownloads.length() < m_downloads_limit)
    {
        startNextDownload();
    }
}

void Downloader::sendRequest(const QByteArray &METHOD, Download download)
{
    QNetworkRequest request(download.url);
    request.setRawHeader("user-agent", m_userAgent);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    download.requestHeadersSetter(&request);
    QNetworkReply *currentDownload = m_manager->sendCustomRequest(request, METHOD);
    if (METHOD == "GET" && m_currentDownloads.length() >= m_downloads_limit && m_first_new_then_old)
    {
        m_currentDownloads.takeFirst()->abort();
    }
    if (METHOD == "GET") m_currentDownloads.append(currentDownload);

    connect(currentDownload, &QNetworkReply::finished,
            this, [this, download, currentDownload, METHOD]() mutable
    {
        QNetworkRequest new_request;
        bool to_send_new_request = false;
        QNetworkReply::NetworkError err = currentDownload->error();
        if (err != QNetworkReply::OperationCanceledError && err != QNetworkReply::HostNotFoundError)
        {
            new_request = download.onfinished(currentDownload);
        }
        else if (METHOD == "GET" && m_currentDownloads.contains(currentDownload))
        {
            m_downloadQueue.enqueue(download);
            new_request = currentDownload->request();
        }
        if (currentDownload != nullptr)
        {
            if (currentDownload->request().url() != new_request.url() && err != QNetworkReply::HostNotFoundError)
            {
                download.url = new_request.url();
                to_send_new_request = true;
            }
            if (METHOD == "GET") m_currentDownloads.removeOne(currentDownload);
            currentDownload->deleteLater();
        }
        if (to_send_new_request)
        {
            if (METHOD == "GET") m_downloadQueue.prepend(download);
            else
            if (METHOD == "HEAD") sendRequest(METHOD, download);
        }

        if (METHOD == "GET" && m_currentDownloads.length() < m_downloads_limit)
        {
            startNextDownload();
        }
    });
}

void Downloader::HEAD(const Download &download)
{
    sendRequest("HEAD", download);
}

void Downloader::abortDownloads()
{
    foreach(QNetworkReply *reply, m_currentDownloads)
    {
        reply->abort();
    }
}

void Downloader::reset()
{
    m_downloadQueue.clear();
    abortDownloads();
    m_currentDownloads.clear();
}
