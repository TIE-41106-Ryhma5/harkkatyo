#include <QApplication>
#include <QQuickWindow>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    window->showFullScreen();

    return app.exec();
}

