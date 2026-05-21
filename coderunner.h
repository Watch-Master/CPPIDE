#ifndef CODERUNNER_H
#define CODERUNNER_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <QTemporaryFile>
#include <QTextStream>

class CodeRunner : public QObject {
    Q_OBJECT
public:
    explicit CodeRunner(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE void executeCode(const QString &language, const QString &code) {
        if (language == "HTML/CSS/JS") {
            emit webOutputReady(code);
            return;
        }

        process = new QProcess(this);
        connect(process, &QProcess::readyReadStandardOutput, this, [this]() {
            emit consoleOutputReady(process->readAllStandardOutput());
        });
        connect(process, &QProcess::readyReadStandardError, this, [this]() {
            emit consoleOutputReady("<font color='#ff0055'>" + process->readAllStandardError() + "</font>");
        });

        if (language == "Python") {
            runPython(code);
        } else if (language == "C++") {
            runCpp(code);
        }
    }

signals:
    void consoleOutputReady(const QString &output);
    void webOutputReady(const QString &htmlContent);

private:
    QProcess *process;

    void runPython(const QString &code) {
        QTemporaryFile scriptFile;
        if (scriptFile.open()) {
            QTextStream out(&scriptFile);
            out << code;
            scriptFile.close();
            process->start("python3", QStringList() << scriptFile.fileName());
            process->waitForFinished();
        }
    }

    void runCpp(const QString &code) {
        // Simplified compilation logic
        QTemporaryFile cppFile;
        cppFile.setFileTemplate("XXXXXX.cpp");
        if (cppFile.open()) {
            QTextStream out(&cppFile);
            out << code;
            QString fileName = cppFile.fileName();
            QString outName = fileName + ".out";
            cppFile.close();

            QProcess compiler;
            compiler.start("g++", QStringList() << fileName << "-o" << outName);
            compiler.waitForFinished();

            if (compiler.exitCode() == 0) {
                process->start(outName);
                process->waitForFinished();
            } else {
                emit consoleOutputReady("<font color='#ff0055'>" + compiler.readAllStandardError() + "</font>");
            }
        }
    }
};

#endif // CODERUNNER_H
