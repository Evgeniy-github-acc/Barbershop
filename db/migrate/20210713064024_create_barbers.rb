class CreateBarbers < ActiveRecord::Migration[5.2]
  def change
      create_table :barbers do |t|
        t.text :name
        
        t.timestamps
      end
  
  Barbers.create :name => 'Jessie Pinkman'
  Barbers.create :name => 'Walter White'
  Barbers.create :name => 'Gus Fring'
  end
end
