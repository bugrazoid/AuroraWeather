#include "citymanager.h"

#include <QtQml>
#include <QDebug>

#include "common.h"

CityManager::CityManager(QObject *parent)
    : QAbstractListModel(parent),
      current_city("Москва"),
      settings(ORGANIZATION_NAME, APPLICATION_NAME)
{
    auto cc = settings.value("current_city").toString();
    if (!cc.isEmpty()) {
        current_city = cc;
    }
    current_city_data = settings.value("current_city_data").toMap();
    const auto size = settings.beginReadArray("favorites");
    for (int i = 0; i < size; ++i) {
        settings.setArrayIndex(i);
        QString name = settings.value("name").toString();
        QVariantMap data = settings.value("data").toMap();
        qDebug() << i << name;
        favorites.insert(name, data);
    }
    settings.endArray();

    qDebug() << "settings file:" << settings.fileName();

//    if (favorites.isEmpty()) {
//        QVariantMap rnd = {
//            {"v_temp", 25.5},
//            {"v_windspeed", 1.5},
//            {"v_winddirection", 25},
//            {"v_weathercode", 0},
//        };
//        QVariantMap msc = {
//            {"v_temp", 24.4},
//            {"v_windspeed", 2.6},
//            {"v_winddirection", 197},
//            {"v_weathercode", 3},
//        };
//        favorites.insert("Ростов-на-Дону", {
//                             {"v_name", "Ростов-на-Дону"},
//                             {"v_lat", 49.0},
//                             {"v_lon", 49.0},
//                             {"v_current_weather", rnd}
//                         });
//        favorites.insert("Москва", {
//                             {"v_name", "Москва"},
//                             {"v_lat", 49.0},
//                             {"v_lon", 49.0},
//                             {"v_current_weather", msc}
//                         });
//    }
}

CityManager::~CityManager()
{
    settings.setValue("current_city", current_city);
    settings.setValue("current_city_data", current_city_data);
    settings.beginWriteArray("favorites");
    int index = 0;
    while (!favorites.isEmpty()) {
        auto name = favorites.lastKey();
        qDebug() << name;
        auto data = favorites.take(name);
        settings.setArrayIndex(index++);
        settings.setValue("name", name);
        settings.setValue("data", data);
    }
    settings.endArray();
}

QString CityManager::currentCity() const
{
    return current_city;
}

void CityManager::setCurrentCity(const QString &name)
{
    current_city = name;
    Q_EMIT currentCityChanged();
    Q_EMIT currentCityFavoriteChanged();
}

bool CityManager::currentCityFavorite() const
{
    return favorites.contains(current_city);
}

void CityManager::setCurrentCityFavorite(bool checked)
{
    toggleCity(current_city, checked, current_city_data);
    Q_EMIT currentCityFavoriteChanged();
}

const QVariantMap &CityManager::currentCityData() const
{
    return current_city_data;
}

void CityManager::setCurrentCityData(const QVariantMap& data)
{
    qDebug() << data;
    for (auto it = data.begin(); it != data.end(); ++it) {
        current_city_data.insert(it.key(), it.value());
    }
    Q_EMIT currentCityDataChanged();
}

void CityManager::apply()
{
    for (auto it = to_remove.begin(); it != to_remove.end(); ++it) {
        favorites.remove(*it);
    }
    to_remove.clear();
}

void CityManager::toggleCity(const QString& name, bool checked, const QVariantMap& data)
{
    qDebug() << name << checked << data;
    if (checked) {
        favorites.insert(name, data);
    } else {
        favorites.remove(name);
    }
}

bool CityManager::isFavorite(const QString &name)
{
    return favorites.contains(name);
}

void CityManager::clean()
{
    settings.clear();
    settings.sync();
    favorites.clear();
    current_city_data.clear();
    qDebug() << "clean data";
}

void CityManager::loadCurrentCityDataFromFavorite()
{
    setCurrentCityData(favorites.value(current_city));
}

int CityManager::registerType()
{
    static int registred = []{
        return qmlRegisterType<CityManager>(QML_MODULE_NAME, 1, 0, STRINGIFY(CityManager));
    }();
    return registred;
}


int CityManager::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return favorites.count();
}

QVariant CityManager::data(const QModelIndex &index, int role) const
{
    const auto row = index.row();
    const auto it = favorites.begin() + row;
    const auto& key = it.key();
    QVariant v;

    switch (role) {
    case CityName:
        v = key;
        break;
    case Favorite:
        v = !to_remove.contains(key);
        break;
    default:
        break;
    }

    return v;
}


QHash<int, QByteArray> CityManager::roleNames() const
{
    auto role_names = QAbstractListModel::roleNames();
    role_names.insert(CityName, "cityName");
    role_names.insert(Favorite, "favorite");
    return role_names;
}

bool CityManager::setData(const QModelIndex &index, const QVariant &value, int role)
{
    bool changed = false;
    const auto row = index.row();
    const auto it = favorites.begin() + row;
    const auto& key = it.key();

    switch (role) {
    case Favorite:
    {
        bool is_checked = value.toBool();
        if (is_checked) {
            to_remove.remove(key);
        } else {
            to_remove.insert(key);
        }
        changed = true;
        break;
    }
    default:
        break;
    }

    if (changed) {
        Q_EMIT dataChanged(index, index, {Favorite});
    }
    return changed;
}
