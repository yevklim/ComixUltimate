#include "FilterParams.hpp"

ItemType FilterParams::get_type() const
{
    return m_type;
}
QString FilterParams::get_source() const
{
    return m_source;
}
QString FilterParams::get_title() const
{
    return m_title;
}
qtime_t FilterParams::get_added() const
{
    return m_added;
}
qtime_t FilterParams::get_lastview() const
{
    return m_lastview;
}
qrate_t FilterParams::get_rate() const
{
    return m_rate;
}
QStringList FilterParams::get_tags() const
{
    return m_tags;
}

void FilterParams::set_type(ItemType type)
{
    if (!m_changed[Type])
        m_changed[Type] = m_type != type;
    m_type = type;
    emit typeChanged();
    emit objectChanged();
}
void FilterParams::set_source(QString source)
{
    if (!m_changed[Source])
        m_changed[Source] = m_source != source;
    m_source = source;
    emit sourceChanged();
    emit objectChanged();
}
void FilterParams::set_title(QString title)
{
    if (!m_changed[Title])
        m_changed[Title] = m_title != title;
    m_title = title;
    emit titleChanged();
    emit objectChanged();
}
void FilterParams::set_added(qtime_t added)
{
    if (!m_changed[Added])
        m_changed[Added] = m_added != added;
    m_added = added;
    emit addedChanged();
    emit objectChanged();
}
void FilterParams::set_lastview(qtime_t lastview)
{
    if (!m_changed[LastView])
        m_changed[LastView] = m_lastview != lastview;
    m_lastview = lastview;
    emit lastviewChanged();
    emit objectChanged();
}
void FilterParams::set_rate(qrate_t rate)
{
    if (!m_changed[Rate])
        m_changed[Rate] = m_rate != rate;
    m_rate = rate;
    emit rateChanged();
    emit objectChanged();
}
void FilterParams::set_tags(QStringList tags)
{
    if (!m_changed[Tags])
        m_changed[Tags] = m_tags != tags;
    m_tags = tags;
    emit tagsChanged();
    emit objectChanged();
}

bool FilterParams::check_type() const
{
    return m_changed[Type];
}
bool FilterParams::check_source() const
{
    return m_changed[Source];
}
bool FilterParams::check_title() const
{
    return m_changed[Title];
}
bool FilterParams::check_added() const
{
    return m_changed[Added];
}
bool FilterParams::check_lastview() const
{
    return m_changed[LastView];
}
bool FilterParams::check_rate() const
{
    return m_changed[Rate];
}
bool FilterParams::check_tags() const
{
    return m_changed[Tags];
}

bool FilterParams::check_all() const
{
    return std::all_of(m_changed.begin(), m_changed.end(), [](bool b) { return b; });
}

bool FilterParams::check_any() const
{
    return std::any_of(m_changed.begin(), m_changed.end(), [](bool b) { return b; });
}

bool FilterParams::has_tag(QString tag) const
{
    if (tag.size() > 0)
    {
        return m_tags.contains(tag, Qt::CaseInsensitive);
    }
    return true;
}
bool FilterParams::has_tags(QStringList tags) const
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

void FilterParams::push_tag(QString tag)
{
    if (!has_tag(tag))
    {
        m_tags.push_back(tag);
        std::stable_sort(m_tags.begin(), m_tags.end());
        emit tagsChanged();
        emit objectChanged();
    }
}
void FilterParams::push_tags(QStringList tags)
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
        std::stable_sort(m_tags.begin(), m_tags.end());
        emit tagsChanged();
        emit objectChanged();
    }
}

void FilterParams::pop_tag(QString tag)
{
    m_tags.removeOne(tag);
    emit tagsChanged();
    emit objectChanged();
}
void FilterParams::pop_tags(QStringList tags)
{
    for (const QString &tag : tags)
    {
        m_tags.removeOne(tag);
    }
    emit tagsChanged();
    emit objectChanged();
}

void FilterParams::merge(const FilterParams &other)
{
    bool changed = false;
    if (other.m_changed[Type])
    {
        m_changed[Type] = true;
        m_type = other.m_type;
        changed = true;
    }
    if (other.m_changed[Source])
    {
        m_changed[Source] = true;
        m_source = other.m_source;
        changed = true;
    }
    if (other.m_changed[Title])
    {
        m_changed[Title] = true;
        m_title = other.m_title;
        changed = true;
    }
    if (other.m_changed[Added])
    {
        m_changed[Added] = true;
        m_added = other.m_added;
        changed = true;
    }
    if (other.m_changed[LastView])
    {
        m_changed[LastView] = true;
        m_lastview = other.m_lastview;
        changed = true;
    }
    if (other.m_changed[Rate])
    {
        m_changed[Rate] = true;
        m_rate = other.m_rate;
        changed = true;
    }
    if (other.m_changed[Tags])
    {
        m_changed[Tags] = true;
        m_tags = other.m_tags;
        changed = true;
    }

    if (changed)
    {
        emit objectChanged();
    }
}
FilterParams FilterParams::merge_copy(const FilterParams &other)
{
    return FilterParams {
        parent(),
        other.m_changed[Type] ? other.m_type : m_type,
        other.m_changed[Source] ? other.m_source : m_source,
        other.m_changed[Title] ? other.m_title : m_title,
        other.m_changed[Added] ? other.m_added : m_added,
        other.m_changed[LastView] ? other.m_lastview : m_lastview,
        other.m_changed[Rate] ? other.m_rate : m_rate,
        other.m_changed[Tags] ? other.m_tags : m_tags};
}

void FilterParams::read(const QJsonObject &json, bool firstRead)
{
    if (json.contains("source") && json["source"].isString())
    {
//        m_source = json["source"].toString();
        set_source(json["source"].toString());
    }

    if (json.contains("title") && json["title"].isString())
    {
//        m_title = json["title"].toString();
        set_title(json["title"].toString());
    }

    if (json.contains("added") && json["added"].isDouble())
    {
//        m_added = json["added"].toDouble();
        set_added(json["added"].toDouble());
    }

    if (json.contains("lastview") && json["lastview"].isDouble())
    {
//        m_lastview = json["lastview"].toDouble();
        set_lastview(json["lastview"].toDouble());
    }

    if (json.contains("rate") && json["rate"].isDouble())
    {
//        m_rate = json["rate"].toInt();
        set_rate(json["rate"].toInt());
    }

    if (json.contains("tags") && json["tags"].isArray())
    {
        QJsonArray tags = json["tags"].toArray();
        QStringList _tags = {};
        _tags.clear();
        for (const QJsonValue &tag : tags)
        {
            if (tag.isString())
                _tags.push_back(tag.toString());
        }
        set_tags(_tags);
    }
}

void FilterParams::write(QJsonObject &json) const
{
    if (m_changed[Source])
        json["source"] = m_source;
    if (m_changed[Title])
        json["title"] = m_title;
    if (m_changed[Added])
        json["added"] = m_added;
    if (m_changed[LastView])
        json["lastview"] = m_lastview;
    if (m_changed[Rate])
        json["rate"] = m_rate;
    if (m_changed[Tags])
    {
        QJsonArray tags;
        for (const QString &tag : m_tags)
        {
            tags.append(tag);
        }
        json["tags"] = tags;
    }
}

int FilterParams::qmlRegisterType(const char *uri, int versionMajor, int versionMinor)
{
    return ::qmlRegisterType<FilterParams>(uri, versionMajor, versionMinor, "FilterParams");
}

int FilterParams::qRegisterMetaType()
{
    return ::qRegisterMetaType<FilterParams*>("FilterParams*");
}
