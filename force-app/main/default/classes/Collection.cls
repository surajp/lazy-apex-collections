public class Collection {
	private List<IOperation> operations=null;
    private List<SObject> sObjectCollection=null;
    private Collection(){}
    private Collection(Collection c){
        this.operations=c.operations.clone();
        this.sObjectCollection=c.sObjectCollection.clone();
    }
    public static Collection of(List<SObject> coll){
        Collection c=new Collection();
        c.sObjectCollection=coll;
        c.operations = new List<IOperation>();
        return c; 
    }
    private Collection addOperation(IOperation op){
        Collection c = new Collection(this);
        c.operations.add(op);
        return c;
    }
    public Collection mapValues(MapOperation op){
        return this.addOperation(op);
    }
    
    public Collection filterValues(FilterOperation op){
        return this.addOperation(op);
    }
    
    public List<SObject> toList(){
        List<SObject> newCollection = new List<SObject>();
        for(SObject s:sobjectCollection){
            boolean filtered=false;
            boolean isClone=false;
            for(IOperation o:operations){
                if(o instanceOf MapOperation){
                    if(isClone==false){
                        s=s.clone(true, true);
                        isClone=true;
                    }
                    s=((MapOperation)o).doMap(s);
                }else if(o instanceOf FilterOperation){
                    if(!((FilterOperation)o).doFilter(s)){
                        filtered=true;
                        break;
                    }
                }
            }
            if(!filtered){
                newCollection.add(s);
            }
        }
        return newCollection;
    }
    
}
