class AddSlugToNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :notes, :slug, :string
  end
end
