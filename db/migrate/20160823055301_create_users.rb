class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text       :mid
      t.timestamps null: false
    end
  end
end
