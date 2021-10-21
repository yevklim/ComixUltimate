#include "DataBase.hpp"

QString DataBase::filepath() const
{
    return savefile;
}

QVector<DBItem *> DataBase::get_items()
{
    return m_items;
}
QVector<DBItem *> DataBase::get_items(const FilterParams &filter_params, const SorterParams &sorter_params)
{
    QVector<DBItem *> items;
    if (!filter_params.check_any())
    {
        items = m_items;
    }
    else
    {
        items = get_filtered(filter_params);
    }
    if (sorter_params.check_any())
    {
        items = get_sorted(sorter_params, items);
    }
    return items;
}
QVector<DBItem *> DataBase::get_items(const SorterParams &sorter_params, const FilterParams &filter_params)
{
    return get_items(filter_params, sorter_params);
}

QVector<DBItem *> DataBase::get_filtered(const FilterParams &filter_params)
{
    return get_filtered(filter_params, m_items);
}
QVector<DBItem *> DataBase::get_filtered(const FilterParams &filter_params, QVector<DBItem *> items)
{
//    items.erase(
//        std::remove_if(items.begin(), items.end(), [&filter_params](DBItem *item) {
//            return !item->pass_filters(filter_params);
//        }),
//        items.end());
    for (int i = 0, e = items.size(); i < e; )
    {
        DBItem *item = items[i];
        if (!item->pass_filters(filter_params))
        {
            items.removeOne(item);
            e--;
        }
        else
        {
            i++;
        }
    }
    return items;
}
QVector<DBItem *> DataBase::get_sorted(const SorterParams &sorter_params)
{
    return get_sorted(sorter_params, m_items);
}
QVector<DBItem *> DataBase::get_sorted(const SorterParams &sorter_params, QVector<DBItem *> items)
{
    if (sorter_params.m_alphabet)
    {
        // ordering_comp returns `comparison > 0` if sort is reversed else `comparison < 0`
        auto cmp{sorter_params.m_reversed ? ComixUltimate::cmp_greater<int> : ComixUltimate::cmp_less<int>};
        std::stable_sort(items.begin(), items.end(), [&sorter_params, &cmp](DBItem *item1, DBItem *item2) mutable {
            return cmp(item1->compare(item2, sorter_params.m_param));
        });
    }
    // `else` is used because if sort is alphabet and reversed, we have already reversed it
    else if (sorter_params.m_reversed)
    {
        std::reverse(items.begin(), items.end());
    }
    return items;
}

DBItem *DataBase::get_item(qhash_t hash) const
{
//    return *std::find_if(m_items.begin(), m_items.end(), [hash](DBItem *item) {
//        return item->get_hash() == hash;
//    });
    foreach(DBItem *item, m_items)
    {
        if (item->m_hash == hash)
        {
            return item;
        }
    }
    return nullptr;
}
DBItem *DataBase::get_item(QString source, bool exact_match) const
{
//    return *std::find_if(m_items.begin(), m_items.end(), [source](DBItem *item) {
//        return item->get_source() == source;
//    });
    foreach(DBItem *item, m_items)
    {
        if (exact_match ? item->m_source == source : item->m_source.contains(source))
        {
            return item;
        }
    }
    return nullptr;
}
DBItem *DataBase::operator[](qhash_t hash) const
{
    return get_item(hash);
}
DBItem *DataBase::operator[](QString source) const
{
    return get_item(source);
}

bool DataBase::contain_item(DBItem *item) const
{
//    return std::find(m_items.begin(), m_items.end(), item) != m_items.end();
    for (const DBItem *m_item : m_items)
    {
        if (m_item->get_source() == item->get_source()) {
            return true;
        }
    }
    return false;
}
bool DataBase::contain_items(QVector<DBItem *> items) const
{
    for (DBItem *item : items)
    {
        if (!contain_item(item))
            return false;
    }
    return true;
}

void DataBase::push_item(DBItem *item)
{
    DBItem *new_item = (item->parent() == this) ? item : new DBItem{this, item};
    if (!contain_item(new_item))
    {
        m_items.push_back(new_item);
        connect(new_item, &DBItem::objectChanged, this, &DataBase::itemsChanged);
    }
    emit itemAdded();
    emit itemsChanged();
    emit sizeChanged();
    emit objectChanged();
}
void DataBase::push_items(QVector<DBItem *> items)
{
    bool changed = false;
    for (DBItem *item : items)
    {
        DBItem *new_item = (item->parent() == this) ? item : new DBItem{this, item};
        if (!contain_item(new_item))
        {
            m_items.push_back(new_item);
            connect(new_item, &DBItem::objectChanged, this, &DataBase::itemsChanged);
            changed = true;
        }
    }
    if (changed)
    {
        emit itemAdded();
        emit itemsChanged();
        emit sizeChanged();
        emit objectChanged();
    }
}

