#ifndef ARDUINOEXCEPTIONS_H
#define ARDUINOEXCEPTIONS_H

#include <QObject>
#include <QException>


class VerifyException: public QException{
    public:
        VerifyException(const QString& s, const QList<QString>& l):message(s),errorsList(l){}
        void raise() const { throw *this; }
        VerifyException *clone() const { return new VerifyException(*this); }
        QString getMessage() const{return message;}

    public:
        const QString message;
        const QList<QString> errorsList;
};


class BoardNotKnownException: public QException{
    public:
        BoardNotKnownException(const QString& s):message(s){}
        void raise() const { throw *this; }
        BoardNotKnownException *clone() const { return new BoardNotKnownException(*this); }
        QString getMessage() const{return message;}

    private:
        QString message;
};

class BoardNotDetectedException: public QException{
    public:
        BoardNotDetectedException(const QString& s):message(s){}
        void raise() const { throw *this; }
        BoardNotDetectedException *clone() const { return new BoardNotDetectedException(*this); }
        QString getMessage() const{return message;}

    private:
        QString message;
};

#endif // ARDUINOEXCEPTIONS_H