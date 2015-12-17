require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    values = params.map { |_, val| val }
    where_line = params.map { |attr_name, _| "#{attr_name} = ?"}

    parse_all(DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line.join(" AND ")}
    SQL
    )
  end
end

class SQLObject
  extend Searchable
end
