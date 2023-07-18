#ifndef CITYMANAGER_H
#define CITYMANAGER_H

#include <QAbstractListModel>
#include <QMap>
#include <QSet>
#include <QSettings>

class CityManager : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString currentCity READ currentCity WRITE setCurrentCity NOTIFY currentCityChanged)
    Q_PROPERTY(bool currentCityFavorite READ currentCityFavorite WRITE setCurrentCityFavorite NOTIFY currentCityFavoriteChanged)
    Q_PROPERTY(QVariantMap currentCityData READ currentCityData WRITE setCurrentCityData NOTIFY currentCityDataChanged)

public:
    explicit CityManager(QObject *parent = nullptr);
    ~CityManager() override;

    QString currentCity() const;
    void setCurrentCity(const QString& name);

    bool currentCityFavorite() const;
    void setCurrentCityFavorite(bool checked);

    const QVariantMap& currentCityData() const;
    void setCurrentCityData(const QVariantMap& data);

    Q_INVOKABLE void apply();
    Q_INVOKABLE void toggleCity(const QString& name, bool checked, const QVariantMap& data);
    Q_INVOKABLE bool isFavorite(const QString& name);
    Q_INVOKABLE void clean();
    Q_INVOKABLE QVariantMap loadCityDataFromFavorite(const QString &name);
    Q_INVOKABLE void appendCurrentCityData(const QVariantMap& data);

    static int registerType();

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    enum Role {
        CityName = Qt::DisplayRole,
        Favorite = Qt::UserRole + 1,
    };

signals:
    void currentCityChanged();
    void currentCityFavoriteChanged();
    void currentCityDataChanged();

private:
    QString current_city;
    QVariantMap current_city_data;
    QMap<QString, QVariantMap> favorites;
    QSet<QString> to_remove;
    QSettings settings;
};

#endif // CITYMANAGER_H
