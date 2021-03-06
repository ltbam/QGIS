
class QgsVectorDataProvider : QgsDataProvider
{
%TypeHeaderCode
#include <qgsvectordataprovider.h>
%End

  public:

    // If you add to this, please also add to capabilitiesString()
    /**
     * enumeration with capabilities that providers might implement
     */
    enum Capability
    {
      /** Provider has no capabilities */
      NoCapabilities,
      /** Allows adding features */
      AddFeatures,
      /** Allows deletion of features */
      DeleteFeatures,
      /** Allows modification of attribute values */
      ChangeAttributeValues,
      /** Allows addition of new attributes (fields) */
      AddAttributes,
      /** Allows deletion of attributes (fields) */
      DeleteAttributes,
      /** DEPRECATED - do not use */
      SaveAsShapefile,
      /** Allows creation of spatial index */
      CreateSpatialIndex,
      /** Fast access to features using their ID */
      SelectAtId,
      /** Allows modifications of geometries */
      ChangeGeometries,
      /** DEPRECATED - do not use */
      SelectGeometryAtId,
      /** DEPRECATED - do not use */
      RandomSelectGeometryAtId,
      /** DEPRECATED - do not use */
      SequentialSelectGeometryAtId,
      CreateAttributeIndex,
      /** Allows user to select encoding */
      SelectEncoding,
      /** Supports simplification of geometries on provider side according to a distance tolerance */
      SimplifyGeometries,
      /** Supports topological simplification of geometries on provider side according to a distance tolerance */
      SimplifyGeometriesWithTopologicalValidation,
      /** Supports transactions*/
      TransactionSupport
    };

    /** Bitmask of all provider's editing capabilities */
    static const int EditingCapabilities;

    /**
     * Constructor of the vector provider
     * @param uri  uniform resource locator (URI) for a dataset
     */
    QgsVectorDataProvider( QString uri = QString() );

    /**
     * Destructor
     */
    virtual ~QgsVectorDataProvider();

    /**
     * Return feature source object that can be used for querying provider's data. The returned feature source
     * is independent from provider - any changes to provider's state (e.g. change of subset string) will not be
     * reflected in the feature source, therefore it can be safely used for processing in background without
     * having to care about possible changes within provider that may happen concurrently. Also, even in the case
     * of provider being deleted, any feature source obtained from the provider will be kept alive and working
     * (they are independent and owned by the caller).
     *
     * Sometimes there are cases when some data needs to be shared between vector data provider and its feature source.
     * In such cases, the implementation must ensure that the data is not susceptible to run condition. For example,
     * if it is possible that both feature source and provider may need reading/writing to some shared data at the
     * same time, some synchronization mechanisms must be used (e.g. mutexes) to prevent data corruption.
     *
     * @note added in 2.4
     * @return new instance of QgsAbstractFeatureSource (caller is responsible for deleting it)
     */
    virtual QgsAbstractFeatureSource* featureSource() const /Factory/;

    /**
     * Returns the permanent storage type for this layer as a friendly name.
     */
    virtual QString storageType() const;

    /**
     * Query the provider for features specified in request.
     */
    virtual QgsFeatureIterator getFeatures( const QgsFeatureRequest& request = QgsFeatureRequest() ) = 0;

    /**
     * Get feature type.
     * @return int representing the feature type
     */
    virtual QGis::WkbType geometryType() const = 0;

    /**
     * Number of features in the layer
     * @return long containing number of features
     */
    virtual long featureCount() const = 0;

    /**
     * Return a map of indexes with field names for this layer
     * @return map of fields
     * @see QgsFields
     */
    virtual const QgsFields &fields() const = 0;

    /**
     * Return a short comment for the data that this provider is
     * providing access to (e.g. the comment for postgres table).
     */
    virtual QString dataComment() const;

    /**
     * Returns the minimum value of an attribute
     * @param index the index of the attribute
     *
     * Default implementation walks all numeric attributes and caches minimal
     * and maximal values. If provider has facilities to retrieve minimal
     * value directly, override this function.
     */
    virtual QVariant minimumValue( int index );

    /**
     * Returns the maximum value of an attribute
     * @param index the index of the attribute
     *
     * Default implementation walks all numeric attributes and caches minimal
     * and maximal values. If provider has facilities to retrieve maximal
     * value directly, override this function.
     */
    virtual QVariant maximumValue( int index );

    /**
     * Return unique values of an attribute
     * @param index the index of the attribute
     * @param uniqueValues values reference to the list to fill
     * @param limit maxmum number of the values to return
     *
     * Default implementation simply iterates the features
     */
    virtual void uniqueValues( int index, QList<QVariant> &uniqueValues /Out/, int limit = -1 );

