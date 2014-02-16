class RenameStyleColumnOfUsers < ActiveRecord::Migration
  def change
    change_table :beers do |t|
      t.integer :style_id
      t.rename :style, :old_style
    end
  end
end
