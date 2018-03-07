/// Either a single SQL `DataPredicate` or a group (AND/OR) of them.
public enum DataPredicateItem {
    case group(DataPredicateGroup)
    case predicate(DataPredicate)
}
