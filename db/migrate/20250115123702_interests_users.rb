class InterestsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :interests_users, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :interest, null: false, foreign_key: true
    end
  end
end