void DataBase::remove_item(DBItem *item)
{
    m_items.removeOne(item);
    disconnect(item, &DBItem::objectChanged, this, &DataBase::itemsChanged);
    item->deleteLater();
    emit itemRemoved();
    emit itemsChanged();
    emit sizeChanged();
    emit objectChanged();
}
void DataBase::remove_items(QVector<DBItem *> items)
{
    bool changed = false;
    for (DBItem *item : items)
    {
        if (m_items.removeOne(item))
        {
            changed = true;
            disconnect(item, &DBItem::objectChanged, this, &DataBase::itemsChanged);
            item->deleteLater();
        }
    }
    if (changed)
    {
        //TODO: REMOVE ALL UNNECESSARY emits across this file
        emit itemRemoved();
        emit itemsChanged();
        emit sizeChanged();
        emit objectChanged();
    }
}
void DataBase::remove_item(qhash_t hash)
{
    remove_item(get_item(hash));
}
void DataBase::remove_item(QString source)
{
    remove_item(get_item(source));
}


QStringList DataBase::get_tags() const
{
    return m_tags;
}
void DataBase::set_tags(QStringList tags)
{
    m_tags = tags;
    emit tagsChanged();
    emit objectChanged();
}
bool DataBase::has_tag(QString tag) const
{
//    return std::find(m_tags.begin(), m_tags.end(), tag) != m_tags.end();
    if (tag.size() > 0)
    {
        return m_tags.contains(tag, Qt::CaseInsensitive);
    }
    return true;
}
bool DataBase::has_tags(QStringList tags) const
{
    for (const QString &tag : tags)
    {
        if (!has_tag(tag))
        {
            return false;
        }
    }
    return true;
}
void DataBase::push_tag(QString tag)
{
    if (!has_tag(tag))
    {
        m_tags.push_back(tag);
        m_tags.sort();
        emit tagsChanged();
        emit objectChanged();
    }
}
void DataBase::push_tags(QStringList tags)
{
    bool to_sort = false;
    for (const QString &tag : tags)
    {
        if (!has_tag(tag))
        {
            to_sort = true;
            m_tags.push_back(tag);
        }
    }
    if (to_sort)
    {
        m_tags.sort();
        emit tagsChanged();
        emit objectChanged();
    }
}
void DataBase::pop_tag(QString tag)
{
//    m_tags.erase(std::remove(m_tags.begin(), m_tags.end(), tag), m_tags.end());
    m_tags.removeOne(tag);
}
void DataBase::pop_tags(QStringList tags)
{
    for (const QString &tag : tags)
    {
        m_tags.removeOne(tag);
    }
}


size_t DataBase::size() const
{
    return m_items.size();
}
QVector<DBItem *>::iterator DataBase::begin()
{
    return m_items.begin();
}
QVector<DBItem *>::iterator DataBase::end()
{
    return m_items.end();
}

void DataBase::read(const QJsonObject &json)
{
    if (json.contains("tags") && json["tags"].isArray())
    {
        QJsonArray qtags = json["tags"].toArray();
        m_tags.clear();
        for (int i = 0, size = qtags.size(); i < size; i++)
        {
            QString tag = qtags.at(i).toString();
            if (tag.size() > 0)
            {
                m_tags.push_back(tag);
            }
        }
    }

    if (json.contains("items") && json["items"].isArray())
    {
        QJsonArray qitems = json["items"].toArray();
        m_items.clear();
        for (int i = 0, size = qitems.size(); i < size; i++)
        {
            QJsonObject qitem = qitems.at(i).toObject();
//            DBItem item{this, qitem};
//            m_items.push_back(&item);
            DBItem *item = new DBItem{this, qitem};
            push_tags(item->get_tags()); // in case if DBItem has unregistered tags
            connect(item, &DBItem::objectChanged, this, &DataBase::itemsChanged);
            m_items.push_back(item);
        }
    }
//    writeArray(json_items, true);
//    json_all_items = json_items;
    emit itemsChanged();
    emit sizeChanged();
    emit objectChanged();
}

void DataBase::write(QJsonObject &json) const
{
    QJsonArray qtags;
    foreach(const QString &tag, m_tags)
    {
        if (tag.size() > 0)
        {
            qtags.append(tag);
        }
    }
    json["tags"] = qtags;

    QJsonArray qitems;
    for (DBItem *item : m_items)
    {
        QJsonObject qitem;
        item->write(qitem);
        qitems.append(qitem);
    }
    json["items"] = qitems;
}

void DataBase::requestItems()
{
    emit sendItems(get_items());
}

DBItem *DataBase::get_new_item()
{
    if (new_item == nullptr)
    {
        new_item = new DBItem{this};
    }
    return new_item;
}
void DataBase::add_new_item()
{
    if (new_item != nullptr)
    {
        new_item->generate_hash();
        connect(new_item, &DBItem::objectChanged, this, &DataBase::itemsChanged);
        push_item(new_item);
        new_item = nullptr;
    }
}
