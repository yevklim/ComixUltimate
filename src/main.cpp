#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCoreApplication>
#include <QTextStream>
//#include <QStandardPaths>

#include "DataBase.hpp"
#include "DataBaseViewer.hpp"
#include "DataBaseViewer.hpp"
#include "HistoryViewer.hpp"
#include "FilterParams.hpp"
#include "SorterParams.hpp"
#include "Parser.hpp"
#include "Provider.hpp"
#include "LocalCachingNetworkAccessManagerFactory.hpp"
#include "Palettes.hpp"
#include "PageLimiter.hpp"
#include "Pager.hpp"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    QStringList args = QCoreApplication::arguments();

    bool json = true;
    if (args.length() > 1)
        json = (args[1].toLower() != QStringLiteral("binary"));

    DataBase database(&app);
    if (!database.load(json ? ISaveLoad::Json : ISaveLoad::Binary))
        return 1;

    DataBaseViewer databaseViewer(&database);
    HistoryViewer historyViewer(&database);
    Palettes palettes(&app);

    MasterProvider provider(&app, &database);

    LocalCachingNetworkAccessManagerFactory NAMFactory{};
    QQmlApplicationEngine engine(&app);
    const QUrl url(QStringLiteral("qrc:/ui/Main.qml"));

    engine.setNetworkAccessManagerFactory(&NAMFactory);

    engine.rootContext()->setContextProperty(QString("Palettes"), &palettes);
    engine.rootContext()->setContextProperty(QString("Provider"), &provider);
    engine.rootContext()->setContextProperty(QString("DataBase"), &database);
    engine.rootContext()->setContextProperty(QString("DataBaseViewer"), &databaseViewer);
    engine.rootContext()->setContextProperty(QString("HistoryViewer"), &historyViewer);

    FilterParams::qmlRegisterType("ComixUltimate", 1, 0);
    SorterParams::qmlRegisterType("ComixUltimate", 1, 0);
    DBItem::qmlRegisterType("ComixUltimate", 1, 0);
    PageLimiter::qmlRegisterType("ComixUltimate", 1, 0);
    Pager::qmlRegisterType("ComixUltimate", 1, 0);

    FilterParams::qRegisterMetaType();
    SorterParams::qRegisterMetaType();
    DBItem::qRegisterMetaType();

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