    /**
     * Returns the possible enum values of an attribute. Returns an empty stringlist if a provider does not support enum types
     * or if the given attribute is not an enum type.
     * @param index the index of the attribute
     * @param enumList reference to the list to fill
     */
    virtual void enumValues( int index, QStringList& enumList /Out/ );

    /**
     * Adds a list of features
     * @return true in case of success and false in case of failure
     */
    virtual bool addFeatures( QList<QgsFeature> &flist /In,Out/ );

    /**
     * Deletes one or more features
     * @param id list containing feature ids to delete
     * @return true in case of success and false in case of failure
     */
    virtual bool deleteFeatures( const QSet<qint64> &id );

    /**
     * Adds new attributes
     * @param attributes list of new attributes
     * @return true in case of success and false in case of failure
     */
    virtual bool addAttributes( const QList<QgsField> &attributes );

    /**
     * Deletes existing attributes
     * @param attributes a set containing indices of attributes
     * @return true in case of success and false in case of failure
     */
    virtual bool deleteAttributes( const QSet<int> &attributes );

    /**
     * Changes attribute values of existing features.
     * @param attr_map a map containing changed attributes
     * @return true in case of success and false in case of failure
     */
    virtual bool changeAttributeValues( const QMap<qint64, QMap<int, QVariant> > &attr_map );

    /**
     * Returns the default value for field specified by @c fieldId
     */
    virtual QVariant defaultValue( int fieldId );

    /**
     * Changes geometries of existing features
     * @param geometry_map   A QgsGeometryMap whose index contains the feature IDs
     *                       that will have their geometries changed.
     *                       The second map parameter being the new geometries themselves
     * @return               True in case of success and false in case of failure
     */
    virtual bool changeGeometryValues( QMap<qint64, QgsGeometry> & geometry_map );

    /**
     * Creates a spatial index on the datasource (if supported by the provider type).
     * @return true in case of success
     */
    virtual bool createSpatialIndex();

    /** Create an attribute index on the datasource*/
    virtual bool createAttributeIndex( int field );

    /** Returns a bitmask containing the supported capabilities
        Note, some capabilities may change depending on whether
        a spatial filter is active on this provider, so it may
        be prudent to check this value per intended operation.
     */
    virtual int capabilities() const;

    /**
     *  Returns the above in friendly format.
     */
    QString capabilitiesString() const;

    /**
     * Set encoding used for accessing data from layer
     */
    virtual void setEncoding( const QString& e );

    /**
     * Get encoding which is used for accessing data
     */
    QString encoding() const;

    /**
     * Returns the index of a field name or -1 if the field does not exist
     */
    int fieldNameIndex( const QString& fieldName ) const;

    /**
     * Return a map where the key is the name of the field and the value is its index
     */
    QMap<QString, int> fieldNameMap() const;

    /**
     * Return list of indexes to fetch all attributes in nextFeature()
     */
    QList<int> attributeIndexes();

    /**
     * Return list of indexes of fields that make up the primary key
     */
    virtual QList<int> pkAttributeIndexes();

    /**
     * Return list of indexes to names for QgsPalLabeling fix
     */
    virtual QHash<int, QString> palAttributeIndexNames() const;

    /**
     * check if provider supports type of field
     */
    bool supportedType( const QgsField &field ) const;

    struct NativeType
    {
      NativeType( QString typeDesc, QString typeName, QVariant::Type type, int minLen = 0, int maxLen = 0, int minPrec = 0, int maxPrec = 0 );

      QString mTypeDesc;
      QString mTypeName;
      QVariant::Type mType;
      int mMinLen;
      int mMaxLen;
      int mMinPrec;
      int mMaxPrec;
    };

    /**
     * Returns the names of the supported types
     */
    const QList< QgsVectorDataProvider::NativeType > &nativeTypes() const;

    /**
     * Returns true if the provider is strict about the type of inserted features
     * (e.g. no multipolygon in a polygon layer)
     */
    bool doesStrictFeatureTypeCheck() const;

    /** Returns a list of available encodings */
    static const QStringList &availableEncodings();

    /**
     * Provider has errors to report
     */
    bool hasErrors();

    /**
     * Clear recorded errors
     */
    void clearErrors();

    /**
     * Get recorded errors
     */
    QStringList errors();


    /**
     * It returns false by default.
     * Must be implemented by providers that support saving and loading styles to db returning true
     */
    virtual bool isSaveAndLoadStyleToDBSupported();

    static QVariant convertValue( QVariant::Type type, QString value );

    /**
     * Returns the transaction this data provider is included in, if any.
     */
    virtual QgsTransaction* transaction() const;

    virtual void forceReload();

  protected:
    void clearMinMaxCache();
    void fillMinMaxCache();

    void pushError( QString msg );
};
