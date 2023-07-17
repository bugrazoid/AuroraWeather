#include "geoinfo.h"

#include <QDebug>
#include <QGeoPositionInfoSource>

GeoProvider::GeoProvider(QObject *parent)
    : QObject(parent),
      geo_source(QGeoPositionInfoSource::createDefaultSource(this))
{
    qDebug() << QGeoPositionInfoSource::availableSources();
    qDebug() << geo_source;
    if (geo_source != nullptr) {
        last_coordinate = geo_source->lastKnownPosition().coordinate();
    }
}

QGeoCoordinate GeoProvider::coordinate()
{
    return last_coordinate;
}
