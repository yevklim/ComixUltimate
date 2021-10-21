#include "DBItem.hpp"

qhash_t DBItem::get_hash() const
{
    return m_hash;
}
qhash_t DBItem::generate_hash()
{
    m_hash = static_cast<quint32>(std::hash<std::wstring>{}(m_source.toStdWString()));
    emit hashChanged();
    return m_hash;
}

int DBItem::get_type() const
{
    return static_cast<int>(m_type);
}
QString DBItem::get_source() const
{
    return m_source;
}
QString DBItem::get_title() const
{
    return m_title;
}
QString DBItem::get_cover() const
{
    return m_cover;
}
qtime_t DBItem::get_added() const
{
    return m_added;
}
qtime_t DBItem::get_lastview() const
{
    return m_lastview;
}
qrate_t DBItem::get_rate() const
{
    return m_rate;
}
QStringList DBItem::get_tags() const
{
    return m_tags;
}

void DBItem::set_type(int type)
{
    m_type = static_cast<ItemType>(type);
    emit typeChanged();
    emit objectChanged();
}
void DBItem::set_source(QString source)
{
    // TODO URL checking
    m_source = QUrl(source).toString();
    if (m_source.endsWith("/"))
    {
        m_source.resize(m_source.size() - 1);
    }
    emit sourceChanged();
    emit objectChanged();
}
void DBItem::set_title(QString title)
{
    m_title = title;
    emit titleChanged();
    emit objectChanged();
}
void DBItem::set_cover(QString cover)
{
    // TODO URL checking
    m_cover = cover;
    emit coverChanged();
    emit objectChanged();
}
void DBItem::set_added(qtime_t added)
{
    m_added = added;
    emit addedChanged();
    emit objectChanged();
}
void DBItem::set_lastview(qtime_t lastview)
{
    m_lastview = lastview;
    emit lastviewChanged();
    emit objectChanged();
}
void DBItem::set_rate(qrate_t rate)
{
    m_rate = rate;
    emit rateChanged();
    emit objectChanged();
}
void DBItem::set_tags(QStringList tags)
{
    m_tags = tags;
    emit tagsChanged();
    emit objectChanged();
}

void DBItem::update_lastview()
{
    m_lastview = QDateTime::currentMSecsSinceEpoch();
    emit lastviewChanged();
    emit objectChanged();
}

bool DBItem::has_tag(QString tag) const
{
    if (tag.size() > 0)
    {
        return m_tags.contains(tag, Qt::CaseInsensitive);
    }
    return true;
}
bool DBItem::has_tags(QStringList tags) const
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

void DBItem::push_tag(QString tag)
{
    if (!has_tag(tag))
    {
        m_tags.push_back(tag);
        m_tags.sort();
        emit tagsChanged();
        emit objectChanged();
    }
}
void DBItem::push_tags(QStringList tags)
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

void DBItem::pop_tag(QString tag)
{
    m_tags.removeOne(tag);
    emit tagsChanged();
    emit objectChanged();
}
void DBItem::pop_tags(QStringList tags)
{
    for (const QString &tag : tags)
    {
        m_tags.removeOne(tag);
    }
    emit tagsChanged();
    emit objectChanged();
}

bool DBItem::pass_filters(const FilterParams &filter_params) const
{
    bool pass = true;
    if (filter_params.m_type != ComixUltimate::UndefinedType && m_type != filter_params.m_type)
    {
        return false;
    }
    if (!m_source.contains(filter_params.m_source, Qt::CaseInsensitive))
    {
        return false;
    }
    if (!m_title.contains(filter_params.m_title, Qt::CaseInsensitive))
    {
        return false;
    }
    if (m_added < filter_params.m_added)
    {
        return false;
    }
    if (m_lastview < filter_params.m_lastview)
    {
        return false;
    }
    if (m_rate < filter_params.m_rate)
    {
        return false;
    }

    if (filter_params.check_tags())
    {
//        QString tags = m_tags.join(";");  // for soft checking
        foreach(QString tag, filter_params.m_tags) {
//            if (!tags.contains(tag)) pass = false; // soft checking
            if (!m_tags.contains(tag)) pass = false; // hard checking
//            if (!m_tags.contains(QRegularExpression(tag))) pass = false; // soft checking 2
        }
    }

    return pass;
}
int DBItem::compare(DBItem *other, QString param) const
{
    if (param == "source")
    {
        return QString::compare(m_source, other->m_source, Qt::CaseInsensitive);
    }
    if (param == "title")
    {
        return QString::compare(m_title, other->m_title, Qt::CaseInsensitive);
    }
    if (param == "added")
    {
        return ComixUltimate::signum(m_added - other->m_added);
    }
    if (param == "lastview")
    {
        return ComixUltimate::signum(m_lastview - other->m_lastview);
    }
    if (param == "rate")
    {
        return ComixUltimate::signum(m_rate - other->m_rate);
    }
    return ComixUltimate::signum(m_hash - other->m_hash);
}

void DBItem::read(const QJsonObject &json, bool readHash)
{
    if (json.contains("type") && json["type"].isDouble())
    {
        int t = json["type"].toInt();
        m_type = static_cast<ItemType>(t);
    }

    if (json.contains("source") && json["source"].isString())
    {
        m_source = json["source"].toString();
        if (m_source.endsWith("/"))
        {
            m_source.resize(m_source.size() - 1);
        }
    }

    if (json.contains("title") && json["title"].isString())
        m_title = json["title"].toString();

    if (json.contains("cover") && json["cover"].isString())
        m_cover = json["cover"].toString();

    if (json.contains("added") && json["added"].isDouble())
        m_added = json["added"].toDouble();

    if (json.contains("lastview") && json["lastview"].isDouble())
        m_lastview = json["lastview"].toDouble();

//    if (m_added == m_lastview) m_lastview = 0;

    if (json.contains("rate") && json["rate"].isDouble())
        m_rate = json["rate"].toInt();

    if (json.contains("tags") && json["tags"].isArray())
    {
        QJsonArray tags = json["tags"].toArray();
        m_tags.clear();
        for (const QJsonValue &tag : tags)
        {
            if (tag.isString())
                m_tags.push_back(tag.toString());
        }
    }
    if (readHash && json.contains("hash") && json["hash"].isDouble()) m_hash = json["hash"].toVariant().toLongLong();
    else m_hash = generate_hash();
}

void DBItem::write(QJsonObject &json, bool writeHash) const
{
    if (writeHash) json["hash"] = QJsonValue::fromVariant(m_hash);
    json["type"] = static_cast<int>(m_type);
    json["source"] = m_source;
    json["title"] = m_title;
    json["cover"] = m_cover;
    json["added"] = m_added;
    json["lastview"] = m_lastview;
    json["rate"] = m_rate;
    QJsonArray tags;
    for (const QString &tag : m_tags)
    {
        tags.append(tag);
    }
    json["tags"] = tags;
}

int DBItem::qmlRegisterType(const char *uri, int versionMajor, int versionMinor)
{
    return ::qmlRegisterType<DBItem>(uri, versionMajor, versionMinor, "DBItem");
}

int DBItem::qRegisterMetaType()
{
    return ::qRegisterMetaType<DBItem*>("DBItem*");
}
