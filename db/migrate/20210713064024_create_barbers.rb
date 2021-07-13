class CreateBarbers < ActiveRecord::Migration[5.2]
  def change
    def change
      create_table :client do |t|
        t.text :name
        
        t.timestamps
      end
  end
end
