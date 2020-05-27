# A simple lazy collections framework in Apex

The operations are run only when `toList()` is called on the collection. The records are looped over only once

* Creating a Collection

```
Account[] accounts = [Select Name,AnnualRevenue from Accounts];
Collection acctCollection = Collection.of(accounts);
```

* How to implement a mapper class

```
  class AccountMap implements MapOperation {
    public SObject doMap(SObject a) {
      Account acc = (Account) a;
      acc.AnnualRevenue = acc.Name.startsWith('Ac')
        ? acc.AnnualRevenue == null ? 10000 : acc.AnnualRevenue * 2
        : 5000;
      return acc;
    }
  }
```

* How to implement a filter class

```
  class AccountRevenueFilter implements FilterOperation {
    public Boolean doFilter(SObject a) {
      return ((Account) a).AnnualRevenue > 5001;
    }
  }

```

* Usage

```
    Account[] result = acctCollection
      .mapValues(new AccountMap())
      .filterValues(new AccountRevenueFilter())
      .mapValues(new AccountMap())
      .toList();
```
