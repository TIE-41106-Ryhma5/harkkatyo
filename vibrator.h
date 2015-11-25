#ifndef VIBRATOR_H
#define VIBRATOR_H

#include <QObject>
#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>

class Vibrator : public QObject
{
    Q_OBJECT
    public:
        explicit Vibrator(QObject *parent = 0);
    signals:
    public slots:
        void vibrate(int milliseconds);
    private:
        QAndroidJniObject vibratorService;
};

#endif // VIBRATOR_H
