module ActiveRecord
  class SchemaDumper
    private
      alias old_tables tables    
      def tables(stream)
        old_tables(stream)
        @connection.tables.sort.each do |tbl|
          next if tbl == "schema_info"
          foreign_key_constraints(tbl, stream)
        end
      end
    
      def foreign_key_constraints(table, stream)
        keys = @connection.foreign_key_constraints(table)
        keys.each do |key|
          stream.print "  add_foreign_key_constraint #{table.inspect}, #{key.foreign_key.inspect}, #{key.reference_table.inspect}, #{key.reference_column.inspect}, :name => #{key.name.inspect}, :on_update => #{key.on_update.inspect}, :on_delete => #{key.on_delete.inspect}"
          stream.puts
        end
        stream.puts unless keys.empty?
      end
  end
  
  module ConnectionAdapters    
    class ForeignKeyConstraintDefinition < Struct.new(:name, :foreign_key, :reference_table, :reference_column, :on_update, :on_delete) #:nodoc:
    end
    
    class AbstractAdapter
      protected
        def symbolize_foreign_key_constraint_action(constraint_action)
          constraint_action.downcase.gsub(/\s/, '_').to_sym
        end
    end
    
    class PostgreSQLAdapter < AbstractAdapter
      def foreign_key_constraints(table, name = nil)
        sql =  "SELECT conname, pg_catalog.pg_get_constraintdef(oid) AS consrc FROM pg_catalog.pg_constraint WHERE contype='f' "
        sql += "AND conrelid = (SELECT oid FROM pg_catalog.pg_class WHERE relname='#{table}')"
        
        result = query(sql, name)
        
        keys = []
        
        result.each do |row| 
          # pg_catalog.pg_get_constraintdef returns a string like this:
          # FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
          if row[1] =~ /FOREIGN KEY \((.+)\) REFERENCES (.+)\((.+)\) ON UPDATE (\w+) ON DELETE (\w+)/
            keys << ForeignKeyConstraintDefinition.new(row[0],
                                                       Regexp.last_match(1),
                                                       Regexp.last_match(2),
                                                       Regexp.last_match(3),
                                                       symbolize_foreign_key_constraint_action(Regexp.last_match(4)),
                                                       symbolize_foreign_key_constraint_action(Regexp.last_match(5)))
          end
        end
        
        keys
      end
      
      def remove_foreign_key_constraint(table_name, constraint_name)
        execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{constraint_name}"
      end
      
      alias old_default_value default_value
      def default_value(value)
        return ":now" if value =~ /^now\(\)|^\('now'::text\)::(date|timestamp)/i
        return old_default_value(value) 
      end
    end
    
    class MysqlAdapter < AbstractAdapter
      def foreign_key_constraints(table, name = nil)
        constraints = [] 
        execute("SHOW CREATE TABLE #{table}", name).each do |row|
          row[1].each do |create_line|
            if create_line.strip =~ /CONSTRAINT `([^`]+)` FOREIGN KEY \(`([^`]+)`\) REFERENCES `([^`]+)` \(`([^`]+)`\)([^,]*)/          
              constraint = ForeignKeyConstraintDefinition.new(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3), Regexp.last_match(4), nil, nil)
            
              constraint_params = {}
              
              unless Regexp.last_match(5).nil?
                Regexp.last_match(5).strip.split('ON ').each do |param|
                  constraint_params[Regexp.last_match(1).upcase] = Regexp.last_match(2).strip.upcase if param.strip =~ /([^ ]+) (.+)/
                end
              end
            
              constraint.on_update = symbolize_foreign_key_constraint_action(constraint_params['UPDATE']) if constraint_params.include? 'UPDATE'
              constraint.on_delete = symbolize_foreign_key_constraint_action(constraint_params['DELETE']) if constraint_params.include? 'DELETE'

              constraints << constraint
            end
          end
        end
    
        constraints
      end
      
      def remove_foreign_key_constraint(table_name, constraint_name)
        execute "ALTER TABLE #{table_name} DROP FOREIGN KEY #{constraint_name}"
      end      
    end
    
    class Column
      private
        alias old_extract_limit extract_limit
        def extract_limit(sql_type)
          return 255 if sql_type =~ /enum/i
          old_extract_limit(sql_type)
        end

        alias old_simplified_type simplified_type
        def simplified_type(field_type)
          return :string if field_type =~ /enum/i
          old_simplified_type(field_type)
        end
    end
    
    module SchemaStatements
      # Adds a new foreign key constraint to the table.
      #
      # The constrinat will be named after the table and the reference table and column
      # unless you pass +:name+ as an option.
      #
      # options: :name, :on_update, :on_delete   
      def foreign_key_constraint_statement(condition, fkc_sym)
        action = { :restrict => 'RESTRICT', :cascade => 'CASCADE', :set_null => 'SET NULL' }[fkc_sym]
        action ? ' ON ' << condition << ' ' << action : ''
      end
      
      def add_foreign_key_constraint(table_name, foreign_key, reference_table, reference_column, options = {})
        constraint_name = options[:name] || "#{table_name}_ibfk_#{foreign_key}"
        
        sql = "ALTER TABLE #{table_name} ADD CONSTRAINT #{constraint_name} FOREIGN KEY (#{foreign_key}) REFERENCES #{reference_table} (#{reference_column})"
    
        sql << foreign_key_constraint_statement('UPDATE', options[:on_update])
        sql << foreign_key_constraint_statement('DELETE', options[:on_delete])
        
        execute sql
      end
      
      # options: Must enter one of the two options:
      #  1)  :name => the name of the foreign key constraint
      #  2)  :foreign_key => the name of the column for which the foreign key was created
      #      (only if the default constraint_name was used)
      def remove_foreign_key_constraint(table_name, options={})
        constraint_name = options[:name] || ("#{table_name}_ibfk_#{options[:foreign_key]}" if options[:foreign_key])
        raise ArgumentError, "You must specify the constraint name" if constraint_name.blank?
        
        @connection.remove_foreign_key_constraint(table_name, constraint_name)
      end
    end
  end
end
