## FinderPath Variable in FinderImpl Class

When a *FinderImpl.java contains `public static final FinderPath`, it means that
the class is using FinderCache and we should override the method
`BasePersistenceImpl.fetchByPrimaryKeys(Set<Serializable>)`.