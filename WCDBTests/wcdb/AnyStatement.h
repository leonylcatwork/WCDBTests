//
//  AnyStatement.h
//  momo_ios
//
//  Created by leon on 24/01/2020.
//  Copyright © 2020 MaiMemo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WCDB/Column.hpp>
#import <WCDB/statement.hpp>

namespace WCDB {

class AnyStatement : public Statement {
public:
    AnyStatement();
    AnyStatement(NSString *stmt = @"", Statement::Type aType = Statement::Type::None);
    AnyStatement(const char *stmt = "", Statement::Type aType = Statement::Type::None);
    AnyStatement(const Statement &statement, bool subquery = false);
    AnyStatement &merge(const Statement &statement, bool subquery = false);
    AnyStatement &append(const Expr &expr, bool subquery = false);

    virtual Statement::Type getStatementType() const override;
private:  Statement::Type _type;
};

}
