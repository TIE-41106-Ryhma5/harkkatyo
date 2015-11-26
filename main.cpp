#include <QApplication>
#include <QQuickWindow>
#include <QQmlApplicationEngine>
#include "vibrator.h"
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    Vibrator vibrator;

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    window->showFullScreen();
    engine.rootContext()->setContextProperty("Vibrator", &vibrator);

    return app.exec();
}

