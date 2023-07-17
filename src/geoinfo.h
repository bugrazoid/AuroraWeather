#ifndef GEOINFO_H
#define GEOINFO_H

#include <QObject>
#include <QGeoCoordinate>

class QGeoPositionInfoSource;

class GeoProvider : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QGeoCoordinate coordinate READ coordinate NOTIFY coordinateChanged)

public:
    explicit GeoProvider(QObject *parent = nullptr);

    QGeoCoordinate coordinate();

signals:
    void coordinateChanged();

private:
    QGeoPositionInfoSource* geo_source;
    QGeoCoordinate last_coordinate;

};

#endif // GEOINFO_H
