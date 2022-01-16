@isTest
public class CollectionTest {
  @isTest
  public static void testFilter() {
    Account[] accountList = new List<Account>{};
    accountList.add(new Account(Name = 'Acme'));
    accountList.add(new Account(Name = 'Global'));
    accountList.add(new Account(Name = 'Tech'));
    Collection acctCollection = Collection.of(accountList);
    Account[] result = acctCollection.filterValues(new AccountNameFilter('Acme')).toList();
    system.assertEquals(1, result.size());
    system.assertEquals('Acme', result[0].Name);
  }

  @isTest
  public static void testFilterAndMap() {
    Account[] accountList = new List<Account>{};
    accountList.add(new Account(Name = 'Acme'));
    accountList.add(new Account(Name = 'Global'));
    accountList.add(new Account(Name = 'Tech'));
    accountList.add(new Account(Name = 'Acclimate'));
    Collection acctCollection = Collection.of(accountList);
    system.assertEquals(4, acctCollection.toList().size());
    Account[] result = acctCollection
      .mapValues(new AccountMap())
      .filterValues(new AccountRevenueFilter())
      .mapValues(new AccountMap())
      .toList();
    system.assertEquals(2, result.size());
    system.assertEquals('Acme', result[0].Name);
    system.assertEquals('Acclimate', result[1].Name);
    system.assertEquals(20000, result[1].AnnualRevenue);
    system.assertEquals(4, acctCollection.toList().size());
  }

  @isTest
  public static void itShouldMapByFieldUnique() {
    Account[] accountList = new List<Account>{};
    accountList.add(new Account(Name = 'Acme', Industry = 'Technology'));
    accountList.add(new Account(Name = 'Global', Industry = 'Healthcare'));
    accountList.add(new Account(Name = 'Tech', Industry = 'Technology'));
    accountList.add(new Account(Name = 'Acclimate', Industry = 'Agriculture'));
    Collection acctCollection = Collection.of(accountList);
    Map<Object, Account> acctsByIndustry = new Map<Object, Account>();
    acctCollection.toMapByField(Account.Industry, acctsByIndustry);
    system.assertEquals(3, acctsByIndustry.size(), 'Expected map by field to SObject to produce 3 values');
    system.assert(
      acctsByIndustry.get('Technology') != null,
      'Expected map by field to SObject to return only 1 record per key'
    );
  }

  @isTest
  public static void itShouldMapByField() {
    Account[] accountList = new List<Account>{};
    accountList.add(new Account(Name = 'Acme', Industry = 'Technology'));
    accountList.add(new Account(Name = 'Global', Industry = 'Healthcare'));
    accountList.add(new Account(Name = 'Tech', Industry = 'Technology'));
    accountList.add(new Account(Name = 'Acclimate', Industry = 'Agriculture'));
    Collection acctCollection = Collection.of(accountList);
    Map<Object, List<Account>> acctsListByIndustry = new Map<Object, List<Account>>();
    acctCollection.filterValues(new AccountIndustryFilter()).toMapByField(Account.Industry, acctsListByIndustry);
    System.assertEquals(
      1,
      acctsListByIndustry.size(),
      'Expected map by field to SObject to produce 1 values after fitering out everything but "Technology"'
    );
    System.assertEquals(
      2,
      acctsListByIndustry.get('Technology').size(),
      'Expected map by field to SObject to return 2 records for the industry "Technology"'
    );
  }

  class AccountIndustryFilter implements FilterOperation {
    public Boolean doFilter(SObject a) {
      return ((Account) a).Industry == 'Technology';
    }
  }

  class AccountRevenueFilter implements FilterOperation {
    public Boolean doFilter(SObject a) {
      return ((Account) a).AnnualRevenue > 5001;
    }
  }

  class AccountNameFilter implements FilterOperation {
    String name;
    public AccountNameFilter(String name) {
      this.name = name;
    }
    public Boolean doFilter(SObject a) {
      return ((Account) a).Name == this.name;
    }
  }

  class AccountMap implements MapOperation {
    public SObject doMap(SObject a) {
      Account acc = (Account) a;
      acc.AnnualRevenue = acc.Name.startsWith('Ac') ? acc.AnnualRevenue == null ? 10000 : acc.AnnualRevenue * 2 : 5000;
      return acc;
    }
  }
}
