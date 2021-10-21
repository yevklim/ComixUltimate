#include "SorterParams.hpp"

QString SorterParams::get_param() const
{
    return m_param;
}
bool SorterParams::get_alphabet() const
{
    return m_alphabet;
}
bool SorterParams::get_reversed() const
{
    return m_reversed;
}

void SorterParams::set_param(QString param)
{
    if (m_param != param)
    {
        m_changed[Param] = true;
        m_param = param;
        emit paramChanged();
        emit objectChanged();
    }
}
void SorterParams::set_alphabet(bool alphabet)
{
    if (m_alphabet != alphabet)
    {
        m_changed[Alphabet] = true;
        m_alphabet = alphabet;
        emit alphabetChanged();
        emit objectChanged();
    }
}
void SorterParams::set_reversed(bool reversed)
{
    if (m_reversed != reversed)
    {
        m_changed[Reversed] = true;
        m_reversed = reversed;
        emit reversedChanged();
        emit objectChanged();
    }
}

bool SorterParams::check_param() const
{
    return m_changed[Param];
}
bool SorterParams::check_alphabet() const
{
    return m_changed[Alphabet];
}
bool SorterParams::check_reversed() const
{
    return m_changed[Reversed];
}

bool SorterParams::check_all() const
{
    return std::all_of(m_changed.begin(), m_changed.end(), [](bool b) { return b; });
}

bool SorterParams::check_any() const
{
    return std::any_of(m_changed.begin(), m_changed.end(), [](bool b) { return b; });
}

void SorterParams::merge(const SorterParams &other)
{
    bool changed = false;

    if (other.m_changed[Param])
    {
        m_changed[Param] = true;
        m_param = other.m_param;
        changed = true;
    }
    if (other.m_changed[Alphabet])
    {
        m_changed[Alphabet] = true;
        m_alphabet = other.m_alphabet;
        changed = true;
    }
    if (other.m_changed[Reversed])
    {
        m_changed[Reversed] = true;
        m_reversed = other.m_reversed;
        changed = true;
    }

    if (changed)
    {
        emit objectChanged();
    }
}
SorterParams SorterParams::merge_copy(const SorterParams &other)
{
    return SorterParams {
        parent(),
        other.m_changed[Param] ? other.m_param : m_param,
        other.m_changed[Alphabet] ? other.m_alphabet : m_alphabet,
        other.m_changed[Reversed] ? other.m_reversed : m_reversed};
}

void SorterParams::read(const QJsonObject &json)
{
    if (json.contains("param") && json["param"].isString())
    {
        set_param(json["param"].toString());
//        m_param = json["param"].toString();
    }


    if (json.contains("alphabet") && json["alphabet"].isBool())
    {
//        m_alphabet = json["alphabet"].toBool();
        set_alphabet(json["alphabet"].toBool());
    }

    if (json.contains("reversed") && json["reversed"].isBool())
    {
//        m_reversed = json["reversed"].toBool();
        set_reversed(json["reversed"].toBool());
    }
}

void SorterParams::write(QJsonObject &json) const
{
    if (m_changed[Param])
        json["param"] = m_param;
    if (m_changed[Alphabet])
        json["alphabet"] = m_alphabet;
    if (m_changed[Reversed])
        json["reversed"] = m_reversed;
}

int SorterParams::qmlRegisterType(const char *uri, int versionMajor, int versionMinor)
{
    return ::qmlRegisterType<SorterParams>(uri, versionMajor, versionMinor, "SorterParams");
}

int SorterParams::qRegisterMetaType()
{
    return ::qRegisterMetaType<SorterParams*>("SorterParams*");
}
