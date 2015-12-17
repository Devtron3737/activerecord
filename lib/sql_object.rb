require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

class SQLObject
  def self.columns
    col_names_s = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    col_names_s.first.map { |col| col.to_sym }
  end

  def self.finalize!
    cols = self.columns

    cols.each do |col|
      #getter
      define_method("#{col}") do #this defines getter method for attributes
        attributes[col]
      end

      define_method("#{col}=") do |value| #this defines setter method for attributes
        attributes[col] = value           #can now call get/set methods by col names
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    if @table_name.nil?
      @table_name = self.to_s.tableize
    else
      @table_name
    end
  end

  def self.all
    puts("
      SELECT
      *
      FROM
      #{table_name}
      SQL
    ")

    parse_all(DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL
    )
  end

  def self.parse_all(results)
    parsed_results = []
    results.each { |obj| parsed_results << self.new(obj) }
    parsed_results
  end

  def self.find(id)
    objects = parse_all(DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
    #{table_name}
    WHERE
    id = ?
    SQL
    )

    objects.first
  end

  def initialize(params = {})
    cols = self.class.columns
    params.each do |attr_name, val|
      if cols.include?(attr_name.to_sym)
        self.send("#{attr_name}=", val)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attr_vals = self.class.columns.drop(1).map { |attr_name| self.send("#{attr_name}") }
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = []
    attribute_values.count.times { question_marks << "?" }
    question_marks = question_marks.join(", ")
    inserted_values = DBConnection.execute(<<-SQL, *attribute_values.drop(1))
    INSERT INTO
    #{self.class.table_name} (#{col_names})
    VALUES
    (#{question_marks})
    SQL

    self.send("id=", DBConnection.last_insert_row_id)
  end

  def update
    formatted_cols = self.class.columns.map { |col| "#{col} = ?" }
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
      #{self.class.table_name}
      SET
      #{formatted_cols.drop(1).join(", ")}
      WHERE
      id = ?
    SQL
  end

  def save
    case id.nil?
      when true
        insert
      when false
        update
    end
  end
end
