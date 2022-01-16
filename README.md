# A simple lazy collections framework in Apex

The operations are run only when `toList()` or `toMapByField()` is called on the collection. The records are looped over only once

- Usage

```apex

Account[] result = acctCollection
  .mapValues(new AccountMap())
  .filterValues(new AccountRevenueFilter())
  .mapValues(new AccountMap())
  .toList();
```

- Aternatively, you can retrieve a map of record by field value

```apex

Map<String,Account> acctIndustryMap = new Map<String,Account>();
acctCollection
  .mapValues(new AccountMap())
  .filterValues(new AccountRevenueFilter())
  .mapValues(new AccountMap())
  .toMapByField(Account.Industry,acctIndustryMap);

//acctIndustryMap will contain the mapped values. If there are multiple records with the same 'Industry' value, the last record in the list with the value will be returned in the map

```

- or, you can retrieve a map of list of records by field value

```apex

Map<String,List<Account>> acctsIndustryMap = new Map<String,List<Account>>();
acctCollection
  .mapValues(new AccountMap())
  .filterValues(new AccountRevenueFilter())
  .mapValues(new AccountMap())
  .toMapByField(Account.Industry,acctsIndustryMap);

//acctIndustryMap will contain the mapped values

```

- Creating a Collection

```apex

Account[] accounts = [Select Name,AnnualRevenue from Accounts];
Collection acctCollection = Collection.of(accounts);

```

- How to implement a mapper class

```apex
class AccountMap implements MapOperation {
  public SObject doMap(SObject a) {
    Account acc = (Account) a;
    acc.AnnualRevenue = acc.Name.startsWith(('Ac)
      ? acc.AnnualRevenue == null ? 10000 : acc.AnnualRevenue * 2
      : 5000;
    return acc;
  }
}
```

- How to implement a filter class

```apex
class AccountRevenueFilter implements FilterOperation {
  public Boolean doFilter(SObject a) {
    return ((Account) a).AnnualRevenue > 5001;
  }
}
```
