//
//  AnyStatement.m
//  momo_ios
//
//  Created by leon on 24/01/2020.
//  Copyright © 2020 MaiMemo Inc. All rights reserved.
//

#import "AnyStatement.h"
#include <WCDB/expr.hpp>


namespace WCDB {


AnyStatement::AnyStatement() : Statement()
{
    _type = Statement::Type::None;
}


AnyStatement::AnyStatement(NSString *stmt, Statement::Type aType) : Statement()
{
    _type = aType;
    m_description.append(stmt.UTF8String);
}


AnyStatement::AnyStatement(const char *stmt, Statement::Type aType) : Statement()
{
    _type = aType;
    m_description.append(stmt);
}


AnyStatement::AnyStatement(const Statement &statement, bool subquery) : Statement()
{
    _type = statement.getStatementType();
    m_description.append(subquery ? ("(" + statement.getDescription() + ")") : statement.getDescription());
}


Statement::Type AnyStatement::getStatementType() const
{
    return _type;
}


AnyStatement &AnyStatement::merge(const Statement &statement, bool subquery)
{
    m_description.append(subquery ? (" (" + statement.getDescription() + ")") : (" " + statement.getDescription()));
    return *this;
}


AnyStatement &AnyStatement::append(const Expr &expr, bool subquery)
{
    if (!expr.isEmpty()) {
        m_description.append(subquery ? (" (" + expr.getDescription() + ")") : (" " + expr.getDescription()));
    }
    return *this;
}


}
