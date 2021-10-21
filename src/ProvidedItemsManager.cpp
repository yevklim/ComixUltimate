#include "ProvidedItemsManager.hpp"

ProvidedItem *ProvidedItemsManager::get_item(const QString &source, bool exact_match)
{
    ProvidedItem *item_to_return{nullptr};
    foreach(ProvidedItem *provided_item, m_items)
    {
        if (exact_match ? provided_item->item->get_source() == source : provided_item->item->get_source().contains(source))
        {
            item_to_return = provided_item;
            break;
        }
    }
    if (item_to_return != nullptr)
    {
        return item_to_return;
    }
    else
    {
        DBItem *dbitem = m_database->get_item(source);
        if (dbitem != nullptr)
        {
            ProvidedItem *item = new ProvidedItem{
                dbitem
            };
            m_items.append(item);
            return item;
        }
        else
        {
            return nullptr;
        }
    }
}

ProvidedItem *ProvidedItemsManager::get_item(qhash_t hash)
{
    ProvidedItem *item_to_return{nullptr};
    foreach(ProvidedItem *provided_item, m_items)
    {
        if (provided_item->item->get_hash() == hash)
        {
            item_to_return = provided_item;
            break;
        }
    }
    if (item_to_return != nullptr)
    {
        return item_to_return;
    }
    else
    {
        ProvidedItem *item = new ProvidedItem{
            m_database->get_item(hash)
        };
        m_items.append(item);
        return item;
    }
}

bool ProvidedItemsManager::update_cached_links(ProvidedItem *item)
{
    if (item->links.size() == 0)
    {
        item->links = item->new_links;
        return true;
    }

//    QStringList merged{};
    QStringList links = get_simplified_urls(item->links);
    QStringList new_links = get_simplified_urls(item->new_links);

    bool updated = false;

    int diff = links.size() - new_links.size();
    if (diff > 0)
    {
        int indexOf = new_links.indexOf(links.first());
        if (links[0] != new_links[0] && indexOf != -1)
        {
//            merged << item->new_links.sliced(0, indexOf)
//                   << item->links;

//            item->links.prepend(item->new_links.sliced(0, indexOf));
            item->links = item->new_links.sliced(0, indexOf) + item->links;
            updated = true;
        }
    }
    else
    if (diff < 0)
    {
        int indexOfFirst = new_links.indexOf(links.first()),
            indexOfLast = new_links.indexOf(links.last());
//        if (links[0] == new_links[0])
//        {
//            merged << item->links
//                   << item->new_links.sliced(links.size());
//        }
//        else
//        if (links.last() == new_links.last())
//        {
//            merged << item->new_links.sliced(0, -diff)
//                   << item->links;
//        }
//        else
//        if (indexOfFirst != -1 && indexOfLast != -1)
//        {
//            merged << item->new_links.sliced(0, indexOfFirst)
//                   << item->links
//                   << item->new_links.sliced(indexOfLast + 1);
//        }

        item->links =
                item->new_links.sliced(0, indexOfFirst != -1 ? indexOfFirst : 0) +
                item->links;
        if (indexOfLast != -1)
        {
            item->links << item->new_links.sliced(indexOfLast + 1);
        }


        if (indexOfFirst == -1 && indexOfLast == -1)
        {
            item->links = item->new_links;
        }
        updated = true;
    }
    else
    {
        //
    }
    return updated;
}

DataBase *ProvidedItemsManager::get_database()
{
    return m_database;
}

ProvidedItemsList &ProvidedItemsManager::get_items()
{
    return m_items;
}

Downloader *ProvidedItemsManager::get_downloader()
{
    return m_downloader;
}

QString ProvidedItemsManager::filepath() const
{
    return m_cache_path.absoluteFilePath("items_cache");
}

void ProvidedItemsManager::read(const QJsonObject &json)
{
    QStringList sources = json.keys();
    foreach(const QString &source, sources)
    {
        ProvidedItem *item = get_item(source);
        if (item != nullptr)
        {
            item->links = json[source].toVariant().toStringList();
        }
    }
}

void ProvidedItemsManager::write(QJsonObject &json) const
{
    foreach(const ProvidedItem *providedItem, m_items)
    {
        const QString &source = providedItem->item->get_source();
        if (!source.contains("file://"))
        {
            json[source] = QJsonArray::fromStringList(providedItem->links);
        }
    }
}

QStringList ProvidedItemsManager::get_simplified_urls(const QStringList &urls)
{
    QStringList simplified_urls = urls;
    for (int i = 0; i < simplified_urls.size(); i++) {
        simplify_url(simplified_urls[i]);
    }
    return simplified_urls;
}

QString ProvidedItemsManager::get_simplified_url(const QString &url)
{
    QString simplified = url;
    simplify_url(simplified);
    return simplified;
}

void ProvidedItemsManager::simplify_url(QString &url)
{
    url.replace(QRegularExpression("(^.*://|www.|/^)|(jpg|jpeg|png|bmp|gif)"), "");
}
