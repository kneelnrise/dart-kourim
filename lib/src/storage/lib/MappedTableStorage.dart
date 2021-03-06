part of kourim.storage.lib;

/// This class is planned for the usage of [window.sessionStorage] and [window.localStorage].
class MappedTableStorage implements ITableStorage {
  Storage storage;
  String _name;

  MappedTableStorage(this.storage, this._name);

  @override
  String get name => _name;

  @override
  Future<Option<Map<String, Object>>> find(Object key) {
    return new Future((){
      var rows = load();
      if (rows.containsKey(key)) {
        return Some(rows[key]);
      } else {
        return None;
      }
    });
  }

  @override
  Future<Iterable<Map<String, Object>>> findAll() {
    return new Future((){
      return load().values;
    });
  }

  @override
  Future<Option<Map<String, Object>>> findOneBy(Map<String, Object> parameters) {
    return new Future((){
      for (Map<String, Object> row in load().values) {
        bool valid = true;
        parameters.forEach((key, value){
          if (!row.containsKey(key) || row[key] != value) {
            valid = false;
          }
        });
        if (valid) {
          return Some(row);
        }
      }
      return None;
    });
  }

  @override
  Future<Iterable<Map<String, Object>>> findManyBy(Map<String, Object> parameters) {
    return new Future((){
      List<Map<String, Object>> result = [];
      for (Map<String, Object> row in load().values) {
        bool valid = true;
        parameters.forEach((key, value){
          if (!row.containsKey(key) || row[key] != value) {
            valid = false;
          }
        });
        if (valid) {
          result.add(row);
        }
      }
      return result;
    });
  }

  @override
  Future<Option<Map<String, Object>>> findOneWhen(Constraint constraint) {
    return new Future((){
      for (Map<String, Object> row in load().values) {
        if (constraint(row)) {
          return Some(row);
        }
      }
      return None;
    });
  }

  @override
  Future<Iterable<Map<String, Object>>> findManyWhen(Constraint constraint) {
    return new Future((){
      List<Map<String, Object>> result = [];
      for (Map<String, Object> row in load().values) {
        if (constraint(row)) {
          result.add(row);
        }
      }
      return result;
    });
  }

  @override
  Future<Option<Map<String, Object>>> findOneFor(Map<String, Object> parameters, Constraint constraint) {
    return findOneWhen((Map values){
      var valid = true;
      parameters.forEach((key, value){
        if (!values.containsKey(key) || values[key] != value) {
          valid = false;
        }
      });
      return valid && constraint(values);
    });
  }

  @override
  Future<Iterable<Map<String, Object>>> findManyFor(Map<String, Object> parameters, Constraint constraint) {
    return findManyWhen((Map values){
      var valid = true;
      parameters.forEach((key, value){
        if (!values.containsKey(key) || values[key] != value) {
          valid = false;
        }
      });
      return valid && constraint(values);
    });
  }

  @override
  Future putOne(Object key, Map<String, Object> value) {
    return new Future((){
      var rows = load();
      rows[key] = value;
      save(rows);
    });
  }

  @override
  Future putMany(Map<Object, Map<String, Object>> values) {
    return new Future((){
      var rows = load();
      rows.addAll(values);
      save(rows);
    });
  }

  @override
  Future foreach(ForeachValues process) {
    return new Future((){
      load().values.forEach(process);
    });
  }

  @override
  Future<Iterable<Object>> map(MapValues process) {
    return new Future((){
      return load().values.map(process);
    });
  }

  @override
  Future remove(Object key) {
    return new Future((){
      var rows = load();
      rows.remove(key);
    });
  }

  @override
  Future removeBy(Map<String, Object> parameters) {
    return new Future((){
      var rows = load();
      var resultRows = {};
      rows.forEach((rowKey, rowValue){
        bool keep = false;
        parameters.forEach((paramKey, paramValue){
          if (!rowValue.containsKey(paramKey) || rowValue[paramKey] != paramValue) {
            keep = true;
          }
        });
        if (keep) {
          resultRows[rowKey] = rowValue;
        }
      });
    });
  }

  @override
  Future removeWhen(Constraint constraint) {
    return new Future((){
      var rows = load();
      var resultRows = {};
      rows.forEach((rowKey, rowValue){
        if (!constraint(rowValue)) {
          resultRows[rowKey] = rowValue;
        }
      });
    });
  }

  @override
  Future clean() {
    return new Future((){
      save({});
    });
  }

  Map<Object, Map<String, Object>> load() {
    if (storage.containsKey(config.databaseName + '_' + name)) {
      return JSON.decode(storage[config.databaseName + '_' + name]);
    } else {
      return {};
    }
  }

  void save(Map<Object, Map<String, Object>> data) {
    // Transform Object keys to String keys.
    var encodedData = {};
    data.forEach((key, value){
      encodedData[key.toString()] = value;
    });
    storage[config.databaseName + '_' + name] = JSON.encode(encodedData);
  }
}