public class Collection {
  private List<IOperation> operations = null;
  private List<SObject> sObjectCollection = null;

  private Collection() {
  }

  private Collection(Collection c) {
    this.operations = c.operations.clone();
    this.sObjectCollection = c.sObjectCollection.clone();
  }

  public static Collection of(List<SObject> coll) {
    Collection c = new Collection();
    c.sObjectCollection = coll;
    c.operations = new List<IOperation>();
    return c;
  }

  private Collection addOperation(IOperation op) {
    Collection c = new Collection(this);
    c.operations.add(op);
    return c;
  }

  public Collection mapValues(MapOperation op) {
    return this.addOperation(op);
  }

  public Collection filterValues(FilterOperation op) {
    return this.addOperation(op);
  }

  private SObject applyOperations(SObject record) {
    boolean filtered = false;
    boolean isClone = false;
    for (IOperation o : this.operations) {
      if (o instanceof MapOperation) {
        if (isClone == false) {
          record = record.clone(true, true);
          isClone = true;
        }
        record = ((MapOperation) o).doMap(record);
      } else if (o instanceof FilterOperation) {
        if (!((FilterOperation) o).doFilter(record)) {
          filtered = true;
          break;
        }
      }
    }
    if (!filtered)
      return record;
    return null;
  }

  public List<SObject> toList() {
    List<SObject> newCollection = new List<SObject>();
    for (SObject s : this.sObjectCollection) {
      SObject processedRecord = this.applyOperations(s);
      if (processedRecord != null)
        newCollection.add(processedRecord);
    }
    return newCollection;
  }

  public void toMapByField(SObjectField field, Map<Object, List<SObject>> returnMap) {
    List<SObject> newCollection = new List<SObject>();
    for (SObject s : this.sObjectCollection) {
      SObject processedRecord = this.applyOperations(s);
      if (processedRecord != null) {
        if (!returnMap.containsKey(processedRecord.get(field))) {
          List<SObject> sobjList = this.sobjectCollection.clone();
          sobjList.clear();
          returnMap.put(processedRecord.get(field), sobjList);
        }
        returnMap.get(processedRecord.get(field)).add(processedRecord);
      }
    }
  }

  public void toMapByField(SObjectField field, Map<Object, SObject> returnMap) {
    List<SObject> newCollection = new List<SObject>();
    for (SObject s : this.sObjectCollection) {
      SObject processedRecord = this.applyOperations(s);
      if (processedRecord != null) {
        returnMap.put(processedRecord.get(field), processedRecord);
      }
    }
  }
}
