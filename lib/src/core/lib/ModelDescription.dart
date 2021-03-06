part of kourim.core.lib;

/// Default implementation of the interface [IModelDescription] used by the system in production mode.
class ModelDescription implements IModelDescription {
  Map<String, IModel> models = {};

  @override
  Option<IModel> findByName(String name) {
    return new Option(models[name]);
  }

  @override
  void add(IModel model) {
    models[model.name] = model;
  }

  @override
  Iterable<String> get modelNames {
    return models.keys;
  }
}

class Model implements IModel {
  String name;
  Map<String, IColumn> columns = {};
  Map<String, IQuery> queries = {};
  Map<String, IJoin> joins = {};
  Option<String> storage;
  Option<String> strategy;
  Option<int> limit;
  ClassMirror classMirror;
  bool isNestedOnly;

  @override
  bool get hasCache => storage.isDefined;

  @override
  bool get hasNotCache => !hasCache;

  @override
  Iterable<String> get queryNames {
    return queries.keys;
  }

  @override
  Iterable<String> get columnNames {
    return columns.keys;
  }

  Iterable<String> get joinNames {
    return joins.keys;
  }

  @override
  IColumn get keyColumn {
    for (var column in columns.values) {
      if (column.key) {
        return column;
      }
    }
    return null;
  }

  @override
  void addQuery(IQuery query) {
    queries[query.name] = query;
    query.model = this;
  }

  @override
  void addColumn(IColumn column) {
    columns[column.name] = column;
    column.model = this;
  }

  @override
  void addJoin(IJoin join) {
    joins[join.name] = join;
    join.model = this;
  }

  @override
  Option<IQuery> getQuery(String name) {
    return new Option(queries[name]);
  }

  @override
  Option<IColumn> getColumn(String name) {
    return new Option(columns[name]);
  }

  @override
  Option<IJoin> getJoin(String name) {
    return new Option(joins[name]);
  }

  @override
  IModel copy() {
    var model = new Model();
    model.name = name;
    model.storage = storage;
    model.strategy = strategy;
    model.limit = limit;
    model.classMirror = classMirror;
    model.columns = {};
    model.queries = {};
    columns.forEach((key, column) {
      model.columns[key] = column.copy();
      model.columns[key].model = model;
    });
    queries.forEach((key, query){
      model.queries[key] = query.copy();
      model.queries[key].model = model;
    });
    return model;
  }
}

class Column implements IColumn {
  IModel model;
  String name;
  bool key;
  bool unique;
  VariableMirror variableMirror;
  String type;
  bool isModelDescription;

  @override
  String get fullName => model.name + '.' + name;

  @override
  Object getValue(Object source) {
    var valueMirror = reflect(source).getField(variableMirror.simpleName);
    if (valueMirror.hasReflectee) {
      return valueMirror.reflectee;
    } else {
      return null;
    }
  }

  @override
  void setValue(Object source, Object value) {
    reflect(source).setField(variableMirror.simpleName, value);
  }

  @override
  IColumn copy() {
    var column = new Column();
    column.model = model;
    column.name = name;
    column.key = key;
    column.unique = unique;
    column.variableMirror = variableMirror;
    column.type = type;
    column.isModelDescription = isModelDescription;
    return column;
  }
}

class Query implements IQuery {
  IModel model;
  String name;
  Option<String> remote = new Option();
  Option<String> then = new Option();
  String type;
  bool authentication;
  List<String> fields = [];
  Option<dynamic> criteria = new Option();
  Option<String> storage;
  Option<int> limit;
  String strategy;

  @override
  Option<IQuery> get thenQuery {
    return then.map((then) => model.getQuery(then).get());
  }

  @override
  String get fullName => model.name + '.' + name;

  @override
  bool get hasCache => storage.isDefined && type == constants.get;

  @override
  bool get hasNotCache => !hasCache;

  @override
  IQuery copy() {
    var query = new Query();
    query.model = model;
    query.name = name;
    query.remote = remote;
    query.then = then;
    query.type = type;
    query.authentication = authentication;
    query.fields = fields;
    query.criteria = criteria;
    query.storage = storage;
    query.limit = limit;
    query.strategy = strategy;
    return query;
  }
}

class Join implements IJoin {
  IModel model;
  String name;
  String from;
  String to;
  String by;
  VariableMirror variableMirror;

  @override
  Object getValue(Object source) {
    var valueMirror = reflect(source).getField(variableMirror.simpleName);
    if (valueMirror.hasReflectee) {
      return valueMirror.reflectee;
    } else {
      return null;
    }
  }

  @override
  void setValue(Object source, Object value) {
    reflect(source).setField(variableMirror.simpleName, value);
  }

  @override
  IJoin copy() {
    var join = new Join();
    join.model = model;
    join.name = name;
    join.from = from;
    join.to = to;
    join.by = by;
    join.variableMirror = variableMirror;
    return join;
  }
}