class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :patronymic
      t.string :surname
      t.string :full_name
      t.string :email, null: false
      t.string :nationality
      t.string :country
      t.string :gender
      t.integer :age

      t.timestamps
    end
  end
end
