class RemoveOldStyleColumnOfUsers < ActiveRecord::Migration
  def change
    change_table :beers do |t|
      t.remove :old_style
    end
  end
end
