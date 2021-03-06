/****************************************************************************
**
** Copyright (C) 2013 Research In Motion.
** Contact: http://www.qt-project.org/legal
**
** This file is part of the QtQml module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QQMLINSTANTIATOR_P_P_H
#define QQMLINSTANTIATOR_P_P_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists purely as an
// implementation detail.  This header file may change from version to
// version without notice, or even be removed.
//
// We mean it.
//

#include "qqmlinstantiator_p.h"
#include <QObject>
#include <private/qobject_p.h>
#include <private/qqmlchangeset_p.h>
#include <private/qqmlobjectmodel_p.h>

QT_BEGIN_NAMESPACE

class QQmlInstantiatorPrivate : public QObjectPrivate
{
    Q_DECLARE_PUBLIC(QQmlInstantiator)

public:
    QQmlInstantiatorPrivate();
    ~QQmlInstantiatorPrivate();

    void clear();
    void regenerate();
    void makeModel();
    void _q_createdItem(int, QObject *);
    void _q_modelUpdated(const QQmlChangeSet &, bool);

    bool componentComplete:1;
    bool effectiveReset:1;
    bool active:1;
    bool async:1;
    bool ownModel:1;
    QVariant model;
    QQmlInstanceModel *instanceModel;
    QQmlComponent *delegate;
    QVector<QPointer<QObject> > objects;
};

QT_END_NAMESPACE

#endif // QQMLCREATOR_P_P_H
