
class QModel

  def initialize(options)
    options.keys.each do |key|
      self.instance_variable_set(('@' + key).to_sym, options[key])
      self.class.send(:attr_accessor, key.to_sym)
    end
  end

  def save
    ivars = instance_variables
    options_hash = {}
    ivars.each do |var|
      str_var = var.to_s.gsub("@","").to_sym
      options_hash[str_var] = instance_variable_get(var)
    end

    set_string, insert_string, insert_values = QModel.build_strings(options_hash)

    class_name = QModel.decode_class_name(self.class.to_s)

    if @id
      QDB.instance.execute(<<-SQL, **options_hash)
        UPDATE
          #{class_name}
        SET
          #{set_string}
        WHERE
          id = :id
      SQL
    else
      QDB.instance.execute(<<-SQL, **options_hash)
        INSERT INTO
          #{class_name}(#{insert_string})
        VALUES
          (#{insert_values})
      SQL

      @id = QDB.instance.last_insert_row_id
    end
  end

  def self.find(conditions = {})
    find_string, _, _ = QModel.build_strings(conditions)
    class_name = QModel.decode_class_name(self.to_s)

    results = QDB.instance.execute(<<-SQL, **conditions)
      SELECT
        *
      FROM
        #{class_name}
      WHERE
        #{find_string}
    SQL

    results.map {|result| self.new(result)}
  end

  def self.method_missing(method_sym, *arguments, &prc)
    if method_sym.to_s =~ /^find_by_(.*)$/
      find($1.to_sym => arguments.first)
    else
      super
    end
  end

  private
  def self.build_strings(opts)
    return_string_keys = ""
    insert_values = ""
    return_string = ""
    opts.keys.each_with_index do |key, index|
      next if key == :id
      return_string_keys += "#{key}"
      insert_values += ":#{key}"
      return_string += "#{key} = :#{key}"
      if (index + 1) < opts.keys.length
        return_string_keys += ', '
        return_string += ', '
        insert_values += ', '
      end
    end
    return return_string, return_string_keys, insert_values
  end

  def self.decode_class_name(n)
    n.gsub(/(y)$/, 'ie').gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase + 's'
  end

end
