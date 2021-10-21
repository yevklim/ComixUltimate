#include "Provider.hpp"

MasterProvider::MasterProvider(QObject *parent, DataBase *database) : QObject(parent), m_database{database}
{
    m_items_manager = new ProvidedItemsManager{this, m_database, m_downloader, cache_path};
    QObject::connect(m_parser, &Parser::completelyReady,
                     this, [&, this]
                     (const QString &url)
                     mutable {
        ProvidedItem *item = m_items_manager->get_item(ComixUltimate::get_simplified_url(url), false);
        if (!url.contains("file://"))
        {
            m_items_manager->update_cached_links(item);
            item->new_links.clear();
        }
        emit completelyReady(url, item->links.length());
    });
    QObject::connect(m_parser, &Parser::partiallyReady,
                     this, [&, this]
                     (const QString &url, const QStringList &links)
                     mutable {
        ProvidedItem *item = m_items_manager->get_item(ComixUltimate::get_simplified_url(url), false);
        if (url.contains("file://"))
        {
            item->links = links;
            return;
        }
        bool to_emit = false;
//        if (item->links.isEmpty() || item->links.size() == item->new_links.size())
//        {
//            item->links.append(links);
//            to_emit = true;
//        }
        item->new_links.append(links);

        int diff = item->links.size() - item->new_links.size();

        to_emit = m_items_manager->update_cached_links(item) && (diff > 0);

        int diff2 = (item->links.size() - item->new_links.size()) - diff;

        if (diff < 0)
        {
//            item->links.append(item->new_links.sliced(item->links.size()));
            emit partiallyReady(url, diff2);
        }
        else
        if (to_emit)
        {
            emit partiallyReady(url, diff2, false, true);
        }

    });
    QNetworkDiskCache *disk_cache = new QNetworkDiskCache(m_manager);
    disk_cache->setCacheDirectory(cache_path.absolutePath());
    disk_cache->setMaximumCacheSize(524288000);
    m_manager->setCache(disk_cache);
}

MasterProvider::~MasterProvider()
{
    //
}

void MasterProvider::requestLinks(const QString &url)
{
//    if (url == m_last_requested_url)
//    {
//        return;
//    }
    m_last_requested_url = url;
    abortDownloads();
    ProvidedItem *item = m_items_manager->get_item(url);
    if (item->links.length() > 0)
    {
        emit completelyReady(url, item->links.length());
    }
    if (item->new_links.length() == 0)
    {
        m_parser->requestLinks(url);
    }
}

void MasterProvider::abortDownloads()
{
    m_downloader->reset();
    ProvidedItemsList &items = m_items_manager->get_items();
    foreach (ProvidedItem *item, items)
    {
        item->new_links.clear();
    }
}

QString MasterProvider::get_real_link(qhash_t hash, int index)
{
//    auto link = m_items_manager->get_item(hash)->links[index];
    ProvidedItem *item = m_items_manager->get_item(hash);
    if (item != nullptr && index != -1) {
        if (index < item->links.size()) return item->links.at(index);
        else return "";
    }
    return "";
}

QStringList MasterProvider::get_real_links(qhash_t hash, int from, int to)
{
    ProvidedItem *item = m_items_manager->get_item(hash);
    if (item != nullptr) {
        if (to > item->links.size())
        {
            to = item->links.size();
        }
        if (from >= 0 && to > from)
        {
            return item->links.sliced(from, to - from);
        }
        else return {};
    }
    return {};
}

void MasterProvider::fix_real_link(qhash_t hash, int index)
{
    //
}

QString MasterProvider::get_user_agent()
{
    return m_downloader->get_user_agent();
}

