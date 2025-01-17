class SkillsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :skills_users, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
    end
  end
end
