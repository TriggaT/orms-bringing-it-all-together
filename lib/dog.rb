class Dog 

    attr_accessor :name, :breed
    attr_reader :id 
    
    def initialize(id: nil, name:, breed:)
        @id = id 
        @name = name 
        @breed = breed 
    end 

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY, 
            name TEXT,
            breed TEXT
            )
            SQL

        DB[:conn].execute(sql)
       
    end 

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        Dog.new(id: id, name: name, breed: breed)
    end 

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dogs.id = ?
        LIMIT 1
        SQL
        
        dog = DB[:conn].execute(sql, id).flatten
        self.new(id: id, name: dog[1], breed: dog[2])
    end 

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
        if !dog.empty?
            self.find_by_id(dog[0])
        else 
            dog = self.create(name: name, breed: breed)
        end 
    end 



    def self.find_by_name(name)
         sql = <<-SQL
         SELECT *
         FROM dogs
         WHERE dogs.name = ?
         LIMIT 1
         SQL
        
        dog = DB[:conn].execute(sql, name).flatten
        self.find_by_id(dog[0])
    end 

    def save
        sql = <<-SQL 
        INSERT INTO dogs (name, breed)
        VALUES (?,?);
        SQL
            
        DB[:conn].execute(sql, name, breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        Dog.new(id: id, name: name, breed: breed)
        
    
    end 

    def update
        sql = <<-SQL
        UPDATE dogs 
        SET name = ?, breed = ? 
        WHERE id = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 

    def self.create(name:, breed:) 
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end 




       


        



end 